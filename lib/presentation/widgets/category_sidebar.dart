import 'package:flutter/foundation.dart';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

/// 分类侧边栏数据项
class CategorySidebarItem {
  final String id;
  final String name;
  final String? icon;
  final List<CategorySidebarItem>? children;

  CategorySidebarItem({
    required this.id,
    required this.name,
    this.icon,
    this.children,
  });
}

class CategorySidebar extends StatelessWidget {
  final bool isOpen;
  final List<CategorySidebarItem> categories;
  final Function(CategorySidebarItem) onCategorySelected;
  final VoidCallback onClose;

  const CategorySidebar({
    super.key,
    required this.isOpen,
    required this.categories,
    required this.onCategorySelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOpen) return const SizedBox.shrink();

    return Stack(
      children: [
        // 遮罩层
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: _buildBackdrop(context),
          ),
        ),

        // 侧边栏本体
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          left: isOpen ? 0 : -280,
          top: 0,
          bottom: 0,
          width: 280,
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // 侧边栏头部
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: const Border(
                      bottom: BorderSide(color: AppTheme.dividerColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '商品分类',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                ),

                // 分类列表
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _CategoryTile(
                        category: category,
                        onTap: () => onCategorySelected(category),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// v1.1 新增：性能降级遮罩方案
  Widget _buildBackdrop(BuildContext context) {
    // Android 低版本（< Android 10）回退为纯色遮罩，避免模糊性能问题
    final isLowEndDevice = defaultTargetPlatform == TargetPlatform.android &&
        (MediaQuery.of(context).devicePixelRatio < 2.5);

    if (isLowEndDevice) {
      return Container(color: Colors.black.withOpacity(0.5));
    }

    // iOS / Android 10+ 使用高斯模糊
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(color: Colors.black.withOpacity(0.3)),
    );
  }
}

class _CategoryTile extends StatefulWidget {
  final CategorySidebarItem category;
  final VoidCallback onTap;

  const _CategoryTile({required this.category, required this.onTap});

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.category.children?.isNotEmpty ?? false;

    return Column(
      children: [
        ListTile(
          leading: Text(widget.category.icon ?? '',
              style: const TextStyle(fontSize: 20)),
          title: Text(widget.category.name),
          trailing: hasChildren
              ? Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                )
              : null,
          onTap: () {
            if (hasChildren) {
              setState(() => _isExpanded = !_isExpanded);
            } else {
              widget.onTap();
            }
          },
        ),
        // 二级分类
        if (hasChildren && _isExpanded)
          Container(
            color: Colors.grey[50],
            child: Column(
              children: widget.category.children!
                  .map((child) => ListTile(
                        contentPadding: const EdgeInsets.only(left: 48),
                        title: Text(child.name,
                            style: const TextStyle(fontSize: 14)),
                        onTap: () => widget.onTap(),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
