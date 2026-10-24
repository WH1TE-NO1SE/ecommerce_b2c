"""SQLAlchemy ORM 模型 — 对应 database/create_tables.sql 的 14 张表"""
from sqlalchemy import Column, BigInteger, String, Integer, Text, Numeric, DateTime, SmallInteger, JSON, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from config import Base


class User(Base):
    __tablename__ = "users"
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    username = Column(String(50), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    phone = Column(String(20))
    email = Column(String(100))
    avatar = Column(String(500), default="")
    points = Column(Integer, default=0)
    role = Column(String(20), default="user")
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    addresses = relationship("Address", back_populates="user")
    orders = relationship("Order", back_populates="user")


class Category(Base):
    __tablename__ = "categories"
    id = Column(String(20), primary_key=True)
    name = Column(String(50), nullable=False)
    icon = Column(String(20), default="")
    sort_order = Column(Integer, default=0)

    products = relationship("Product", back_populates="category")


class Product(Base):
    __tablename__ = "products"
    id = Column(String(30), primary_key=True)
    name = Column(String(200), nullable=False)
    description = Column(Text)
    price = Column(Numeric(10, 2), nullable=False)
    original_price = Column(Numeric(10, 2))
    image = Column(String(500), default="")
    category_id = Column(String(20), ForeignKey("categories.id", ondelete="SET NULL"))
    rating = Column(Numeric(2, 1), default=5.0)
    sales = Column(Integer, default=0)
    stock = Column(Integer, default=0)
    is_active = Column(SmallInteger, default=1)
    tags = Column(String(200), default="")
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    category = relationship("Category", back_populates="products")
    images = relationship("ProductImage", back_populates="product", cascade="all, delete-orphan")
    skus = relationship("ProductSku", back_populates="product", cascade="all, delete-orphan")
    reviews = relationship("Review", back_populates="product", cascade="all, delete-orphan")


class ProductImage(Base):
    __tablename__ = "product_images"
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    product_id = Column(String(30), ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    image_url = Column(String(500), nullable=False)
    sort_order = Column(Integer, default=0)

    product = relationship("Product", back_populates="images")


class ProductSku(Base):
    __tablename__ = "product_skus"
    id = Column(String(30), primary_key=True)
    product_id = Column(String(30), ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    spec_name = Column(String(50), nullable=False)
    spec_value = Column(String(100), nullable=False)
    price = Column(Numeric(10, 2), nullable=False)
    stock = Column(Integer, default=0)

    product = relationship("Product", back_populates="skus")


class Review(Base):
    __tablename__ = "reviews"
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    product_id = Column(String(30), ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    rating = Column(SmallInteger, nullable=False)
    content = Column(Text)
    product_spec = Column(String(100), default="")
    created_at = Column(DateTime, server_default=func.now())

    product = relationship("Product", back_populates="reviews")
    user = relationship("User")


class Address(Base):
    __tablename__ = "addresses"
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    user_id = Column(BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    receiver_name = Column(String(50), nullable=False)
    phone = Column(String(20), nullable=False)
    province = Column(String(50), nullable=False)
    city = Column(String(50), nullable=False)
    district = Column(String(50), nullable=False)
    detail = Column(String(200), nullable=False)
    is_default = Column(SmallInteger, default=0)
    created_at = Column(DateTime, server_default=func.now())

    user = relationship("User", back_populates="addresses")


class Order(Base):
    __tablename__ = "orders"
    id = Column(String(30), primary_key=True)
    order_no = Column(String(30), unique=True, nullable=False)
    user_id = Column(BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    total_amount = Column(Numeric(10, 2), nullable=False)
    freight = Column(Numeric(10, 2), default=0)
    discount = Column(Numeric(10, 2), default=0)
    actual_amount = Column(Numeric(10, 2), nullable=False)
    status = Column(String(20), nullable=False, default="pending")
    address_snapshot = Column(JSON)
    created_at = Column(DateTime, server_default=func.now())
    pay_time = Column(DateTime)
    ship_time = Column(DateTime)
    receive_time = Column(DateTime)
    complete_time = Column(DateTime)

    user = relationship("User", back_populates="orders")
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")
    payment = relationship("Payment", back_populates="order", uselist=False, cascade="all, delete-orphan")
    logistics = relationship("Logistics", back_populates="order", uselist=False, cascade="all, delete-orphan")


class OrderItem(Base):
    __tablename__ = "order_items"
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    order_id = Column(String(30), ForeignKey("orders.id", ondelete="CASCADE"), nullable=False)
    product_id = Column(String(30), nullable=False)
    product_name = Column(String(200), nullable=False)
    product_price = Column(Numeric(10, 2), nullable=False)
    product_image = Column(String(500), default="")
    sku_id = Column(String(30))
    sku_spec_value = Column(String(100), default="")
    quantity = Column(Integer, nullable=False, default=1)
    subtotal = Column(Numeric(10, 2), nullable=False)

    order = relationship("Order", back_populates="items")


class Payment(Base):
    __tablename__ = "payments"
    id = Column(String(30), primary_key=True)
    order_id = Column(String(30), ForeignKey("orders.id", ondelete="CASCADE"), unique=True, nullable=False)
    amount = Column(Numeric(10, 2), nullable=False)
    pay_method = Column(String(20), nullable=False, default="微信支付")
    status = Column(String(20), default="pending")
    paid_at = Column(DateTime)

    order = relationship("Order", back_populates="payment")


class Logistics(Base):
    __tablename__ = "logistics"
    id = Column(String(30), primary_key=True)
    order_id = Column(String(30), ForeignKey("orders.id", ondelete="CASCADE"), unique=True, nullable=False)
    company = Column(String(50), nullable=False)
    tracking_no = Column(String(50), default="")
    status = Column(String(20), default="")

    order = relationship("Order", back_populates="logistics")
    nodes = relationship("LogisticsNode", back_populates="logistics", cascade="all, delete-orphan")


class LogisticsNode(Base):
    __tablename__ = "logistics_nodes"
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    logistics_id = Column(String(30), ForeignKey("logistics.id", ondelete="CASCADE"), nullable=False)
    time = Column(String(30), nullable=False)
    content = Column(String(200), nullable=False)
    location = Column(String(100), default="")

    logistics = relationship("Logistics", back_populates="nodes")


class Coupon(Base):
    __tablename__ = "coupons"
    id = Column(String(30), primary_key=True)
    name = Column(String(100), nullable=False)
    description = Column(String(200), default="")
    threshold = Column(Numeric(10, 2), default=0)
    discount = Column(Numeric(10, 2), nullable=False)
    type = Column(String(20), nullable=False, default="fixed")
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime, nullable=False)


class UserCoupon(Base):
    __tablename__ = "user_coupons"
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    user_id = Column(BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    coupon_id = Column(String(30), ForeignKey("coupons.id", ondelete="CASCADE"), nullable=False)
    is_used = Column(SmallInteger, default=0)
    used_at = Column(DateTime)
    order_id = Column(String(30))
    created_at = Column(DateTime, server_default=func.now())

    coupon = relationship("Coupon")
