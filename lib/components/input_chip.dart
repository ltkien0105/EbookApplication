import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/models/book.dart';
import 'package:ebook_application/providers/list_categories_chosen.dart';
import 'package:ebook_application/providers/list_categories_displayed.dart';

class InputChipButton extends ConsumerStatefulWidget {
  const InputChipButton({
    super.key,
    required this.category,
  });

  final Category category;

  @override
  ConsumerState<InputChipButton> createState() => _InputChipButtonState();
}

class _InputChipButtonState extends ConsumerState<InputChipButton> {
  void addCategoryChosen(Category category) {
    ref.watch(categoriesChosenNotifierProvider.notifier).add(category);
  }

  void removeCategoryChosen(Category category) {
    ref.watch(categoriesChosenNotifierProvider.notifier).remove(category);
  }

  void removeCategoryDisplayed(Category category) {
    ref.watch(categoriesDisplayedNotifierProvider.notifier).remove(category);
    ref.watch(categoriesChosenNotifierProvider.notifier).remove(category);
  }

  @override
  Widget build(BuildContext context) {
    bool isSelected =
        ref.watch(categoriesChosenNotifierProvider).contains(widget.category);

    return InputChip(
      label: Text(widget.category.specificName),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      selected: isSelected,
      onSelected: (bool newValue) {
        setState(() {
          isSelected = newValue;
        });
        if (newValue) {
          addCategoryChosen(widget.category);
        } else {
          removeCategoryChosen(widget.category);
        }
      },
      disabledColor: Colors.white,
      selectedColor: Colors.black,
      checkmarkColor: Colors.white,
      deleteIcon: Icon(
        Icons.cancel,
        color: isSelected ? Colors.white : null,
      ),
      onDeleted: () {
        removeCategoryChosen(widget.category);
        removeCategoryDisplayed(widget.category);
      },
    );
  }
}
