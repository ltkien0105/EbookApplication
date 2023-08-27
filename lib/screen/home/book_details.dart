import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/apis/api.dart';
import 'package:ebook_application/models/book.dart';
import 'package:ebook_application/size_config.dart';
import 'package:ebook_application/providers/books_provider.dart';
import 'package:ebook_application/screen/home/components/summary_info_book.dart';

import 'components/category_box.dart';

class BookDetails extends ConsumerStatefulWidget {
  const BookDetails({super.key, required this.book});

  final Book book;

  @override
  ConsumerState<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends ConsumerState<BookDetails> {
  bool isFavorite = false;
  late List<Book> showedList;
  late Future myFuture;

  List<String> getCategoryHandled() {
    if (widget.book.categories.isNotEmpty) {
      return widget.book.categories.map((category) {
        if (category.contains('(')) {
          return category.substring(0, category.indexOf('(') - 1);
        }

        if (category.contains('/')) {
          return category.substring(0, category.indexOf('/') - 1);
        }

        return category;
      }).toList();
    }
    return [];
  }

  Future<void> fetchData() async {
    BooksNotifier booksNotifier = ref.read(booksProvider.notifier);

    List<Map<String, dynamic>>? listBook;

    listBook = await GoogleBooksApi.getBooksByFields(
      '',
      searchTerm: widget.book.authors[0],
      searchField: SearchFields.inauthor,
      maxResults: 5,
    );

    if (listBook != null) {
      booksNotifier.addBookList(listBook);
    }

    showedList = ref
        .watch(booksProvider)
        .where((book) => book.authors.contains(widget.book.authors[0]))
        .toList();
  }

  @override
  void initState() {
    super.initState();

    myFuture = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    String showAuthors = widget.book.authors.join(', ');
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            margin: EdgeInsets.only(right: getProportionateScreenWidth(16)),
            alignment: Alignment.center,
            child: InkWell(
              onTap: () {
                setState(() {
                  isFavorite = !isFavorite;
                });
              },
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
                size: getProportionateScreenWidth(30),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: SizeConfig.screenWidth,
                  height: SizeConfig.screenHeight! * .25,
                  child: Row(
                    children: [
                      Container(
                        height: double.infinity,
                        width: getProportionateScreenWidth(150),
                        color: Colors.yellow,
                        child: Image.network(
                          widget.book.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        width: getProportionateScreenWidth(8),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              widget.book.title,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: getProportionateScreenWidth(20),
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: getProportionateScreenHeight(4),
                            ),
                            Text(
                              showAuthors,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: getProportionateScreenWidth(15),
                              ),
                            ),
                            SizedBox(
                              height: getProportionateScreenHeight(8),
                            ),
                            Expanded(
                              child: GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                childAspectRatio: 1 / .3,
                                mainAxisSpacing:
                                    getProportionateScreenHeight(8),
                                crossAxisSpacing:
                                    getProportionateScreenWidth(4),
                                children: getCategoryHandled()
                                    .map((category) =>
                                        CategoryBox(category: category))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: getProportionateScreenHeight(30),
                ),
                SizedBox(
                  width: SizeConfig.screenWidth,
                  height: SizeConfig.screenHeight! * .25,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Book Description',
                          style: TextStyle(
                            fontSize: getProportionateScreenWidth(20),
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Divider(
                        height: getProportionateScreenHeight(16),
                        thickness: getProportionateScreenHeight(2),
                      ),
                      SizedBox(
                        height: getProportionateScreenHeight(8),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          widget.book.description,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: getProportionateScreenWidth(15),
                          ),
                          maxLines: 8,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: SizeConfig.screenWidth,
                  height: SizeConfig.screenHeight! * .5,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'More from this author',
                          style: TextStyle(
                            fontSize: getProportionateScreenWidth(20),
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Divider(
                        height: getProportionateScreenHeight(16),
                        thickness: getProportionateScreenHeight(2),
                      ),
                      SizedBox(
                        height: getProportionateScreenHeight(8),
                      ),
                      FutureBuilder(
                        future: myFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Expanded(
                              child: ListView.separated(
                                separatorBuilder: (context, index) => SizedBox(
                                  height: getProportionateScreenHeight(8),
                                ),
                                itemCount: showedList.length,
                                itemBuilder: (context, index) {
                                  return SummaryInfoBook(
                                    title: showedList[index].title,
                                    authors: showedList[index].authors,
                                    description: showedList[index].description,
                                    imgUrl: showedList[index].imageUrl,
                                  );
                                },
                              ),
                            );
                          }

                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      )
                    ],
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
