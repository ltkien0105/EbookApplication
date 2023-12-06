import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/size_config.dart';
import 'package:ebook_application/models/book.dart';
import 'package:ebook_application/screen/home/book_list.dart';
import 'package:ebook_application/screen/home/components/list_horizontal.dart';

class Explore extends ConsumerStatefulWidget {
  const Explore({super.key});

  @override
  ConsumerState<Explore> createState() => _ExploreState();
}

class _ExploreState extends ConsumerState<Explore>
    with AutomaticKeepAliveClientMixin<Explore> {
  @override
  bool get wantKeepAlive => true;

  late final Future myFuture;

  List<Category> categoryList = [
    Category.business,
    Category.drama,
    Category.economics,
    Category.fiction,
    Category.computer,
    Category.medical,
    Category.design,
    Category.techEngineering,
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        width: double.infinity,
        height: double.infinity,
        child: ListView.builder(
          itemCount: categoryList.length,
          itemBuilder: (context, index) => SizedBox(
            height: getProportionateScreenHeight(250),
            width: double.infinity,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      categoryList[index].specificName,
                      style: TextStyle(
                        fontSize: getProportionateScreenWidth(20),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookList(
                              category: categoryList[index],
                            ),
                          ),
                        );
                      },
                      child: const Text('See all'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListHorizontal(
                    category: categoryList[index].searchTerm,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
