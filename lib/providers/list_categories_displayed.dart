import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/models/book.dart';

class ListCategoriesDisplayedNotifier extends StateNotifier<Set<Category>> {
  ListCategoriesDisplayedNotifier() : super({});

  void getDataFromListChosen(Set<Category> listChosen) {
    state = listChosen;
  }

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

final categoriesDisplayedNotifierProvider =
StateNotifierProvider<ListCategoriesDisplayedNotifier, Set<Category>>(
      (ref) => ListCategoriesDisplayedNotifier(),
);
