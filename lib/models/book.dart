import 'package:hive/hive.dart';

part 'book.g.dart';

enum Category {
  architecture('Architecture', 'architecture'),
  bioAutobio('Biography & Autobiography', 'biography'),
  body('Body', 'body'),
  business('Business', 'business'),
  comicGraphicNovel('Comics & Graphic Novels', 'comics'),
  computer('Computer', 'computer'),
  cooking('Cooking', 'cooking'),
  design('Design', 'design'),
  drama('Drama', 'drama'),
  economics('Economics', 'economics'),
  education('Education', 'education'),
  family('Family & Relationship', 'family'),
  fiction('Fiction', 'fiction'),
  foreign('Foreign Language Study', 'foreign'),
  gameActivities('Game & Activities', 'game'),
  healthFitness('Health & Fitness', 'health'),
  history('History', 'history'),
  houseHome('House & Home', 'house'),
  humor('Humor', 'humor'),
  mathematics('Mathematics', 'mathematics'),
  medical('Medical', 'medical'),
  photography('Photography', 'photography'),
  poetry('Poetry', 'poetry'),
  psychology('Psychology', 'psychology'),
  reference('Reference', 'reference'),
  science('Science', 'science'),
  techEngineering('Technology & Engineering', 'engineering'),
  travel('Travel', 'travel');

  const Category(this.specificName, this.searchTerm);

  final String specificName;
  final String searchTerm;
}

@HiveType(typeId: 1)
class Book {
  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.categories,
    required this.description,
    required this.imageUrl,
    this.isPopular = false,
    this.isRecent = false,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<String> authors;

  @HiveField(3)
  final List<String> categories;

  @HiveField(4)
  final String description;

  // @HiveField(5)
  // DateTime createdAt;

  @HiveField(5)
  final String imageUrl;

  @HiveField(6)
  bool isPopular;

  @HiveField(7)
  bool isRecent;

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'] as String,
        title: json['title'] as String,
        authors: List<String>.from(json['authors'].map((x) => x)),
        categories: List<String>.from(json['categories'].map((x) => x)),
        description: json['description'] as String,
        imageUrl: json['imageUrl'] as String,
      );
}
