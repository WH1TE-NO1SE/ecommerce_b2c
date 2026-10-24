"""数据库连接配置"""
from sqlalchemy import create_engine
from sqlalchemy.engine import URL
from sqlalchemy.orm import sessionmaker, declarative_base
from settings import MYSQL_USER, MYSQL_PASS, MYSQL_HOST, MYSQL_PORT, MYSQL_DB

# URL.create correctly handles special characters in database passwords.
DATABASE_URL = URL.create(
    "mysql+pymysql", username=MYSQL_USER, password=MYSQL_PASS,
    host=MYSQL_HOST, port=MYSQL_PORT, database=MYSQL_DB,
    query={"charset": "utf8mb4"},
)

engine = create_engine(DATABASE_URL, pool_pre_ping=True, pool_size=10)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    """FastAPI 依赖注入：获取数据库会话"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
