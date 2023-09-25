import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/size_config.dart';
import 'package:ebook_application/providers/shelves_provider.dart';

class SummaryInfoBook extends ConsumerStatefulWidget {
  const SummaryInfoBook({
    super.key,
    required this.id,
    required this.title,
    required this.authors,
    required this.description,
    required this.imgUrl,
    this.hasOptions = false,
    this.displayedInShelf,
    this.removeShelfOrLibrary,
    this.removeLibrary = false,
  });

  final String id;
  final String title;
  final List<String> authors;
  final String description;
  final String imgUrl;
  final bool hasOptions;
  final String? displayedInShelf;
  final VoidCallback? removeShelfOrLibrary;
  final bool removeLibrary;

  @override
  ConsumerState<SummaryInfoBook> createState() => _SummaryInfoBookState();
}

class _SummaryInfoBookState extends ConsumerState<SummaryInfoBook> {
  @override
  Widget build(BuildContext context) {
    final shelves = ref.watch(shelvesProvider);

    final listShelves = shelves.map((shelf) => shelf.name).toList();

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
                child: Text("Add or remove from shelves"),
              ),
              if (widget.removeLibrary)
                const PopupMenuItem(
                  value: 'remove from library',
                  child: Text("Remove from library"),
                ),
              if (widget.displayedInShelf != null)
                const PopupMenuItem(
                  value: 'remove from shelves',
                  child: Text("Remove from this shelves"),
                ),
            ],
            onSelected: (value) async {
              if (value == 'show list shelves') {
                showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: const Text(
                          'Add or remove this book from shelves...',
                        ),
                        content: ConstrainedBox(
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
                                  final listContainThisBook =
                                      shelves.map((shelf) {
                                    if (shelf.booksIDs.contains(widget.id)) {
                                      return shelf.name;
                                    }
                                  }).toList();

                                  return ListTile(
                                    leading: Checkbox(
                                      value:
                                          listContainThisBook.contains(shelfId),
                                      onChanged: (newValue) async {
                                        if (newValue == true) {
                                          for (var shelf in shelves) {
                                            if (shelf.name == shelfId) {
                                              setState(() {
                                                shelf.add(widget.id);
                                              });
                                              if (shelf.booksIDs.isNotEmpty) {
                                                shelf.urlAvatarShelf =
                                                    widget.imgUrl;
                                              }
                                            }
                                          }

                                          await firestore
                                              .doc(
                                                  "libraries/${auth.currentUser!.uid}")
                                              .collection("shelves")
                                              .doc(shelfId)
                                              .update({
                                            "booksID": FieldValue.arrayUnion(
                                                [widget.id])
                                          });
                                        } else {
                                          for (var shelf in shelves) {
                                            if (shelf.name == shelfId) {
                                              setState(() {
                                                shelf.remove(widget.id);
                                              });
                                            }
                                          }

                                          await firestore
                                              .doc(
                                                  "libraries/${auth.currentUser!.uid}")
                                              .collection("shelves")
                                              .doc(shelfId)
                                              .update({
                                            "booksID": FieldValue.arrayRemove(
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
                        ),
                      );
                    });
              } else if (value == 'remove from shelves') {
                await firestore
                    .doc('libraries/${auth.currentUser!.uid}')
                    .collection('shelves')
                    .doc(widget.displayedInShelf!)
                    .update({
                  'booksID': FieldValue.arrayRemove([widget.id])
                });
                widget.removeShelfOrLibrary!();
              } else if (value == 'remove from library') {
                await firestore
                    .doc('libraries/${auth.currentUser!.uid}')
                    .update({
                  'books': FieldValue.arrayRemove([widget.id])
                });
                widget.removeShelfOrLibrary!();
              }
            },
          )
      ],
    );
  }
}
