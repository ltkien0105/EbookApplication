import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/components/input_chip.dart';
import 'package:ebook_application/providers/list_categories_chosen.dart';
import 'package:ebook_application/providers/list_categories_displayed.dart';
import 'package:ebook_application/screen/home/choose_category.dart';

class AddNewBook extends ConsumerStatefulWidget {
  const AddNewBook({super.key});

  @override
  ConsumerState<AddNewBook> createState() => _AddNewBookState();
}

class _AddNewBookState extends ConsumerState<AddNewBook> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> addBook() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final categoryList = ref.watch(categoriesChosenNotifierProvider);

      Set<DocumentReference<Map<String, dynamic>>> categoriesDocument =
          categoryList.map((category) {
        return firestore.doc('categories/${category.name}');
      }).toSet();

      await firestore.collection('books').add({
        'title': _titleController.text,
        'author': _authorController.text,
        'created_at': DateTime.now(),
        'description': _descController.text,
        'categories': categoriesDocument,
      });

      setState(() {
        isLoading = false;
      });

      _titleController.clear();
      _authorController.clear();
      _descController.clear();

      ref.watch(categoriesChosenNotifierProvider.notifier).clear();
      ref.watch(categoriesDisplayedNotifierProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listCategoryDisplayedProvider =
        ref.watch(categoriesDisplayedNotifierProvider);

    return WillPopScope(
      onWillPop: () {
        ref.watch(categoriesChosenNotifierProvider.notifier).clear();
        ref.watch(categoriesDisplayedNotifierProvider.notifier).clear();
        return Future.value(true);
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Adding new book'),
            actions: [
              TextButton(
                onPressed: isLoading ? null : addBook,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'ADD',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 4,
                      ),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                        ),
                        validator: (title) {
                          if (title == null || title.isEmpty) {
                            return '* Title is required';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: _authorController,
                        decoration: const InputDecoration(
                          labelText: 'Author',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                        ),
                        validator: (author) {
                          if (author == null || author.isEmpty) {
                            return '* Author is required';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChooseCategory(),
                                ),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'View all',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: Icon(Icons.arrow_forward_ios),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Wrap(
                        spacing: 5,
                        children: [
                          for (final category in listCategoryDisplayedProvider)
                            InputChipButton(
                              category: category,
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        maxLines: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
