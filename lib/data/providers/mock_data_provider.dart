import '../models/product.dart';
import '../models/cart.dart';
import '../models/order.dart';

class MockDataProvider {
  MockDataProvider._();

  // v1.1: 获取 Mock 降级数据（网络异常时的兜底）
  // v1.3: 返回格式与真实 API 一致
  static dynamic getFallback(String path) {
    if (path.contains('/cart')) {
      return {'items': [], 'total': 0};
    }
    if (path.contains('/orders')) {
      return {'items': []};
    }
    if (path.contains('/products') && !path.contains('/products/p')) {
      return {
        'total': products.length,
        'page': 1,
        'size': 100,
        'items': products.map((p) => p.toJson()).toList(),
      };
    }
    if (path.contains('/categories')) {
      return categories
          .map((c) => {'id': c.id, 'name': c.name, 'icon': c.icon})
          .toList();
    }
    return null;
  }

  // ========== 商品分类 ==========
  static final List<Category> categories = [
    Category(id: 'cat_1', name: '手机数码', icon: '📱'),
    Category(id: 'cat_2', name: '服饰内衣', icon: '👕'),
    Category(id: 'cat_3', name: '食品生鲜', icon: '🍎'),
    Category(id: 'cat_4', name: '美妆护肤', icon: '💄'),
    Category(id: 'cat_5', name: '家居日用', icon: '🏠'),
    Category(id: 'cat_6', name: '电脑办公', icon: '💻'),
    Category(id: 'cat_7', name: '鞋靴箱包', icon: '👟'),
    Category(id: 'cat_8', name: '运动户外', icon: '⚽'),
  ];

  // ========== 商品列表（33个，详细描述+真实图片） ==========
  static final List<Product> products = [
    // 手机数码 cat_1
    _mkProduct(
        id: 'p1',
        name: 'AirPods Pro 2代',
        desc:
            'Apple AirPods Pro 第二代，搭载H2芯片，支持主动降噪与自适应通透模式。个性化空间音频带来沉浸式听感，MagSafe充电盒续航可达30小时。',
        price: 1599,
        orig: 1999,
        img: 'https://images.unsplash.com/photo-1590658268037-6bf12f032f55?w=400&h=400&fit=crop',
        cat: 'cat_1',
        rating: 4.8,
        sales: 12580,
        stock: 100,
        skus: [_mkSku('sku1_1', '颜色', '白色'), _mkSku('sku1_2', '颜色', '黑色')]),
    _mkProduct(
        id: 'p2',
        name: '小米手环8 Pro',
        desc: '1.74英寸AMOLED大屏，支持心率、血氧、睡眠全天候监测。内置GPS独立定位，150+运动模式，50米防水。续航14天。',
        price: 349,
        orig: 399,
        img:
            'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=400&h=400&fit=crop',
        cat: 'cat_1',
        rating: 4.6,
        sales: 8920,
        stock: 200,
        skus: []),
    _mkProduct(
        id: 'p3',
        name: 'iPhone 15 硅胶保护壳',
        desc: 'Apple官方设计，液态硅胶材质，手感细腻亲肤。精准开孔，支持MagSafe无线充电。内衬超细纤维保护机身。',
        price: 89,
        orig: 129,
        img:
            'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=400&h=400&fit=crop',
        cat: 'cat_1',
        rating: 4.7,
        sales: 15600,
        stock: 500,
        skus: [
          _mkSku('sku3_1', '颜色', '午夜蓝'),
          _mkSku('sku3_2', '颜色', '碳黑色'),
          _mkSku('sku3_3', '颜色', '星光色')
        ]),
    _mkProduct(
        id: 'p4',
        name: '倍思磁吸无线充电宝',
        desc:
            '10000mAh大容量，支持MagSafe磁吸+有线双充。20W PD快充，30分钟可充50%。轻薄便携仅180g，可带上飞机。',
        price: 169,
        orig: 199,
        img:
            'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400&h=400&fit=crop',
        cat: 'cat_1',
        rating: 4.5,
        sales: 7800,
        stock: 300,
        skus: []),
    _mkProduct(
        id: 'p5',
        name: '漫步者蓝牙耳机',
        desc: '主动降噪深度-38dB，6mm复合振膜单元。蓝牙5.3低延迟，游戏模式延迟低至80ms。单次续航6小时，IP54防水防汗。',
        price: 259,
        orig: 329,
        img:
            'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400&h=400&fit=crop',
        cat: 'cat_1',
        rating: 4.4,
        sales: 5600,
        stock: 150,
        skus: [_mkSku('sku5_1', '颜色', '星空灰'), _mkSku('sku5_2', '颜色', '珊瑚粉')]),
    // 服饰内衣 cat_2
    _mkProduct(
        id: 'p6',
        name: '纯棉圆领T恤 男款',
        desc: '100%新疆长绒棉，240g加厚面料不透不变形。活性印染不褪色，预缩处理不缩水。经典百搭版型，四季可穿。',
        price: 79,
        orig: 129,
        img:
            'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
        cat: 'cat_2',
        rating: 4.5,
        sales: 15600,
        stock: 500,
        skus: [
          _mkSku('sku6_1', '尺码', 'S'),
          _mkSku('sku6_2', '尺码', 'M'),
          _mkSku('sku6_3', '尺码', 'L'),
          _mkSku('sku6_4', '尺码', 'XL')
        ]),
    _mkProduct(
        id: 'p7',
        name: '女士纯棉内裤3条装',
        desc: 'A类婴儿级纯棉面料，AAA级抗菌抑菌。中腰设计不夹臀，无痕剪裁不勒痕。独立包装更卫生。',
        price: 49,
        orig: 79,
        img:
            'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=400&h=400&fit=crop',
        cat: 'cat_2',
        rating: 4.8,
        sales: 28900,
        stock: 1000,
        skus: [
          _mkSku('sku7_1', '尺码', 'M'),
          _mkSku('sku7_2', '尺码', 'L'),
          _mkSku('sku7_3', '尺码', 'XL')
        ]),
    _mkProduct(
        id: 'p8',
        name: '保暖内衣套装',
        desc: '德绒自发热纤维，3秒速热锁温。双面磨绒亲肤不起球，弹力贴身不臃肿。V领设计可内搭衬衫。',
        price: 99,
        orig: 159,
        img:
            'https://images.unsplash.com/photo-1543076659-9380cdf10613?w=400&h=400&fit=crop',
        cat: 'cat_2',
        rating: 4.6,
        sales: 9800,
        stock: 400,
        skus: [
          _mkSku('sku8_1', '尺码', 'M'),
          _mkSku('sku8_2', '尺码', 'L'),
          _mkSku('sku8_3', '尺码', 'XL')
        ]),
    // 食品生鲜 cat_3
    _mkProduct(
        id: 'p9',
        name: '赣南脐橙5斤装',
        desc: '江西赣州原产地直发，树上自然成熟。果肉饱满多汁，甜度高达13°。富含维生素C，皮薄易剥。坏果包赔。',
        price: 29.9,
        orig: 39.9,
        img:
            'https://images.unsplash.com/photo-1547514701-42782101795e?w=400&h=400&fit=crop',
        cat: 'cat_3',
        rating: 4.7,
        sales: 32800,
        stock: 2000,
        skus: []),
    _mkProduct(
        id: 'p10',
        name: '五常稻花香大米10斤',
        desc: '黑龙江五常核心产区，当季新米真空包装。颗粒饱满晶莹，煮饭香气四溢。口感软糯弹牙，冷饭不回生。',
        price: 59.9,
        orig: 89,
        img:
            'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop',
        cat: 'cat_3',
        rating: 4.9,
        sales: 45600,
        stock: 3000,
        skus: []),
    _mkProduct(
        id: 'p11',
        name: '土鸡蛋30枚',
        desc: '林下散养300天以上母鸡所产，蛋黄金黄饱满。无抗生素无激素，通过绿色食品认证。每枚约50g，破损包赔。',
        price: 39.9,
        orig: 59,
        img:
            'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&h=400&fit=crop',
        cat: 'cat_3',
        rating: 4.6,
        sales: 21300,
        stock: 800,
        skus: []),
    _mkProduct(
        id: 'p12',
        name: '进口车厘子2斤',
        desc: '智利原装进口，JJ级大果（30-32mm）。果径均匀，色泽深红发亮。果肉紧实脆甜，果汁充沛。冷链直达。',
        price: 89,
        orig: 129,
        img:
            'https://images.unsplash.com/photo-1528821128474-27f963b062bf?w=400&h=400&fit=crop',
        cat: 'cat_3',
        rating: 4.8,
        sales: 18900,
        stock: 500,
        skus: []),
    _mkProduct(
        id: 'p13',
        name: '纯牛奶24盒整箱',
        desc: '伊利金典系列，3.8g优质乳蛋白。有机牧场奶源，通过中国+欧盟双重有机认证。200ml小盒装。',
        price: 69,
        orig: 89,
        img:
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400&h=400&fit=crop',
        cat: 'cat_3',
        rating: 4.7,
        sales: 34200,
        stock: 2000,
        skus: []),
    // 美妆护肤 cat_4
    _mkProduct(
        id: 'p14',
        name: '玻尿酸面膜10片',
        desc: '三重玻尿酸分子，深层补水锁水。烟酰胺+积雪草精华，提亮肤色修护屏障。天丝膜布服帖透气，敏感肌可用。',
        price: 49,
        orig: 89,
        img:
            'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=400&h=400&fit=crop',
        cat: 'cat_4',
        rating: 4.6,
        sales: 28900,
        stock: 1500,
        skus: []),
    _mkProduct(
        id: 'p15',
        name: '兰蔻小黑瓶精华30ml',
        desc: '兰蔻明星产品，二裂酵母精华。改善肤质粗糙、暗沉、细纹。蛋清质地好吸收，适合所有肤质。',
        price: 599,
        orig: 799,
        img:
            'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=400&h=400&fit=crop',
        cat: 'cat_4',
        rating: 4.9,
        sales: 8900,
        stock: 200,
        skus: []),
    _mkProduct(
        id: 'p16',
        name: '防晒霜SPF50+ 50ml',
        desc: '日本资生堂旗下，SPF50+ PA++++超高倍防晒。防水防汗耐摩擦，户外运动必备。清爽不油腻。',
        price: 89,
        orig: 129,
        img:
            'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400&h=400&fit=crop',
        cat: 'cat_4',
        rating: 4.7,
        sales: 17600,
        stock: 600,
        skus: []),
    _mkProduct(
        id: 'p17',
        name: '氨基酸洗面奶120g',
        desc: '日本进口，6种和汉植物精华。氨基酸表活温和不刺激，泡沫绵密洗后不紧绷。敏感肌首选。',
        price: 69,
        orig: 99,
        img:
            'https://images.unsplash.com/photo-1556227834-09f1de7a7d14?w=400&h=400&fit=crop',
        cat: 'cat_4',
        rating: 4.5,
        sales: 23400,
        stock: 800,
        skus: []),
    // 家居日用 cat_5
    _mkProduct(
        id: 'p18',
        name: '抽纸3层30包整箱',
        desc: '维达明星产品，3层加厚超韧湿水不易破。100%原生木浆，不含荧光增白剂。每包100抽，家庭囤货装。',
        price: 39.9,
        orig: 59.9,
        img:
            'https://images.unsplash.com/photo-1563453392212-326f5e854473?w=400&h=400&fit=crop',
        cat: 'cat_5',
        rating: 4.5,
        sales: 52000,
        stock: 3000,
        skus: []),
    _mkProduct(
        id: 'p19',
        name: '洗衣液4斤装',
        desc: '深层洁净因子，瓦解顽固污渍。薰衣草精油香氛，留香持久72小时。低泡易漂洗，机洗手洗通用。',
        price: 49.9,
        orig: 79,
        img:
            'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=400&h=400&fit=crop',
        cat: 'cat_5',
        rating: 4.6,
        sales: 38900,
        stock: 2500,
        skus: []),
    _mkProduct(
        id: 'p20',
        name: '不锈钢炒锅30cm',
        desc: '304食品级不锈钢，五层复合锅底导热均匀。蜂窝不粘技术，少油烟不粘锅。适用所有灶具含电磁炉。',
        price: 159,
        orig: 259,
        img:
            'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=400&fit=crop',
        cat: 'cat_5',
        rating: 4.7,
        sales: 12300,
        stock: 300,
        skus: []),
    _mkProduct(
        id: 'p21',
        name: '电动牙刷成人款',
        desc: '31000次/分钟高频振动，3种清洁模式。2分钟智能计时+30秒换区提醒。IPX7全身防水，续航30天。',
        price: 129,
        orig: 199,
        img:
            'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400&h=400&fit=crop',
        cat: 'cat_5',
        rating: 4.6,
        sales: 9800,
        stock: 400,
        skus: [_mkSku('sku21_1', '颜色', '白色'), _mkSku('sku21_2', '颜色', '粉色')]),
    _mkProduct(
        id: 'p22',
        name: '落地晾衣架',
        desc: '加粗不锈钢管材，承重可达30kg。可伸缩设计展开长1.5m，折叠后仅5cm。带防风夹和晾袜架。',
        price: 79,
        orig: 129,
        img:
            'https://images.unsplash.com/photo-1584622656313-56d5d6937c86?w=400&h=400&fit=crop',
        cat: 'cat_5',
        rating: 4.5,
        sales: 6700,
        stock: 200,
        skus: []),
    // 电脑办公 cat_6
    _mkProduct(
        id: 'p23',
        name: '罗技无线鼠标',
        desc: '人体工学设计，静音点击不扰人。MagSpeed电磁滚轮，蓝牙+2.4G双连接，支持3台设备切换。续航24个月。',
        price: 89,
        orig: 129,
        img:
            'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400&h=400&fit=crop',
        cat: 'cat_6',
        rating: 4.7,
        sales: 15600,
        stock: 600,
        skus: []),
    _mkProduct(
        id: 'p24',
        name: '机械键盘青轴',
        desc: 'Cherry MX轴体，PBT双色注塑键帽不打油。白色背光+多种灯效。全键无冲，Type-C可拆卸线材。',
        price: 199,
        orig: 299,
        img:
            'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=400&h=400&fit=crop',
        cat: 'cat_6',
        rating: 4.6,
        sales: 8900,
        stock: 300,
        skus: [_mkSku('sku24_1', '轴体', '青轴'), _mkSku('sku24_2', '轴体', '红轴')]),
    _mkProduct(
        id: 'p25',
        name: 'USB-C扩展坞',
        desc: 'HDMI 4K@30Hz+USB3.0x3+SD/TF卡槽+PD100W充电。铝合金外壳散热好，兼容主流笔记本。',
        price: 149,
        orig: 229,
        img:
            'https://images.unsplash.com/photo-1625842268584-8f3296236761?w=400&h=400&fit=crop',
        cat: 'cat_6',
        rating: 4.5,
        sales: 5600,
        stock: 200,
        skus: []),
    _mkProduct(
        id: 'p26',
        name: '显示器屏幕挂灯',
        desc: '非对称光学设计，只照桌面不照屏幕。环境光自动调节，色温亮度无极调节。USB供电不占桌面空间。',
        price: 99,
        orig: 169,
        img:
            'https://images.unsplash.com/photo-1507473885765-e6ed057ab3fe?w=400&h=400&fit=crop',
        cat: 'cat_6',
        rating: 4.6,
        sales: 7800,
        stock: 350,
        skus: []),
    // 鞋靴箱包 cat_7
    _mkProduct(
        id: 'p27',
        name: '回力休闲鞋',
        desc: '国货经典品牌，硫化工艺鞋底耐磨防滑。纯棉帆布鞋面透气舒适，经典百搭款式。建议选大半码。',
        price: 79,
        orig: 129,
        img:
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop',
        cat: 'cat_7',
        rating: 4.5,
        sales: 23400,
        stock: 600,
        skus: [
          _mkSku('sku27_1', '尺码', '38'),
          _mkSku('sku27_2', '尺码', '39'),
          _mkSku('sku27_3', '尺码', '40'),
          _mkSku('sku27_4', '尺码', '41'),
          _mkSku('sku27_5', '尺码', '42')
        ]),
    _mkProduct(
        id: 'p28',
        name: '双肩背包15.6寸',
        desc: '防泼水面料，多层收纳分区。独立笔电隔层适配15.6英寸笔记本。隐藏式防盗拉链，轻量化设计仅680g。',
        price: 119,
        orig: 199,
        img:
            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop',
        cat: 'cat_7',
        rating: 4.7,
        sales: 11200,
        stock: 400,
        skus: [
          _mkSku('sku28_1', '颜色', '黑色'),
          _mkSku('sku28_2', '颜色', '灰色'),
          _mkSku('sku28_3', '颜色', '蓝色')
        ]),
    _mkProduct(
        id: 'p29',
        name: '行李箱20寸',
        desc: '德国拜耳PC箱体，轻韧抗压。360度万向静音飞机轮，TSA海关密码锁。符合登机尺寸。',
        price: 199,
        orig: 349,
        img:
            'https://images.unsplash.com/photo-1565026057447-bc90a3dceb87?w=400&h=400&fit=crop',
        cat: 'cat_7',
        rating: 4.6,
        sales: 8900,
        stock: 250,
        skus: [_mkSku('sku29_1', '颜色', '银色'), _mkSku('sku29_2', '颜色', '黑色')]),
    // 运动户外 cat_8
    _mkProduct(
        id: 'p30',
        name: '瑜伽垫加厚6mm',
        desc: 'TPE环保材质，双面防滑纹路。高密度回弹不塌陷，隔音减震。送收纳绑带+网袋，方便携带。',
        price: 49,
        orig: 89,
        img:
            'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=400&h=400&fit=crop',
        cat: 'cat_8',
        rating: 4.7,
        sales: 17600,
        stock: 800,
        skus: [
          _mkSku('sku30_1', '颜色', '粉色'),
          _mkSku('sku30_2', '颜色', '紫色'),
          _mkSku('sku30_3', '颜色', '绿色')
        ]),
    _mkProduct(
        id: 'p31',
        name: '运动水壶600ml',
        desc: 'Tritan材质不含BPA，安全无异味。一键弹盖单手开合，防漏锁扣。容量刻度线，提醒饮水。',
        price: 39,
        orig: 69,
        img:
            'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400&h=400&fit=crop',
        cat: 'cat_8',
        rating: 4.5,
        sales: 12300,
        stock: 600,
        skus: []),
    _mkProduct(
        id: 'p32',
        name: '羽毛球拍套装',
        desc: '全碳素拍框，轻量高弹。攻守兼备均衡拍型，适合初中级选手。含球拍2支+羽毛球3个+拍包一个。',
        price: 149,
        orig: 259,
        img:
            'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=400&h=400&fit=crop',
        cat: 'cat_8',
        rating: 4.6,
        sales: 7800,
        stock: 300,
        skus: []),
    _mkProduct(
        id: 'p33',
        name: '跑步运动袜3双',
        desc: '毛巾底加厚缓冲，减少足底冲击。网眼透气排汗，银离子抗菌除臭。Y型跟设计不滑跟。',
        price: 29.9,
        orig: 49,
        img:
            'https://images.unsplash.com/photo-1586350977771-b3b0abd50c82?w=400&h=400&fit=crop',
        cat: 'cat_8',
        rating: 4.5,
        sales: 19800,
        stock: 1000,
        skus: [
          _mkSku('sku33_1', '尺码', '39-42'),
          _mkSku('sku33_2', '尺码', '43-46')
        ]),
  ];

  static Product _mkProduct(
      {required String id,
      required String name,
      required String desc,
      required double price,
      required double orig,
      required String img,
      required String cat,
      required double rating,
      required int sales,
      required int stock,
      required List<ProductSku> skus,
      String tags = ''}) {
    // 自动填充 SKU 价格和库存（与商品保持一致）
    final fixedSkus = skus
        .map((sku) => ProductSku(
              id: sku.id,
              specName: sku.specName,
              specValue: sku.specValue,
              price: sku.price == 0 ? price : sku.price,
              stock: sku.stock == 0 ? stock : sku.stock,
            ))
        .toList();
    return Product(
      id: id,
      name: name,
      description: desc,
      price: price,
      originalPrice: orig,
      image: img,
      images: [img],
      category: cat,
      rating: rating,
      sales: sales,
      stock: stock,
      skus: fixedSkus,
      reviews: [],
      tags: tags,
    );
  }

  static ProductSku _mkSku(String id, String specName, String specValue,
      [double price = 0, int stock = 0]) {
    return ProductSku(
        id: id,
        specName: specName,
        specValue: specValue,
        price: price,
        stock: stock);
  }

  // ========== 预置订单（各状态） ==========
  static List<Order> getMockOrders() {
    if (products.isEmpty) return [];
    return [
      Order(
        id: 'order_001',
        orderNo: 'DD20260510001',
        items: [
          CartItem(
              id: 'ci01',
              product: products[0],
              sku: products[0].skus[0],
              quantity: 1,
              addTime: DateTime.now().subtract(const Duration(days: 3))),
        ],
        totalAmount: 1599.00,
        freight: 0.00,
        discount: 80.00,
        status: OrderStatus.delivered,
        address: _defAddr(),
        payment: Payment(
            id: 'pay01',
            orderId: 'order_001',
            amount: 1519.00,
            payMethod: '支付宝',
            status: 'success'),
        logistics: Logistics(
          id: 'log01',
          company: '顺丰速运',
          trackingNo: 'SF1234567890',
          status: '已签收',
          nodes: [
            LogisticsNode(
                time: '2026-05-10 09:00',
                content: '已签收，签收人：本人',
                location: '济南市'),
            LogisticsNode(
                time: '2026-05-09 18:30',
                content: '快件已到达【济南分拨中心】',
                location: '济南'),
            LogisticsNode(
                time: '2026-05-09 12:00',
                content: '快件已发往【济南分拨中心】',
                location: '上海'),
            LogisticsNode(
                time: '2026-05-08 20:00', content: '顺丰小哥已取件', location: '上海'),
          ],
        ),
        createTime: DateTime.now().subtract(const Duration(days: 3)),
        payTime: DateTime.now().subtract(const Duration(days: 3)),
        shipTime: DateTime.now().subtract(const Duration(days: 2)),
        receiveTime: DateTime.now().subtract(const Duration(days: 1)),
        completeTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Order(
        id: 'order_002',
        orderNo: 'DD20260511001',
        items: [
          CartItem(
              id: 'ci02',
              product: products[8],
              quantity: 2,
              addTime: DateTime.now().subtract(const Duration(hours: 5))),
          CartItem(
              id: 'ci03',
              product: products[12],
              quantity: 1,
              addTime: DateTime.now().subtract(const Duration(hours: 5))),
        ],
        totalAmount: 98.90,
        freight: 5.00,
        discount: 10.00,
        status: OrderStatus.shipped,
        address: _defAddr(),
        payment: Payment(
            id: 'pay02',
            orderId: 'order_002',
            amount: 93.90,
            payMethod: '微信支付',
            status: 'success'),
        logistics: Logistics(
          id: 'log02',
          company: '中通快递',
          trackingNo: 'ZT9876543210',
          status: '运输中',
          nodes: [
            LogisticsNode(
                time: '2026-05-11 10:00',
                content: '快件已从【济南中转站】发出',
                location: '济南'),
            LogisticsNode(
                time: '2026-05-11 08:00',
                content: '快件已到达【济南中转站】',
                location: '济南'),
            LogisticsNode(
                time: '2026-05-10 20:00',
                content: '快件已发往【济南中转站】',
                location: '杭州'),
          ],
        ),
        createTime: DateTime.now().subtract(const Duration(hours: 5)),
        payTime: DateTime.now().subtract(const Duration(hours: 5)),
        shipTime: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Order(
        id: 'order_003',
        orderNo: 'DD20260511002',
        items: [
          CartItem(
              id: 'ci04',
              product: products[14],
              quantity: 1,
              addTime: DateTime.now().subtract(const Duration(minutes: 30))),
        ],
        totalAmount: 599.00,
        freight: 0.00,
        discount: 50.00,
        status: OrderStatus.paid,
        address: _defAddr(),
        payment: Payment(
            id: 'pay03',
            orderId: 'order_003',
            amount: 549.00,
            payMethod: '微信支付',
            status: 'success'),
        createTime: DateTime.now().subtract(const Duration(minutes: 30)),
        payTime: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Order(
        id: 'order_004',
        orderNo: 'DD20260511003',
        items: [
          CartItem(
              id: 'ci05',
              product: products[20],
              quantity: 1,
              addTime: DateTime.now().subtract(const Duration(minutes: 10))),
          CartItem(
              id: 'ci06',
              product: products[22],
              quantity: 1,
              addTime: DateTime.now().subtract(const Duration(minutes: 10))),
        ],
        totalAmount: 238.00,
        freight: 0.00,
        discount: 0.00,
        status: OrderStatus.pending,
        address: _defAddr(),
        payment: Payment(
            id: 'pay04',
            orderId: 'order_004',
            amount: 238.00,
            payMethod: '微信支付',
            status: 'pending'),
        createTime: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      Order(
        id: 'order_005',
        orderNo: 'DD20260508001',
        items: [
          CartItem(
              id: 'ci07',
              product: products[4],
              quantity: 1,
              addTime: DateTime.now().subtract(const Duration(days: 7))),
        ],
        totalAmount: 259.00,
        freight: 0.00,
        discount: 20.00,
        status: OrderStatus.completed,
        address: _defAddr(),
        payment: Payment(
            id: 'pay05',
            orderId: 'order_005',
            amount: 239.00,
            payMethod: '支付宝',
            status: 'success'),
        logistics: Logistics(
          id: 'log05',
          company: '圆通速递',
          trackingNo: 'YT5678901234',
          status: '已签收',
          nodes: [
            LogisticsNode(
                time: '2026-05-08 14:00',
                content: '已签收，签收人：本人',
                location: '济南市'),
          ],
        ),
        createTime: DateTime.now().subtract(const Duration(days: 7)),
        payTime: DateTime.now().subtract(const Duration(days: 7)),
        shipTime: DateTime.now().subtract(const Duration(days: 6)),
        receiveTime: DateTime.now().subtract(const Duration(days: 5)),
        completeTime: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  static Address _defAddr() => Address(
        id: 'addr_default',
        receiverName: '白噪音',
        phone: '13812345678',
        province: '山东省',
        city: '济南市',
        district: '历下区',
        detail: 'XX路XX号XX小区1号楼101',
        isDefault: true,
      );

  // ========== 预置地址列表 ==========
  static List<Address> getMockAddresses() => [
        _defAddr(),
        Address(
          id: 'addr_home',
          receiverName: '白噪音',
          phone: '13812345678',
          province: '山东省',
          city: '济南市',
          district: '市中区',
          detail: 'XX路XX号XX公寓A座1203',
          isDefault: false,
        ),
        Address(
          id: 'addr_school',
          receiverName: '白噪音',
          phone: '13812345678',
          province: '山东省',
          city: '青岛市',
          district: '崂山区',
          detail: 'XX大学XX校区XX宿舍楼301',
          isDefault: false,
        ),
      ];
}
