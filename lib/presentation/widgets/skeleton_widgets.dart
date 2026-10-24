import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

/// v1.2 骨架屏组件集 —— 用于数据加载时的占位展示

class SkeletonBlock extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets margin;

  const SkeletonBlock({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 4,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// 商品卡片骨架屏（模拟 ProductCard 布局）
class SkeletonProductCard extends StatelessWidget {
  const SkeletonProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片区域
          Expanded(
            flex: 3,
            child: SkeletonBlock(
              height: double.infinity,
              borderRadius: AppTheme.radiusLarge,
            ),
          ),
          // 信息区域
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBlock(height: 14, width: double.infinity),
                  SizedBox(height: 4),
                  SkeletonBlock(height: 14, width: 80),
                  Spacer(),
                  Row(
                    children: [
                      SkeletonBlock(height: 16, width: 60),
                      Spacer(),
                      SkeletonBlock(height: 12, width: 30),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SkeletonBlock(
                          height: 28,
                          borderRadius: AppTheme.radiusSmall,
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: SkeletonBlock(
                          height: 28,
                          borderRadius: AppTheme.radiusSmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 商品网格骨架屏
class SkeletonProductGrid extends StatelessWidget {
  final int itemCount;
  const SkeletonProductGrid({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => const SkeletonProductCard(),
    );
  }
}

/// Banner 骨架屏
class SkeletonBanner extends StatelessWidget {
  final double height;
  const SkeletonBanner({super.key, this.height = 180});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// 订单卡片骨架屏
class SkeletonOrderCard extends StatelessWidget {
  const SkeletonOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBlock(height: 12, width: 120),
              SkeletonBlock(height: 20, width: 60, borderRadius: 12),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              SkeletonBlock(height: 60, width: 60, borderRadius: 8),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBlock(height: 14, width: double.infinity),
                    SizedBox(height: 8),
                    SkeletonBlock(height: 12, width: 80),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SkeletonBlock(height: 14, width: 120),
            ],
          ),
        ],
      ),
    );
  }
}

/// 订单列表骨架屏
class SkeletonOrderList extends StatelessWidget {
  final int itemCount;
  const SkeletonOrderList({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: itemCount,
      itemBuilder: (_, __) => const SkeletonOrderCard(),
    );
  }
}
