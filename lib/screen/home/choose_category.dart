import 'package:ebook_application/components/custom_expansion_list.dart'
    as cus_exp;
import 'package:ebook_application/providers/list_categories_chosen.dart';
import 'package:ebook_application/providers/list_categories_displayed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChooseCategory extends ConsumerStatefulWidget {
  const ChooseCategory({super.key});

  @override
  ConsumerState<ChooseCategory> createState() => _ChooseCategoryState();
}

class _ChooseCategoryState extends ConsumerState<ChooseCategory> {
  final List<bool> _isOpen = [true, true];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        ref
            .watch(categoriesDisplayedNotifierProvider.notifier)
            .getDataFromListChosen(ref.watch(categoriesChosenNotifierProvider));

        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Choose Category'),
          actions: [
            TextButton(
              onPressed: () {
                ref
                    .watch(categoriesDisplayedNotifierProvider.notifier)
                    .getDataFromListChosen(
                        ref.watch(categoriesChosenNotifierProvider));

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: cus_exp.ExpansionPanelList(
              dividerColor: Colors.pink,
              expansionCallback: (index, isOpen) => setState(() {
                _isOpen[index] = !isOpen;
              }),
              expandIconColor: Colors.black,
              children: [
                cus_exp.ExpansionPanel(
                  canTapOnHeader: true,
                  backgroundColor: const Color.fromARGB(255, 249, 249, 249),
                  headerBuilder: (context, isOpen) => Container(
                    padding: const EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Fiction',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  body: const Column(
                    children: [],
                    // children: Category.values
                    //     .where((category) => category.type == 'fiction')
                    //     .map((category) => CheckCategoryItem(
                    //           category: category,
                    //         ))
                    //     .toList(),
                  ),
                  isExpanded: _isOpen[0],
                ),
                cus_exp.ExpansionPanel(
                  canTapOnHeader: true,
                  backgroundColor: const Color.fromARGB(255, 249, 249, 249),
                  headerBuilder: (context, isOpen) => Container(
                    padding: const EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Nonfiction',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  body: const Column(children: [] // Category.values
                      //     .where((category) => category.type == 'nonfiction')
                      //     .map((category) => CheckCategoryItem(
                      //           category: category,
                      //         ))
                      //     .toList(),
                      ),
                  isExpanded: _isOpen[1],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
