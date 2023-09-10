import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/size_config.dart';

class SummaryInfoBook extends StatefulWidget {
  const SummaryInfoBook({
    super.key,
    required this.id,
    required this.title,
    required this.authors,
    required this.description,
    required this.imgUrl,
    this.hasOptions = false,
  });

  final String id;
  final String title;
  final List<String> authors;
  final String description;
  final String imgUrl;
  final bool hasOptions;

  @override
  State<SummaryInfoBook> createState() => _SummaryInfoBookState();
}

class _SummaryInfoBookState extends State<SummaryInfoBook> {
  List<String> listShelves = [];
  List<String> listContainThisBook = [];

  Future<void> getListShelves() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .doc('libraries/${auth.currentUser!.uid}')
        .collection('shelves')
        .get();

    listShelves = snapshot.docs.map((doc) => doc.id).toList();

    await Future.forEach(listShelves, (shelfID) async {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await firestore
          .doc('libraries/${auth.currentUser!.uid}')
          .collection('shelves')
          .doc(shelfID)
          .get();

      List<String> booksID =
          List<String>.from(snapshot.data()!['booksID'].map((id) => id));

      if (booksID.contains(widget.id)) {
        listContainThisBook.add(shelfID);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String showAuthors = widget.authors.join(', ');
    return Row(
      children: [
        Card(
          elevation: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: widget.imgUrl,
              fit: BoxFit.fill,
              width: 130,
            ),
          ),
        ),
        SizedBox(
          width: getProportionateScreenWidth(10),
        ),
        Expanded(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: getProportionateScreenWidth(20),
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Text(
                  showAuthors,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: getProportionateScreenWidth(13),
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Text(
                  widget.description,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  softWrap: false,
                ),
              ),
            ],
          ),
        ),
        if (widget.hasOptions)
          PopupMenuButton(
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'show list shelves',
                child: Text("Add to shelves"),
              ),
            ],
            onSelected: (value) {
              if (value == 'show list shelves') {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Add this book to shelves...'),
                    content: FutureBuilder(
                        future: getListShelves(),
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: SizeConfig.screenHeight! * .05,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: listShelves.map((shelfId) {
                                  return StatefulBuilder(
                                    builder: (
                                      BuildContext context,
                                      void Function(void Function()) setState,
                                    ) {
                                      return ListTile(
                                        leading: Checkbox(
                                          value: listContainThisBook
                                              .contains(shelfId),
                                          onChanged: (newValue) async {
                                            if (newValue == true) {
                                              setState(() {
                                                listContainThisBook
                                                    .add(shelfId);
                                              });

                                              await firestore
                                                  .doc(
                                                      "libraries/${auth.currentUser!.uid}")
                                                  .collection("shelves")
                                                  .doc(shelfId)
                                                  .update({
                                                "booksID":
                                                    FieldValue.arrayUnion(
                                                        [widget.id])
                                              });
                                            } else {
                                              setState(() {
                                                listContainThisBook
                                                    .remove(shelfId);
                                              });

                                              await firestore
                                                  .doc(
                                                      "libraries/${auth.currentUser!.uid}")
                                                  .collection("shelves")
                                                  .doc(shelfId)
                                                  .update({
                                                "booksID":
                                                    FieldValue.arrayRemove(
                                                        [widget.id])
                                              });
                                            }
                                          },
                                          activeColor: Colors.red,
                                        ),
                                        title: Text(shelfId),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            );
                          }

                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }),
                  ),
                );
              }
            },
          )
      ],
    );
  }
}
