import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebook_application/screen/home/book_details.dart';
import 'package:flutter/material.dart';

import 'package:ebook_application/size_config.dart';

class SummaryInfoBook extends StatelessWidget {
  const SummaryInfoBook({
    super.key,
    required this.title,
    required this.authors,
    required this.description,
    required this.imgUrl,
  });

  final String title;
  final List<String> authors;
  final String description;
  final String imgUrl;

  @override
  Widget build(BuildContext context) {
    String showAuthors = authors.join(', ');
    return Row(
      children: [
        Card(
          elevation: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: imgUrl,
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
                  title,
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
                  description,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  softWrap: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
