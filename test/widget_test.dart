import 'package:ecommerce_b2c/presentation/widgets/category_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Category selection updates when tapped', (tester) async {
    var selected = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => CategoryChip(
            label: '手机数码',
            isSelected: selected,
            onTap: () => setState(() => selected = !selected),
          ),
        ),
      ),
    ));
    expect(tester.widget<CategoryChip>(find.byType(CategoryChip)).isSelected,
        isFalse);
    await tester.tap(find.text('手机数码'));
    await tester.pump();
    expect(tester.widget<CategoryChip>(find.byType(CategoryChip)).isSelected,
        isTrue);
    await tester.tap(find.text('手机数码'));
    await tester.pump();
    expect(tester.widget<CategoryChip>(find.byType(CategoryChip)).isSelected,
        isFalse);
  });
}
