"""
电商B2C FastAPI 后端
启动: uvicorn main:app --host 0.0.0.0 --port 8000 --reload
文档: http://localhost:8000/docs
"""
import time
from datetime import datetime
from typing import Optional, List
from fastapi import FastAPI, Depends, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func as sql_func

from config import get_db, engine
from models import (
    Base, User, Category, Product, ProductImage, ProductSku,
    Review, Address, Order, OrderItem, Payment, Logistics,
    LogisticsNode, Coupon, UserCoupon,
)
from auth import (
    hash_password, verify_password, create_access_token,
    get_current_user, get_optional_user, require_admin,
)

# 创建表（如果不存在）
Base.metadata.create_all(bind=engine)

app = FastAPI(title="电商B2C API", version="1.3")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# 辅助函数
# ============================================================
def gen_id(prefix: str = "") -> str:
    return f"{prefix}{int(time.time() * 1000)}"


def gen_order_no() -> str:
    return f"DD{int(time.time() * 1000)}"


# 订单状态机
VALID_TRANSITIONS = {
    "pending": ["paid", "cancelled"],
    "paid": ["shipped", "cancelled", "refunding"],
    "shipped": ["delivering", "delivered"],
    "delivering": ["delivered"],
    "delivered": ["completed", "refunding"],
    "completed": [],
    "cancelled": [],
    "refunding": ["refunded"],
    "refunded": [],
}


# ============================================================
# 认证路由
# ============================================================
@app.post("/api/auth/register")
def register(data: dict, db: Session = Depends(get_db)):
    username = data.get("username", "").strip()
    password = data.get("password", "")
    if not username or len(password) < 6:
        raise HTTPException(400, "用户名不能为空，密码至少6位")
    if db.query(User).filter(User.username == username).first():
        raise HTTPException(400, "用户名已存在")
    user = User(
        username=username,
        password_hash=hash_password(password),
        phone=data.get("phone", ""),
        email=data.get("email", ""),
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    token = create_access_token({"sub": str(user.id)})
    return {"token": token, "user": _user_dict(user)}


@app.post("/api/auth/login")
def login(data: dict, db: Session = Depends(get_db)):
    username = data.get("username", "")
    password = data.get("password", "")
    user = db.query(User).filter(User.username == username).first()
    if not user or not verify_password(password, user.password_hash):
        raise HTTPException(401, "用户名或密码错误")
    token = create_access_token({"sub": str(user.id)})
    return {"token": token, "user": _user_dict(user)}


def _user_dict(u: User) -> dict:
    return {
        "id": str(u.id), "username": u.username, "phone": u.phone or "",
        "email": u.email or "", "avatar": u.avatar or "",
        "points": u.points, "role": u.role,
    }


# ============================================================
# 商品路由
# ============================================================
@app.get("/api/categories")
def list_categories(db: Session = Depends(get_db)):
    cats = db.query(Category).order_by(Category.sort_order).all()
    return [{"id": c.id, "name": c.name, "icon": c.icon} for c in cats]


@app.get("/api/products")
def list_products(
    category: Optional[str] = None,
    keyword: Optional[str] = None,
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    q = db.query(Product).filter(Product.is_active == 1)
    if category:
        q = q.filter(Product.category_id == category)
    if keyword:
        q = q.filter(Product.name.contains(keyword))
    total = q.count()
    items = q.order_by(Product.sales.desc()).offset((page - 1) * size).limit(size).all()
    return {
        "total": total,
        "page": page,
        "size": size,
        "items": [_product_brief(p) for p in items],
    }


@app.get("/api/products/{product_id}")
def get_product(product_id: str, db: Session = Depends(get_db)):
    p = db.query(Product).options(
        joinedload(Product.skus),
        joinedload(Product.images),
        joinedload(Product.reviews).joinedload(Review.user),
    ).filter(Product.id == product_id).first()
    if not p:
        raise HTTPException(404, "商品不存在")
    return _product_detail(p)


def _product_brief(p: Product) -> dict:
    return {
        "id": p.id, "name": p.name, "description": p.description or "",
        "price": float(p.price), "originalPrice": float(p.original_price or p.price),
        "image": p.image or "", "category": p.category_id or "",
        "rating": float(p.rating or 5), "sales": p.sales, "stock": p.stock,
        "tags": p.tags or "",
    }


def _product_detail(p: Product) -> dict:
    d = _product_brief(p)
    d["images"] = [img.image_url for img in sorted(p.images, key=lambda x: x.sort_order)]
    d["skus"] = [
        {"id": s.id, "specName": s.spec_name, "specValue": s.spec_value,
         "price": float(s.price), "stock": s.stock}
        for s in p.skus
    ]
    d["reviews"] = [
        {"id": str(r.id), "userId": str(r.user_id), "username": r.user.username if r.user else "",
         "avatar": r.user.avatar if r.user else "", "rating": r.rating,
         "content": r.content or "", "createTime": r.created_at.isoformat() if r.created_at else "",
         "productSpec": r.product_spec or ""}
        for r in p.reviews
    ]
    return d


# ============================================================
# 购物车路由
# ============================================================
@app.get("/api/cart")
def get_cart(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """获取购物车（从 order_items 中 status=pending 的临时订单获取，或用独立 cart 表）"""
    # 这里用一个简单的方案：直接查 order_items 中属于该用户的 pending 订单
    # 实际生产中建议用独立 cart 表，这里为简化直接返回空，由前端 GetStorage 管理
    # 后续可扩展独立 cart 表
    return {"items": []}


@app.post("/api/cart/sync")
def sync_cart(data: dict, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """同步购物车（前端推送完整购物车到后端校验库存）"""
    items = data.get("items", [])
    result = []
    for item in items:
        product = db.query(Product).filter(Product.id == item.get("productId")).first()
        if not product:
            result.append({"id": item.get("id"), "valid": False, "reason": "商品已下架"})
            continue
        sku_id = item.get("skuId")
        stock = product.stock
        if sku_id:
            sku = db.query(ProductSku).filter(ProductSku.id == sku_id).first()
            if sku:
                stock = sku.stock
        qty = item.get("quantity", 1)
        if qty > stock:
            result.append({"id": item.get("id"), "valid": False, "reason": f"库存不足，仅剩{stock}件"})
        else:
            result.append({"id": item.get("id"), "valid": True})
    return {"results": result}


# ============================================================
# 订单路由
# ============================================================
@app.post("/api/orders")
def create_order(data: dict, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    items = data.get("items", [])
    address_data = data.get("address")
    if not items:
        raise HTTPException(400, "订单商品不能为空")
    if not address_data:
        raise HTTPException(400, "收货地址不能为空")

    total_amount = 0
    order_items_data = []
    for item in items:
        product = db.query(Product).filter(Product.id == item["productId"]).first()
        if not product:
            raise HTTPException(400, f"商品 {item.get('productId')} 不存在")
        price = float(product.price)
        sku_id = item.get("skuId")
        sku_spec = ""
        if sku_id:
            sku = db.query(ProductSku).filter(ProductSku.id == sku_id).first()
            if sku:
                price = float(sku.price)
                sku_spec = sku.spec_value
                # 扣减SKU库存
                if sku.stock < item["quantity"]:
                    raise HTTPException(409, f"{product.name} {sku_spec} 库存不足")
                sku.stock -= item["quantity"]
        else:
            if product.stock < item["quantity"]:
                raise HTTPException(409, f"{product.name} 库存不足")
            product.stock -= item["quantity"]

        subtotal = price * item["quantity"]
        total_amount += subtotal
        product.sales += item["quantity"]
        order_items_data.append({
            "product_id": product.id,
            "product_name": product.name,
            "product_price": price,
            "product_image": product.image or "",
            "sku_id": sku_id,
            "sku_spec_value": sku_spec,
            "quantity": item["quantity"],
            "subtotal": subtotal,
        })

    freight = float(data.get("freight", 0))
    discount = float(data.get("discount", 0))
    actual_amount = total_amount + freight - discount

    order_id = gen_id("order_")
    order = Order(
        id=order_id,
        order_no=gen_order_no(),
        user_id=user.id,
        total_amount=total_amount,
        freight=freight,
        discount=discount,
        actual_amount=actual_amount,
        status="pending",
        address_snapshot=address_data,
    )
    db.add(order)
    db.flush()

    for oid in order_items_data:
        db.add(OrderItem(order_id=order_id, **oid))

    # 创建支付记录
    db.add(Payment(
        id=gen_id("pay_"),
        order_id=order_id,
        amount=actual_amount,
        pay_method=data.get("payMethod", "微信支付"),
        status="pending",
    ))

    db.commit()
    return {"orderId": order_id, "orderNo": order.order_no, "actualAmount": actual_amount}


@app.get("/api/orders")
def list_orders(
    status: Optional[str] = None,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    q = db.query(Order).filter(Order.user_id == user.id)
    if status:
        q = q.filter(Order.status == status)
    orders = q.order_by(Order.created_at.desc()).all()
    return {"items": [_order_dict(o) for o in orders]}


@app.get("/api/orders/{order_id}")
def get_order(order_id: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    o = db.query(Order).options(
        joinedload(Order.items),
        joinedload(Order.payment),
        joinedload(Order.logistics).joinedload(Logistics.nodes),
    ).filter(Order.id == order_id, Order.user_id == user.id).first()
    if not o:
        raise HTTPException(404, "订单不存在")
    return _order_dict(o)


@app.put("/api/orders/{order_id}/status")
def update_order_status(order_id: str, data: dict, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    new_status = data.get("status")
    o = db.query(Order).filter(Order.id == order_id).first()
    if not o:
        raise HTTPException(404, "订单不存在")
    # 普通用户只能操作自己的订单，管理员可以操作所有
    if user.role != "admin" and o.user_id != user.id:
        raise HTTPException(403, "无权操作")
    allowed = VALID_TRANSITIONS.get(o.status, [])
    if new_status not in allowed:
        raise HTTPException(400, f"不允许从 {o.status} 变为 {new_status}")
    o.status = new_status
    now = datetime.now()
    if new_status == "paid":
        o.pay_time = now
        # 更新支付记录
        pay = db.query(Payment).filter(Payment.order_id == order_id).first()
        if pay:
            pay.status = "success"
            pay.paid_at = now
    elif new_status == "shipped":
        o.ship_time = now
    elif new_status == "delivered":
        o.receive_time = now
    elif new_status == "completed":
        o.complete_time = now
    elif new_status == "cancelled":
        # 退回库存
        for item in o.items:
            product = db.query(Product).filter(Product.id == item.product_id).first()
            if product:
                product.stock += item.quantity
                if item.sku_id:
                    sku = db.query(ProductSku).filter(ProductSku.id == item.sku_id).first()
                    if sku:
                        sku.stock += item.quantity
    db.commit()
    return {"ok": True, "status": new_status}


@app.post("/api/orders/{order_id}/pay")
def pay_order(order_id: str, data: dict, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """模拟支付"""
    o = db.query(Order).filter(Order.id == order_id, Order.user_id == user.id).first()
    if not o:
        raise HTTPException(404, "订单不存在")
    if o.status != "pending":
        raise HTTPException(400, f"订单状态为 {o.status}，无法支付")
    pay_method = data.get("payMethod", "微信支付")
    now = datetime.now()
    o.status = "paid"
    o.pay_time = now
    pay = db.query(Payment).filter(Payment.order_id == order_id).first()
    if pay:
        pay.status = "success"
        pay.paid_at = now
        pay.pay_method = pay_method
    db.commit()
    return {"ok": True, "status": "paid"}


def _order_dict(o: Order) -> dict:
    addr = o.address_snapshot or {}
    items = [
        {
            "id": str(oi.id),
            "product": {
                "id": oi.product_id, "name": oi.product_name,
                "price": float(oi.product_price), "image": oi.product_image or "",
                "description": "", "originalPrice": float(oi.product_price),
                "images": [], "category": "", "rating": 0, "sales": 0, "stock": 0, "skus": [],
            },
            "sku": {"id": oi.sku_id, "specName": "", "specValue": oi.sku_spec_value or "",
                    "price": float(oi.product_price), "stock": 0} if oi.sku_id else None,
            "quantity": oi.quantity,
            "isSelected": True,
            "addTime": o.created_at.isoformat() if o.created_at else "",
        }
        for oi in o.items
    ]
    pay_dict = None
    if o.payment:
        pay_dict = {
            "id": o.payment.id, "orderId": o.payment.order_id,
            "amount": float(o.payment.amount), "payMethod": o.payment.pay_method,
            "status": o.payment.status,
        }
    return {
        "id": o.id, "orderNo": o.order_no,
        "totalAmount": float(o.total_amount), "freight": float(o.freight),
        "discount": float(o.discount), "actualAmount": float(o.actual_amount),
        "status": o.status, "address": addr, "items": items, "payment": pay_dict,
        "createTime": o.created_at.isoformat() if o.created_at else None,
        "payTime": o.pay_time.isoformat() if o.pay_time else None,
        "shipTime": o.ship_time.isoformat() if o.ship_time else None,
        "receiveTime": o.receive_time.isoformat() if o.receive_time else None,
        "completeTime": o.complete_time.isoformat() if o.complete_time else None,
    }


# ============================================================
# 地址路由
# ============================================================
@app.get("/api/addresses")
def list_addresses(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    addrs = db.query(Address).filter(Address.user_id == user.id).order_by(Address.is_default.desc()).all()
    return {"items": [_addr_dict(a) for a in addrs]}


@app.post("/api/addresses")
def create_address(data: dict, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if data.get("isDefault"):
        db.query(Address).filter(Address.user_id == user.id).update({"is_default": 0})
    addr = Address(user_id=user.id, **_addr_fields(data))
    db.add(addr)
    db.commit()
    db.refresh(addr)
    return _addr_dict(addr)


@app.put("/api/addresses/{addr_id}")
def update_address(addr_id: int, data: dict, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    addr = db.query(Address).filter(Address.id == addr_id, Address.user_id == user.id).first()
    if not addr:
        raise HTTPException(404, "地址不存在")
    if data.get("isDefault"):
        db.query(Address).filter(Address.user_id == user.id, Address.id != addr_id).update({"is_default": 0})
    for k, v in _addr_fields(data).items():
        setattr(addr, k, v)
    db.commit()
    return _addr_dict(addr)


@app.delete("/api/addresses/{addr_id}")
def delete_address(addr_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    addr = db.query(Address).filter(Address.id == addr_id, Address.user_id == user.id).first()
    if not addr:
        raise HTTPException(404, "地址不存在")
    db.delete(addr)
    db.commit()
    return {"ok": True}


@app.put("/api/addresses/{addr_id}/default")
def set_default_address(addr_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    addr = db.query(Address).filter(Address.id == addr_id, Address.user_id == user.id).first()
    if not addr:
        raise HTTPException(404, "地址不存在")
    db.query(Address).filter(Address.user_id == user.id).update({"is_default": 0})
    addr.is_default = 1
    db.commit()
    return {"ok": True}


def _addr_fields(data: dict) -> dict:
    return {
        "receiver_name": data.get("receiverName", ""),
        "phone": data.get("phone", ""),
        "province": data.get("province", ""),
        "city": data.get("city", ""),
        "district": data.get("district", ""),
        "detail": data.get("detail", ""),
        "is_default": 1 if data.get("isDefault") else 0,
    }


def _addr_dict(a: Address) -> dict:
    return {
        "id": str(a.id), "receiverName": a.receiver_name, "phone": a.phone,
        "province": a.province, "city": a.city, "district": a.district,
        "detail": a.detail, "isDefault": bool(a.is_default),
    }


# ============================================================
# 优惠券路由
# ============================================================
@app.get("/api/coupons")
def list_coupons(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    now = datetime.now()
    coupons = db.query(Coupon).filter(Coupon.start_time <= now, Coupon.end_time >= now).all()
    return {"items": [
        {"id": c.id, "name": c.name, "description": c.description,
         "threshold": float(c.threshold), "discount": float(c.discount),
         "type": c.type, "startTime": c.start_time.isoformat(),
         "endTime": c.end_time.isoformat()}
        for c in coupons
    ]}


# ============================================================
# 管理员路由
# ============================================================
@app.get("/api/admin/dashboard")
def admin_dashboard(admin: User = Depends(require_admin), db: Session = Depends(get_db)):
    total_products = db.query(Product).filter(Product.is_active == 1).count()
    total_orders = db.query(Order).count()
    total_sales = db.query(sql_func.sum(Order.actual_amount)).filter(
        Order.status.in_(["paid", "shipped", "delivered", "completed"])
    ).scalar() or 0
    pending_orders = db.query(Order).filter(Order.status.in_(["pending", "paid"])).count()
    total_users = db.query(User).count()
    # 热销商品 TOP10
    top_products = db.query(Product).filter(Product.is_active == 1).order_by(Product.sales.desc()).limit(10).all()
    return {
        "totalProducts": total_products,
        "totalOrders": total_orders,
        "totalSales": float(total_sales),
        "pendingOrders": pending_orders,
        "totalUsers": total_users,
        "topProducts": [{"id": p.id, "name": p.name, "sales": p.sales, "price": float(p.price)} for p in top_products],
    }


# ============================================================
# 管理员 - 商品管理
# ============================================================
@app.get("/api/admin/products")
def admin_list_products(
    keyword: Optional[str] = None,
    category: Optional[str] = None,
    status: Optional[str] = None,
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    q = db.query(Product)
    if keyword:
        q = q.filter(Product.name.contains(keyword))
    if category:
        q = q.filter(Product.category_id == category)
    if status == "active":
        q = q.filter(Product.is_active == 1)
    elif status == "inactive":
        q = q.filter(Product.is_active == 0)
    total = q.count()
    items = q.order_by(Product.created_at.desc()).offset((page - 1) * size).limit(size).all()
    return {
        "total": total, "page": page, "size": size,
        "items": [_admin_product_dict(p) for p in items],
    }


@app.post("/api/admin/products")
def admin_add_product(data: dict, admin: User = Depends(require_admin), db: Session = Depends(get_db)):
    pid = data.get("id") or gen_id("prod_")
    product = Product(
        id=pid, name=data["name"], description=data.get("description", ""),
        price=data["price"], original_price=data.get("originalPrice"),
        image=data.get("image", ""), category_id=data.get("categoryId"),
        rating=data.get("rating", 5.0), sales=data.get("sales", 0),
        stock=data.get("stock", 0), is_active=data.get("isActive", 1),
        tags=data.get("tags", ""),
    )
    db.add(product)
    if data.get("image"):
        db.add(ProductImage(product_id=pid, image_url=data["image"], sort_order=0))
    # 添加 SKU
    for sku in data.get("skus", []):
        db.add(ProductSku(
            id=sku.get("id") or gen_id("sku_"), product_id=pid,
            spec_name=sku["specName"], spec_value=sku["specValue"],
            price=sku.get("price", data["price"]), stock=sku.get("stock", 0),
        ))
    db.commit()
    return {"ok": True, "id": pid}


@app.put("/api/admin/products/{product_id}")
def admin_update_product(product_id: str, data: dict, admin: User = Depends(require_admin), db: Session = Depends(get_db)):
    p = db.query(Product).filter(Product.id == product_id).first()
    if not p:
        raise HTTPException(404, "商品不存在")
    field_map = {
        "name": "name", "description": "description", "price": "price",
        "originalPrice": "original_price", "image": "image",
        "categoryId": "category_id", "stock": "stock", "sales": "sales",
        "rating": "rating", "isActive": "is_active", "tags": "tags",
    }
    for camel, snake in field_map.items():
        if camel in data:
            setattr(p, snake, data[camel])
    db.commit()
    return {"ok": True}


@app.delete("/api/admin/products/{product_id}")
def admin_delete_product(product_id: str, admin: User = Depends(require_admin), db: Session = Depends(get_db)):
    p = db.query(Product).filter(Product.id == product_id).first()
    if not p:
        raise HTTPException(404, "商品不存在")
    db.delete(p)
    db.commit()
    return {"ok": True}


@app.put("/api/admin/products/{product_id}/status")
def admin_toggle_product_status(product_id: str, data: dict, admin: User = Depends(require_admin), db: Session = Depends(get_db)):
    p = db.query(Product).filter(Product.id == product_id).first()
    if not p:
        raise HTTPException(404, "商品不存在")
    p.is_active = 1 if data.get("isActive", True) else 0
    db.commit()
    return {"ok": True, "isActive": bool(p.is_active)}


def _admin_product_dict(p: Product) -> dict:
    skus = db_skus(p)
    return {
        "id": p.id, "name": p.name, "description": p.description or "",
        "price": float(p.price), "originalPrice": float(p.original_price or p.price),
        "image": p.image or "", "categoryId": p.category_id or "",
        "rating": float(p.rating or 5), "sales": p.sales, "stock": p.stock,
        "isActive": bool(p.is_active), "tags": p.tags or "",
        "skus": [{"id": s.id, "specName": s.spec_name, "specValue": s.spec_value,
                   "price": float(s.price), "stock": s.stock} for s in skus],
    }


def db_skus(p: Product) -> list:
    from config import SessionLocal
    db = SessionLocal()
    try:
        return db.query(ProductSku).filter(ProductSku.product_id == p.id).all()
    finally:
        db.close()


# ============================================================
# 管理员 - 订单管理
# ============================================================
@app.get("/api/admin/orders")
def admin_list_orders(
    status: Optional[str] = None,
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    q = db.query(Order)
    if status:
        q = q.filter(Order.status == status)
    total = q.count()
    orders = q.order_by(Order.created_at.desc()).offset((page - 1) * size).limit(size).all()
    return {"total": total, "page": page, "items": [_order_dict(o) for o in orders]}


@app.put("/api/admin/orders/{order_id}/ship")
def admin_ship_order(order_id: str, data: dict, admin: User = Depends(require_admin), db: Session = Depends(get_db)):
    o = db.query(Order).filter(Order.id == order_id).first()
    if not o:
        raise HTTPException(404, "订单不存在")
    if o.status != "paid":
        raise HTTPException(400, f"订单状态为 {o.status}，无法发货")
    now = datetime.now()
    o.status = "shipped"
    o.ship_time = now
    # 创建物流信息
    company = data.get("company", "顺丰速运")
    tracking_no = data.get("trackingNo", f"SF{int(now.timestamp())}")
    logistics = Logistics(
        id=gen_id("log_"), order_id=order_id,
        company=company, tracking_no=tracking_no, status="已发货",
    )
    db.add(logistics)
    db.add(LogisticsNode(
        logistics_id=logistics.id, time=now.strftime("%Y-%m-%d %H:%M"),
        content=f"{company}已取件", location="仓库",
    ))
    db.commit()
    return {"ok": True, "status": "shipped", "trackingNo": tracking_no}


# ============================================================
# 管理员 - 用户管理
# ============================================================
@app.get("/api/admin/users")
def admin_list_users(
    keyword: Optional[str] = None,
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    q = db.query(User)
    if keyword:
        q = q.filter(User.username.contains(keyword) | User.phone.contains(keyword))
    total = q.count()
    users = q.order_by(User.created_at.desc()).offset((page - 1) * size).limit(size).all()
    return {
        "total": total, "page": page,
        "items": [{
            "id": str(u.id), "username": u.username, "phone": u.phone or "",
            "email": u.email or "", "role": u.role, "points": u.points,
            "createdAt": u.created_at.isoformat() if u.created_at else "",
        } for u in users],
    }


@app.put("/api/admin/users/{user_id}/role")
def admin_update_user_role(user_id: int, data: dict, admin: User = Depends(require_admin), db: Session = Depends(get_db)):
    u = db.query(User).filter(User.id == user_id).first()
    if not u:
        raise HTTPException(404, "用户不存在")
    new_role = data.get("role", "user")
    if new_role not in ("user", "admin"):
        raise HTTPException(400, "角色只能是 user 或 admin")
    u.role = new_role
    db.commit()
    return {"ok": True, "role": new_role}


# ============================================================
# 管理员 - 优惠券管理
# ============================================================
@app.get("/api/admin/coupons")
def admin_list_coupons(admin: User = Depends(require_admin), db: Session = Depends(get_db)):
    coupons = db.query(Coupon).order_by(Coupon.start_time.desc()).all()
    return {"items": [_coupon_dict(c) for c in coupons]}


@app.post("/api/admin/coupons")
def admin_add_coupon(data: dict, admin: User = Depends(require_admin), db: Session = Depends(get_db)):
    cid = data.get("id") or gen_id("coupon_")
    coupon = Coupon(
        id=cid, name=data["name"], description=data.get("description", ""),
        threshold=data.get("threshold", 0), discount=data["discount"],
        type=data.get("type", "fixed"),
        start_time=datetime.fromisoformat(data["startTime"]),
        end_time=datetime.fromisoformat(data["endTime"]),
    )
    db.add(coupon)
    db.commit()
    return {"ok": True, "id": cid}


@app.put("/api/admin/coupons/{coupon_id}")
def admin_update_coupon(coupon_id: str, data: dict, admin: User = Depends(require_admin), db: Session = Depends(get_db)):
    c = db.query(Coupon).filter(Coupon.id == coupon_id).first()
    if not c:
        raise HTTPException(404, "优惠券不存在")
    for key in ["name", "description", "threshold", "discount", "type"]:
        if key in data:
            setattr(c, key, data[key])
    if "startTime" in data:
        c.start_time = datetime.fromisoformat(data["startTime"])
    if "endTime" in data:
        c.end_time = datetime.fromisoformat(data["endTime"])
    db.commit()
    return {"ok": True}


@app.delete("/api/admin/coupons/{coupon_id}")
def admin_delete_coupon(coupon_id: str, admin: User = Depends(require_admin), db: Session = Depends(get_db)):
    c = db.query(Coupon).filter(Coupon.id == coupon_id).first()
    if not c:
        raise HTTPException(404, "优惠券不存在")
    db.delete(c)
    db.commit()
    return {"ok": True}


def _coupon_dict(c: Coupon) -> dict:
    return {
        "id": c.id, "name": c.name, "description": c.description or "",
        "threshold": float(c.threshold), "discount": float(c.discount),
        "type": c.type,
        "startTime": c.start_time.isoformat() if c.start_time else "",
        "endTime": c.end_time.isoformat() if c.end_time else "",
    }


# ============================================================
# 健康检查
# ============================================================
@app.get("/api/health")
def health():
    return {"status": "ok", "version": "1.4"}
