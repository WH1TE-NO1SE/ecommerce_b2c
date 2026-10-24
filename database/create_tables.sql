-- ============================================================
-- 电商B2C平台 - MySQL 建表脚本
-- 数据库: ecommerce_b2c
-- 字符集: utf8mb4
-- ============================================================

CREATE DATABASE IF NOT EXISTS ecommerce_b2c
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE ecommerce_b2c;

-- 1. 用户表
CREATE TABLE IF NOT EXISTS users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  phone VARCHAR(20) DEFAULT NULL,
  email VARCHAR(100) DEFAULT NULL,
  avatar VARCHAR(500) DEFAULT '',
  points INT DEFAULT 0,
  role VARCHAR(20) DEFAULT 'user',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. 商品分类表
CREATE TABLE IF NOT EXISTS categories (
  id VARCHAR(20) PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  icon VARCHAR(20) DEFAULT '',
  sort_order INT DEFAULT 0,
  INDEX idx_sort (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. 商品表
CREATE TABLE IF NOT EXISTS products (
  id VARCHAR(30) PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  original_price DECIMAL(10,2) DEFAULT NULL,
  image VARCHAR(500) DEFAULT '',
  category_id VARCHAR(20) DEFAULT NULL,
  rating DECIMAL(2,1) DEFAULT 5.0,
  sales INT DEFAULT 0,
  stock INT DEFAULT 0,
  is_active TINYINT(1) DEFAULT 1,
  tags VARCHAR(200) DEFAULT '',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
  INDEX idx_category (category_id),
  INDEX idx_active_sales (is_active, sales DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. 商品图片表
CREATE TABLE IF NOT EXISTS product_images (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_id VARCHAR(30) NOT NULL,
  image_url VARCHAR(500) NOT NULL,
  sort_order INT DEFAULT 0,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. 商品规格表
CREATE TABLE IF NOT EXISTS product_skus (
  id VARCHAR(30) PRIMARY KEY,
  product_id VARCHAR(30) NOT NULL,
  spec_name VARCHAR(50) NOT NULL,
  spec_value VARCHAR(100) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  stock INT DEFAULT 0,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. 商品评价表
CREATE TABLE IF NOT EXISTS reviews (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_id VARCHAR(30) NOT NULL,
  user_id BIGINT NOT NULL,
  rating TINYINT NOT NULL,
  content TEXT,
  product_spec VARCHAR(100) DEFAULT '',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_product (product_id),
  INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. 收货地址表
CREATE TABLE IF NOT EXISTS addresses (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  receiver_name VARCHAR(50) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  province VARCHAR(50) NOT NULL,
  city VARCHAR(50) NOT NULL,
  district VARCHAR(50) NOT NULL,
  detail VARCHAR(200) NOT NULL,
  is_default TINYINT(1) DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user (user_id),
  INDEX idx_default (user_id, is_default)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. 订单表
CREATE TABLE IF NOT EXISTS orders (
  id VARCHAR(30) PRIMARY KEY,
  order_no VARCHAR(30) NOT NULL UNIQUE,
  user_id BIGINT NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  freight DECIMAL(10,2) DEFAULT 0.00,
  discount DECIMAL(10,2) DEFAULT 0.00,
  actual_amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending',
  address_snapshot JSON DEFAULT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  pay_time DATETIME DEFAULT NULL,
  ship_time DATETIME DEFAULT NULL,
  receive_time DATETIME DEFAULT NULL,
  complete_time DATETIME DEFAULT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user (user_id),
  INDEX idx_status (status),
  INDEX idx_user_status (user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. 订单明细表
CREATE TABLE IF NOT EXISTS order_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id VARCHAR(30) NOT NULL,
  product_id VARCHAR(30) NOT NULL,
  product_name VARCHAR(200) NOT NULL,
  product_price DECIMAL(10,2) NOT NULL,
  product_image VARCHAR(500) DEFAULT '',
  sku_id VARCHAR(30) DEFAULT NULL,
  sku_spec_value VARCHAR(100) DEFAULT '',
  quantity INT NOT NULL DEFAULT 1,
  subtotal DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  INDEX idx_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. 支付记录表
CREATE TABLE IF NOT EXISTS payments (
  id VARCHAR(30) PRIMARY KEY,
  order_id VARCHAR(30) NOT NULL UNIQUE,
  amount DECIMAL(10,2) NOT NULL,
  pay_method VARCHAR(20) NOT NULL DEFAULT '微信支付',
  status VARCHAR(20) DEFAULT 'pending',
  paid_at DATETIME DEFAULT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  INDEX idx_order (order_id),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. 物流信息表
CREATE TABLE IF NOT EXISTS logistics (
  id VARCHAR(30) PRIMARY KEY,
  order_id VARCHAR(30) NOT NULL UNIQUE,
  company VARCHAR(50) NOT NULL,
  tracking_no VARCHAR(50) DEFAULT '',
  status VARCHAR(20) DEFAULT '',
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  INDEX idx_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. 物流节点表
CREATE TABLE IF NOT EXISTS logistics_nodes (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  logistics_id VARCHAR(30) NOT NULL,
  time VARCHAR(30) NOT NULL,
  content VARCHAR(200) NOT NULL,
  location VARCHAR(100) DEFAULT '',
  FOREIGN KEY (logistics_id) REFERENCES logistics(id) ON DELETE CASCADE,
  INDEX idx_logistics (logistics_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 13. 优惠券模板表
CREATE TABLE IF NOT EXISTS coupons (
  id VARCHAR(30) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(200) DEFAULT '',
  threshold DECIMAL(10,2) DEFAULT 0.00,
  discount DECIMAL(10,2) NOT NULL,
  type VARCHAR(20) NOT NULL DEFAULT 'fixed',
  start_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 14. 用户优惠券关联表
CREATE TABLE IF NOT EXISTS user_coupons (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  coupon_id VARCHAR(30) NOT NULL,
  is_used TINYINT(1) DEFAULT 0,
  used_at DATETIME DEFAULT NULL,
  order_id VARCHAR(30) DEFAULT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (coupon_id) REFERENCES coupons(id) ON DELETE CASCADE,
  INDEX idx_user (user_id),
  INDEX idx_user_unused (user_id, is_used)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
