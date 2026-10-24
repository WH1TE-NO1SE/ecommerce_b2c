# 电商 B2C 平台

基于 Flutter、GetX、FastAPI 和 MySQL 的电商课程项目，包含用户商城、响应式管理后台和本地演示数据。支付为模拟流程。

## 功能

- 商品分类、搜索、详情与规格选择。
- 购物车、收货地址、优惠券、下单和订单状态管理。
- 登录注册、JWT 认证和管理员权限校验。
- 管理后台：统计面板、商品、订单、用户和优惠券管理。
- API 不可用时，部分商品浏览功能回退到本地 Mock 数据。

## 目录

```text
ecommerce_b2c/
├── lib/                     # Flutter 前端
│   ├── app/                 # 路由、绑定、主题、中间件
│   ├── core/                # 网络、常量、异常、国际化
│   ├── data/                # 模型、Mock 数据、本地存储
│   └── presentation/        # 页面、控制器、组件
├── assets/                  # 本地资源
├── backend/                 # FastAPI 后端与配置示例
├── database/                # MySQL 建表与演示数据脚本
├── test/                    # Flutter 测试
├── android/                 # Android 工程
├── ios/                     # iOS 工程
├── web/                     # Web 工程与课程演示页面
└── .github/workflows/ci.yml  # 自动检查
```

## 环境要求

- Flutter 3.24.5 / Dart 3.5.4（当前验证版本）。
- Python 3.12（当前验证版本）、MySQL 8.0+。
- Android 构建需要 Android SDK；iOS 构建需要 macOS 和 Xcode。

项目包含 Android、iOS、Web 工程，暂未配置 Windows 桌面工程。

## 本地启动

以下命令从项目根目录开始，使用 Windows PowerShell。其他系统可使用等价命令。

### 1. 安装后端依赖并配置

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r backend/requirements.txt
Copy-Item backend/.env.example backend/.env
.\.venv\Scripts\python.exe -c "import secrets; print(secrets.token_urlsafe(48))"
```

编辑 `backend/.env`：填写 `MYSQL_PASS`，将生成的随机值填入 `JWT_SECRET_KEY`。
已有本地 `.env` 时保留现有文件。后端和种子脚本共用该配置；系统环境变量优先于 `.env`。

| 变量 | 默认值 / 用途 |
| --- | --- |
| `MYSQL_HOST` | `127.0.0.1` |
| `MYSQL_PORT` | `3306` |
| `MYSQL_USER` | `root` |
| `MYSQL_PASS` | 本地数据库密码 |
| `MYSQL_DB` | `ecommerce_b2c` |
| `JWT_SECRET_KEY` | 必填，至少 32 字符的随机密钥 |

### 2. 初始化数据库

```powershell
mysql -u root -p
```

在 MySQL 客户端执行（将路径替换为自己的项目路径，使用正斜杠）：

```sql
SOURCE D:/path/to/ecommerce_b2c/database/create_tables.sql;
exit
```

脚本创建 `ecommerce_b2c` 数据库及 14 张表。如果修改 `MYSQL_DB`，需要同步修改 SQL 中的数据库名。

可选：向专用演示数据库导入演示数据：

```powershell
.\.venv\Scripts\python.exe database/seed_data.py
```

**种子脚本会清空现有商品、分类、订单、支付、物流、评价和优惠券等数据，请仅对演示数据库执行。**
本次仓库整理未执行该脚本。

### 3. 启动后端

```powershell
Set-Location backend
..\.venv\Scripts\python.exe -m uvicorn main:app --host 127.0.0.1 --port 8000 --reload
```

- API 文档：<http://localhost:8000/docs>
- 健康检查：<http://localhost:8000/api/health>

完整说明见 [backend/README.md](backend/README.md)。

### 4. 启动前端

另开终端，在项目根目录运行：

```powershell
flutter pub get
flutter run -d chrome
```

默认 Web API 地址为 `http://localhost:8000/api`，非 Web 默认面向 Android 模拟器，使用 `http://10.0.2.2:8000/api`。
iOS 模拟器和真机请按实际网络指定地址：

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000/api
```

真机访问时，后端应绑定可访问的网卡地址（例如开发环境下的 `0.0.0.0`），并配置防火墙。

```powershell
flutter build web
flutter build apk --debug
```

## 演示账号

执行种子脚本后可使用以下账号，限本地演示：

| 角色 | 用户名 | 密码 |
| --- | --- | --- |
| 管理员 | admin | admin123 |
| 普通用户 | test | 123456 |

## 检查

```powershell
flutter analyze
flutter test
py -3.12 -m compileall -q backend database
py -3.12 -m unittest discover -s backend -p 'test_*.py' -v
```

GitHub Actions 自动运行 Flutter 静态分析、测试、Web 构建，以及 Python 语法、配置和认证测试。
这些检查不连接数据库，不等同于完整业务联调；Android/iOS 构建需各自平台环境验证。

## 配置与仓库约定

- `.env`、数据库密码、签名密钥、本地数据库和构建缓存不提交到 Git。
- 使用 `backend/.env.example` 分享配置字段，保留 `pubspec.lock` 固定 Flutter 依赖。
- 这是课程演示项目；默认演示账号、模拟支付和开发 CORS 配置需要按正式部署要求调整。
- 项目未指定开源许可证。
