import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/models/book.dart';

class ListCategoriesChosenNotifier extends StateNotifier<Set<Category>> {
  ListCategoriesChosenNotifier() : super({});

  void add(Category newCategory) {
    state = {...state, newCategory};
  }

  void remove(Category categoryRemoved) {
    state = state.where((category) => category != categoryRemoved).toSet();
  }

  void clear() {
    state.clear();
  }
}

final categoriesChosenNotifierProvider =
StateNotifierProvider<ListCategoriesChosenNotifier, Set<Category>>(
      (ref) => ListCategoriesChosenNotifier(),
);
