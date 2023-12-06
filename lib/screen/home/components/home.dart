import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/apis/api.dart';
import 'package:ebook_application/size_config.dart';
import 'package:ebook_application/models/book.dart';
import 'package:ebook_application/screen/home/book_list.dart';
import 'package:ebook_application/providers/books_provider.dart';
import 'package:ebook_application/screen/home/book_details.dart';
import 'package:ebook_application/screen/home/category_list.dart';
import 'package:ebook_application/screen/home/components/list_horizontal.dart';
import 'package:ebook_application/screen/home/components/summary_info_book.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home>
    with AutomaticKeepAliveClientMixin<Home> {
  late final Future myFuture;
  List<Book> recentList = [];

  @override
  bool get wantKeepAlive => true;

  List<Category> categoryList = [
    Category.business,
    Category.drama,
    Category.economics,
    Category.computer,
    Category.fiction,
    Category.medical,
    Category.techEngineering,
  ];

  Future<void> getDataToHomePage({
    required int recentAmount,
  }) async {
    BooksNotifier booksNotifier = ref.read(booksProvider.notifier);

    final List<Map<String, dynamic>>? listRecentBooks =
        await GoogleBooksApi.getBooksByFields(
      "",
      searchTerm: 'fiction',
      searchField: SearchFields.subject,
      maxResults: recentAmount,
      isNewest: true,
    );

    if (listRecentBooks != null) {
      booksNotifier.addBookList(listRecentBooks, isRecent: true);
    }

    final books = ref.read(booksProvider);

    recentList = books.where((book) {
      if (book.imageUrl != null) {
        return book.isRecent && book.imageUrl!.contains('books.google.com');
      }
      return false;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    myFuture = getDataToHomePage(recentAmount: 10);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
      },
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Expanded(
                flex: 2,
                child: ListHorizontal(
                  category: 'popular',
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Categories',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: getProportionateScreenWidth(20),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CategoryList(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.arrow_forward_outlined),
                            ),
                          ],
                        ),
                      ),
                      // const Spacer(),
                      SizedBox(
                        height: getProportionateScreenHeight(40),
                        child: ListView.separated(
                          separatorBuilder: (context, index) => SizedBox(
                            width: getProportionateScreenWidth(10),
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: categoryList.length,
                          itemBuilder: (context, index) =>
                              filterButton(context, categoryList[index]),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Recently Added',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: getProportionateScreenWidth(20),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(16),
                    ),
                    Expanded(
                      child: FutureBuilder(
                        future: myFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 16,
                              ),
                              itemCount: recentList.length,
                              itemBuilder: (context, index) => InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookDetails(
                                        book: recentList[index],
                                      ),
                                    ),
                                  );
                                },
                                child: SummaryInfoBook(
                                  id: recentList[index].id,
                                  title: recentList[index].title,
                                  authors: recentList[index].authors,
                                  description: recentList[index].description,
                                  imgUrl: recentList[index].imageUrl,
                                ),
                              ),
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

ElevatedButton filterButton(BuildContext context, Category category) {
  return ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookList(category: category),
        ),
      );
    },
    style: const ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(Colors.blueAccent),
      foregroundColor: MaterialStatePropertyAll(Colors.white),
      shape: MaterialStatePropertyAll(
        StadiumBorder(),
      ),
    ),
    child: Text(
      category.specificName,
    ),
  );
}
