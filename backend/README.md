# 电商 B2C 后端

FastAPI + SQLAlchemy + MySQL，提供认证、商品、购物车、订单、模拟支付、收货地址、优惠券和管理员 API。

## 配置与启动

完整初始化流程见 [项目 README](../README.md)。从项目根目录运行：

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r backend/requirements.txt
Copy-Item backend/.env.example backend/.env
.\.venv\Scripts\python.exe -c "import secrets; print(secrets.token_urlsafe(48))"
```

在 `backend/.env` 填写数据库密码和随机 `JWT_SECRET_KEY`，已有 `.env` 时保留现有文件。
环境变量优先于 `.env`，配置从文件所在目录加载，不依赖启动终端的当前路径。

通过 `database/create_tables.sql` 建库建表后启动：

```powershell
Set-Location backend
..\.venv\Scripts\python.exe -m uvicorn main:app --host 127.0.0.1 --port 8000 --reload
```

启动时会连接数据库并创建缺失表；请先确保 MySQL 服务和数据库存在。

- Swagger 文档：<http://localhost:8000/docs>（以运行中的路由为准）。
- 健康检查：<http://localhost:8000/api/health>。
- 认证：`POST /api/auth/register`、`POST /api/auth/login`。
- 业务：`/api/products`、`/api/categories`、`/api/cart`、`/api/orders`、`/api/addresses`、`/api/coupons`。
- 管理后台：`/api/admin/*`，要求管理员身份。

## 演示数据

从根目录执行 `.\.venv\Scripts\python.exe database/seed_data.py`。
**该脚本会清空商品、分类、订单等数据，只用于专用演示数据库。**
演示账号见根目录 README。

## 无数据库检查

```powershell
py -3.12 -m compileall -q backend database
py -3.12 -m unittest discover -s backend -p 'test_*.py' -v
```

在项目根目录执行。测试涵盖环境变量优先级、特殊字符数据库密码、JWT 密钥校验与令牌签名验证。
业务 API 的完整验证还需要运行 MySQL 并进行前后端联调。
