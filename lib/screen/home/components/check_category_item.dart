import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/models/book.dart';
import 'package:ebook_application/providers/list_categories_chosen.dart';

class CheckCategoryItem extends ConsumerStatefulWidget {
  const CheckCategoryItem({super.key, required this.category});

  final Category category;

  @override
  ConsumerState<CheckCategoryItem> createState() => _CheckCategoryItemState();
}

class _CheckCategoryItemState extends ConsumerState<CheckCategoryItem> {
  @override
  Widget build(BuildContext context) {
    final listCategoryChosenNotifier =
        ref.watch(categoriesChosenNotifierProvider.notifier);
    bool isChecked =
        ref.watch(categoriesChosenNotifierProvider).contains(widget.category);

    return CheckboxListTile(
      contentPadding: const EdgeInsets.only(left: 30, right: 25),
      title: Text(
        widget.category.specificName,
        style: TextStyle(
          fontSize: 20,
          fontWeight: isChecked ? FontWeight.bold : null,
        ),
      ),
      value: isChecked,
      onChanged: (newVal) {
        setState(() {
          isChecked = newVal!;
        });

        if (newVal!) {
          listCategoryChosenNotifier.add(widget.category);
        } else {
          listCategoryChosenNotifier.remove(widget.category);
        }
      },
      activeColor: Colors.blueAccent,
      fillColor: const MaterialStatePropertyAll(Colors.black),
    );
  }
}
