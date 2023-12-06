import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/size_config.dart';
import 'package:ebook_application/models/shelf.dart';
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
  });

  final String id;
  final String title;
  final List<String> authors;
  final String description;
  final String? imgUrl;
  final bool hasOptions;

  @override
  ConsumerState<SummaryInfoBook> createState() => _SummaryInfoBookState();
}

class _SummaryInfoBookState extends ConsumerState<SummaryInfoBook> {
  @override
  Widget build(BuildContext context) {
    List<Shelf> shelves = ref.watch(shelvesProvider);
    final listShelvesNames = shelves.map((shelf) => shelf.name).toList();

    String showAuthors = widget.authors.join(', ');

    return Row(
      children: [
        Card(
          elevation: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: widget.imgUrl != null
                ? CachedNetworkImage(
                    imageUrl: widget.imgUrl!,
                    fit: BoxFit.fill,
                    width: 130,
                  )
                : Opacity(
                    opacity: 0.3,
                    child: SvgPicture.asset(
                      'assets/images/book_placeholder.svg',
                      width: 130,
                    ),
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
                          children: listShelvesNames.map((shelfName) {
                            return StatefulBuilder(
                              builder: (
                                BuildContext context,
                                void Function(void Function()) setState,
                              ) {
                                List<String?> listContainThisBook =
                                    shelves.map((shelf) {
                                  if (shelf.bookIdAndUrl.keys
                                      .contains(widget.id)) {
                                    return shelf.name;
                                  }
                                }).toList();

                                return ListTile(
                                  leading: Checkbox(
                                    value:
                                        listContainThisBook.contains(shelfName),
                                    onChanged: (newValue) async {
                                      if (newValue == true) {
                                        await firestore
                                            .doc(
                                                'libraries/${auth.currentUser!.uid}')
                                            .update(
                                          {
                                            'books.${widget.id}':
                                                FieldValue.arrayUnion(
                                                    [shelfName])
                                          },
                                        );

                                        await ref
                                            .watch(shelvesProvider.notifier)
                                            .addToSpecificShelf(
                                              shelfName: shelfName,
                                              bookId: widget.id,
                                              imgUrl: widget.imgUrl,
                                            );
                                        setState(() {});
                                      } else {
                                        await firestore
                                            .doc(
                                                'libraries/${auth.currentUser!.uid}')
                                            .update({
                                          'books.${widget.id}':
                                              FieldValue.arrayRemove(
                                                  [shelfName])
                                        });

                                        await ref
                                            .watch(shelvesProvider.notifier)
                                            .removeBookFromSpecificShelf(
                                              shelfName: shelfName,
                                              bookId: widget.id,
                                            );
                                        setState(() {});
                                      }
                                    },
                                    activeColor: Colors.red,
                                  ),
                                  title: Text(shelfName),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          )
      ],
    );
  }
}
