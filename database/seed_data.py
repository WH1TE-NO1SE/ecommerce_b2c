"""
电商B2C 种子数据脚本 v2 — 全面升级版
用法: python seed_data.py
"""
import pymysql
import bcrypt
import sys
from datetime import datetime, timedelta
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from backend.settings import MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASS, MYSQL_DB

DB_CONFIG = {
    'host': MYSQL_HOST,
    'port': MYSQL_PORT,
    'user': MYSQL_USER,
    'password': MYSQL_PASS,
    'database': MYSQL_DB,
    'charset': 'utf8mb4',
}

def hash_password(pwd):
    return bcrypt.hashpw(pwd.encode(), bcrypt.gensalt()).decode()

def seed():
    conn = pymysql.connect(**DB_CONFIG)
    cur = conn.cursor()

    # 清空旧数据（按外键依赖顺序）
    for t in ['logistics_nodes','logistics','payments','order_items','orders',
              'user_coupons','reviews','product_skus','product_images','products',
              'categories','coupons']:
        cur.execute(f"DELETE FROM {t}")
    conn.commit()

    now = datetime.now()

    # ========== 1. 用户 ==========
    cur.execute("INSERT IGNORE INTO users (username, password_hash, phone, email, points, role) VALUES (%s,%s,%s,%s,%s,%s)",
        ('admin', hash_password('admin123'), '13800000000', 'admin@shop.com', 99999, 'admin'))
    cur.execute("INSERT IGNORE INTO users (username, password_hash, phone, email, points, role) VALUES (%s,%s,%s,%s,%s,%s)",
        ('test', hash_password('123456'), '13811112222', 'test@shop.com', 100, 'user'))

    # ========== 2. 分类 ==========
    cats = [
        ('cat_1','手机数码','📱',1), ('cat_2','服饰内衣','👕',2),
        ('cat_3','食品生鲜','🍎',3), ('cat_4','美妆护肤','💄',4),
        ('cat_5','家居日用','🏠',5), ('cat_6','电脑办公','💻',6),
        ('cat_7','鞋靴箱包','👟',7), ('cat_8','运动户外','⚽',8),
    ]
    cur.executemany("INSERT INTO categories (id,name,icon,sort_order) VALUES (%s,%s,%s,%s)", cats)

    # ========== 3. 商品（33个，详细描述+真实图片） ==========
    # (id, name, desc, price, orig, img_keyword, cat, rating, sales, stock)
    products = [
        # === 手机数码 ===
        ('p1','AirPods Pro 2代',
         'Apple AirPods Pro 第二代，搭载H2芯片，支持主动降噪与自适应通透模式。个性化空间音频带来沉浸式听感，MagSafe充电盒续航可达30小时。IPX4防水，适合运动佩戴。',
         1599,1999,'wireless+earbuds','cat_1',4.8,12580,100),

        ('p2','小米手环8 Pro',
         '1.74英寸AMOLED大屏，支持心率、血氧、睡眠全天候监测。内置GPS独立定位，150+运动模式，50米防水。典型续航14天，重度使用也能撑一周。',
         349,399,'fitness+tracker','cat_1',4.6,8920,200),

        ('p3','iPhone 15 硅胶保护壳',
         'Apple官方设计，液态硅胶材质，手感细腻亲肤。精准开孔，支持MagSafe无线充电。内衬超细纤维保护机身，多色可选。',
         89,129,'phone+case','cat_1',4.7,15600,500),

        ('p4','倍思磁吸无线充电宝',
         '10000mAh大容量，支持MagSafe磁吸+有线双充。20W PD快充，30分钟可充50%。LED电量指示，轻薄便携仅180g，可带上飞机。',
         169,199,'power+bank','cat_1',4.5,7800,300),

        ('p5','漫步者LolliPods Pro蓝牙耳机',
         '主动降噪深度-38dB，6mm复合振膜单元。蓝牙5.3低延迟，游戏模式延迟低至80ms。单次续航6小时，配合充电盒总续航24小时。IP54防水防汗。',
         259,329,'bluetooth+earphone','cat_1',4.4,5600,150),

        # === 服饰内衣 ===
        ('p6','纯棉圆领T恤 男款',
         '100%新疆长绒棉，240g加厚面料不透不变形。活性印染不褪色，预缩处理不缩水。经典百搭版型，四季可穿，多色多尺码可选。',
         79,129,'cotton+tshirt','cat_2',4.5,15600,500),

        ('p7','女士纯棉抗菌内裤3条装',
         'A类婴儿级纯棉面料，AAA级抗菌抑菌。中腰设计不夹臀，无痕剪裁不勒痕。独立包装更卫生，建议3个月更换一次。',
         49,79,'cotton+underwear','cat_2',4.8,28900,1000),

        ('p8','加绒加厚保暖内衣套装',
         '德绒自发热纤维，3秒速热锁温。双面磨绒亲肤不起球，弹力贴身不臃肿。V领设计可内搭衬衫，保暖不闷汗。',
         99,159,'thermal+underwear','cat_2',4.6,9800,400),

        # === 食品生鲜 ===
        ('p9','赣南脐橙5斤装',
         '江西赣州原产地直发，树上自然成熟。果肉饱满多汁，甜度高达13°。富含维生素C，皮薄易剥，老人小孩都爱吃。坏果包赔。',
         29.9,39.9,'orange+fruit','cat_3',4.7,32800,2000),

        ('p10','五常稻花香大米10斤',
         '黑龙江五常核心产区，当季新米真空包装。颗粒饱满晶莹，煮饭香气四溢。口感软糯弹牙，冷饭不回生。GB/T 19266标准。',
         59.9,89,'rice+grain','cat_3',4.9,45600,3000),

        ('p11','农家散养土鸡蛋30枚',
         '林下散养300天以上母鸡所产，蛋黄金黄饱满。无抗生素无激素，通过绿色食品认证。每枚约50g，破损包赔。',
         39.9,59,'eggs+farm','cat_3',4.6,21300,800),

        ('p12','智利进口JJ级车厘子2斤',
         '智利原装进口，JJ级大果（30-32mm）。果径均匀，色泽深红发亮。果肉紧实脆甜，果汁充沛。冷链直达，新鲜保障。',
         89,129,'cherry+fruit','cat_3',4.8,18900,500),

        ('p13','伊利金典纯牛奶24盒整箱',
         '伊利金典系列，3.8g优质乳蛋白。有机牧场奶源，通过中国+欧盟双重有机认证。200ml小盒装，早晚各一盒刚刚好。',
         69,89,'milk+dairy','cat_3',4.7,34200,2000),

        # === 美妆护肤 ===
        ('p14','玻尿酸补水面膜10片装',
         '三重玻尿酸分子，深层补水锁水。烟酰胺+积雪草精华，提亮肤色修护屏障。天丝膜布服帖透气，敏感肌可用。',
         49,89,'face+mask+skincare','cat_4',4.6,28900,1500),

        ('p15','兰蔻小黑瓶精华肌底液30ml',
         '兰蔻明星产品，二裂酵母精华。改善肤质粗糙、暗沉、细纹。蛋清质地好吸收，后续护肤品吸收力提升3倍。适合所有肤质。',
         599,799,'serum+skincare','cat_4',4.9,8900,200),

        ('p16','安耐晒金瓶防晒霜SPF50+ 50ml',
         '日本资生堂旗下，SPF50+ PA++++超高倍防晒。防水防汗耐摩擦，户外运动必备。添加美肌精华，防晒同时养肤。清爽不油腻。',
         89,129,'sunscreen+skincare','cat_4',4.7,17600,600),

        ('p17','芙丽芳丝氨基酸洗面奶120g',
         '日本进口，6种和汉植物精华。氨基酸表活温和不刺激，泡沫绵密洗后不紧绷。无香料无色素无酒精，敏感肌首选。',
         69,99,'cleanser+face','cat_4',4.5,23400,800),

        # === 家居日用 ===
        ('p18','维达超韧抽纸3层30包整箱',
         '维达明星产品，3层加厚超韧湿水不易破。100%原生木浆，不含荧光增白剂。每包100抽，家庭囤货装。M号适中尺寸，擦手擦脸都合适。',
         39.9,59.9,'tissue+paper','cat_5',4.5,52000,3000),

        ('p19','蓝月亮洗衣液4斤装',
         '深层洁净因子，瓦解顽固污渍。薰衣草精油香氛，留香持久72小时。低泡易漂洗，呵护衣物纤维。机洗手洗通用。',
         49.9,79,'laundry+detergent','cat_5',4.6,38900,2500),

        ('p20','苏泊尔不锈钢炒锅30cm',
         '304食品级不锈钢，五层复合锅底导热均匀。蜂窝不粘技术，少油烟不粘锅。可视玻璃锅盖，人体工学手柄。适用所有灶具含电磁炉。',
         159,259,'cookware+pan','cat_5',4.7,12300,300),

        ('p21','飞利浦声波电动牙刷',
         '31000次/分钟高频振动，3种清洁模式。2分钟智能计时+30秒换区提醒。IPX7全身防水，续航30天。配2支杜邦刷头。',
         129,199,'electric+toothbrush','cat_5',4.6,9800,400),

        ('p22','落地折叠晾衣架',
         '加粗不锈钢管材，承重可达30kg。可伸缩设计展开长1.5m，折叠后仅5cm。带防风夹和晾袜架，阳台室内两用。',
         79,129,'drying+rack','cat_5',4.5,6700,200),

        # === 电脑办公 ===
        ('p23','罗技M750无线鼠标',
         '人体工学设计，静音点击不扰人。MagSpeed电磁滚轮，精准+疾速双模式。蓝牙+2.4G双连接，支持3台设备切换。续航24个月。',
         89,129,'wireless+mouse','cat_6',4.7,15600,600),

        ('p24','RK987机械键盘 87键',
         'Cherry MX轴体可选（青轴/红轴/茶轴）。PBT双色注塑键帽不打油不褪色。白色背光+多种灯效。全键无冲，Type-C可拆卸线材。',
         199,299,'mechanical+keyboard','cat_6',4.6,8900,300),

        ('p25','绿联Type-C六合一扩展坞',
         'HDMI 4K@30Hz+USB3.0×3+SD/TF卡槽+PD100W充电。铝合金外壳散热好，即插即免驱。兼容MacBook/联想/华为等主流笔记本。',
         149,229,'usb+hub+dock','cat_6',4.5,5600,200),

        ('p26','明基ScreenBar Plus屏幕挂灯',
         '非对称光学设计，只照桌面不照屏幕，0屏幕反光。环境光自动调节，色温亮度无极调节。USB供电不占桌面空间。',
         99,169,'desk+led+light','cat_6',4.6,7800,350),

        # === 鞋靴箱包 ===
        ('p27','回力经典低帮帆布鞋',
         '国货经典品牌，硫化工艺鞋底耐磨防滑。纯棉帆布鞋面透气舒适，经典百搭款式。建议选大半码，男女同款多色可选。',
         79,129,'canvas+shoes','cat_7',4.5,23400,600),

        ('p28','小米极简都市双肩包15.6寸',
         '防泼水面料，多层收纳分区。独立笔电隔层适配15.6英寸笔记本。隐藏式防盗拉链，背部拉杆带。轻量化设计仅680g。',
         119,199,'laptop+backpack','cat_7',4.7,11200,400),

        ('p29','90分20寸登机箱',
         '德国拜耳PC箱体，轻韧抗压。360°万向静音飞机轮，拉杆四档可调。TSA海关密码锁，内部分区收纳。符合登机尺寸。',
         199,349,'travel+suitcase','cat_7',4.6,8900,250),

        # === 运动户外 ===
        ('p30','Keep加厚防滑瑜伽垫6mm',
         'TPE环保材质，双面防滑纹路。高密度回弹不塌陷，隔音减震。送收纳绑带+网袋，方便携带。多色可选。',
         49,89,'yoga+mat','cat_8',4.7,17600,800),

        ('p31','富光大容量运动水壶600ml',
         'Tritan材质不含BPA，安全无异味。一键弹盖单手开合，防漏锁扣。容量刻度线，提醒饮水。硅胶提手便携。',
         39,69,'water+bottle+sport','cat_8',4.5,12300,600),

        ('p32','尤尼克斯碳素羽毛球拍套装',
         '全碳素拍框，轻量高弹。攻守兼备均衡拍型，适合初中级选手。含球拍2支+羽毛球3个+拍包一个，到手即打。',
         149,259,'badminton+racket','cat_8',4.6,7800,300),

        ('p33','跑步专业运动袜3双装',
         '毛巾底加厚缓冲，减少足底冲击。网眼透气排汗，银离子抗菌除臭。Y型跟设计不滑跟，3D包裹贴合足型。',
         29.9,49,'sports+socks','cat_8',4.5,19800,1000),
    ]

    for i, p in enumerate(products):
        img = f'https://source.unsplash.com/400x400/?{p[5]}'
        cur.execute(
            "INSERT INTO products (id,name,description,price,original_price,image,category_id,rating,sales,stock) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",
            (p[0], p[1], p[2], p[3], p[4], img, p[6], p[7], p[8], p[9])
        )
        cur.execute("INSERT INTO product_images (product_id,image_url,sort_order) VALUES (%s,%s,0)", (p[0], img))

    # ========== 4. SKU ==========
    skus = [
        ('sku1_1','p1','颜色','白色',1599,100),('sku1_2','p1','颜色','黑色',1599,100),
        ('sku3_1','p3','颜色','午夜蓝',89,500),('sku3_2','p3','颜色','碳黑色',89,500),('sku3_3','p3','颜色','星光色',89,500),
        ('sku5_1','p5','颜色','星空灰',259,150),('sku5_2','p5','颜色','珊瑚粉',259,150),
        ('sku6_1','p6','尺码','S',79,500),('sku6_2','p6','尺码','M',79,500),('sku6_3','p6','尺码','L',79,500),('sku6_4','p6','尺码','XL',79,500),
        ('sku7_1','p7','尺码','M',49,1000),('sku7_2','p7','尺码','L',49,1000),('sku7_3','p7','尺码','XL',49,1000),
        ('sku8_1','p8','尺码','M',99,400),('sku8_2','p8','尺码','L',99,400),('sku8_3','p8','尺码','XL',99,400),
        ('sku21_1','p21','颜色','白色',129,400),('sku21_2','p21','颜色','粉色',129,400),
        ('sku24_1','p24','轴体','青轴',199,300),('sku24_2','p24','轴体','红轴',199,300),
        ('sku27_1','p27','尺码','38',79,600),('sku27_2','p27','尺码','39',79,600),('sku27_3','p27','尺码','40',79,600),('sku27_4','p27','尺码','41',79,600),('sku27_5','p27','尺码','42',79,600),
        ('sku28_1','p28','颜色','黑色',119,400),('sku28_2','p28','颜色','灰色',119,400),('sku28_3','p28','颜色','蓝色',119,400),
        ('sku29_1','p29','颜色','银色',199,250),('sku29_2','p29','颜色','黑色',199,250),
        ('sku30_1','p30','颜色','粉色',49,800),('sku30_2','p30','颜色','紫色',49,800),('sku30_3','p30','颜色','绿色',49,800),
        ('sku33_1','p33','尺码','39-42',29.9,1000),('sku33_2','p33','尺码','43-46',29.9,1000),
    ]
    cur.executemany("INSERT INTO product_skus (id,product_id,spec_name,spec_value,price,stock) VALUES (%s,%s,%s,%s,%s,%s)", skus)

    # ========== 5. 优惠券 ==========
    coupons = [
        ('coupon_001','新用户专享','满100减20',100,20,'fixed',
         (now-timedelta(days=30)).strftime('%Y-%m-%d %H:%M:%S'),
         (now+timedelta(days=30)).strftime('%Y-%m-%d %H:%M:%S')),
        ('coupon_002','全场9折券','无门槛9折',0,10,'percent',
         (now-timedelta(days=30)).strftime('%Y-%m-%d %H:%M:%S'),
         (now+timedelta(days=30)).strftime('%Y-%m-%d %H:%M:%S')),
        ('coupon_003','满299减50','满299可用',299,50,'fixed',
         (now-timedelta(days=30)).strftime('%Y-%m-%d %H:%M:%S'),
         (now+timedelta(days=30)).strftime('%Y-%m-%d %H:%M:%S')),
    ]
    cur.executemany("INSERT INTO coupons (id,name,description,threshold,discount,type,start_time,end_time) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)", coupons)

    conn.commit()
    cur.close()
    conn.close()
    print("✅ 种子数据 v2 导入完成！")
    print(f"   - 用户: 2  |  分类: {len(cats)}  |  商品: {len(products)}")
    print(f"   - SKU: {len(skus)}  |  优惠券: {len(coupons)}")
    print(f"   - 所有商品描述已升级为详细文案")
    print(f"   - 所有商品图片已替换为 Unsplash 真实图片")

if __name__ == '__main__':
    seed()
