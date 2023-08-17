import 'package:hive/hive.dart';

part 'book.g.dart';

enum Category {
  antiques('Antiques'),
  architecture('Architecture'),
  art('Art'),
  bibles('Bibles'),
  bioAutobio('Biography & Autobiography', searchTerm: 'biography'),
  body('Body'),
  business('Business', searchTerm: 'business'),
  collectibles('Collectibles'),
  comicGraphicNovel('Comics & Graphic Novels'),
  computer('Computer', searchTerm: 'computer'),
  cooking('Cooking'),
  craftHobbies('Craft & Hobbies'),
  design('Design', searchTerm: 'design'),
  drama('Drama', searchTerm: 'drama'),
  economics('Economics', searchTerm: 'economics'),
  education('Education'),
  family('Family & Relationship'),
  fiction('Fiction', searchTerm: 'fiction'),
  foreign('Foreign Language Study'),
  gameActivities('Game & Activities'),
  gardening('Gardening'),
  healthFitness('Health & Fitness'),
  history('History'),
  houseHome('House & Home'),
  humor('Humor'),
  juvenileFic('Juvenile Fiction'),
  juvenileNonFic('Juvenile Nonfiction'),
  languageArtDiscipline('Language Art & Disciplines'),
  law('Law'),
  literaryCollections('Literary Collections'),
  literaryCriticism('Literary Criticism'),
  mathematics('Mathematics'),
  medical('Medical', searchTerm: 'medical'),
  music('Music'),
  nature('Nature'),
  performingArts('Performing Arts'),
  pets('Pets'),
  philosophy('Philosophy'),
  photography('Photography'),
  poetry('Poetry', searchTerm: 'poetry'),
  politicalScience('Political Science'),
  psychology('Psychology'),
  reference('Reference'),
  religion('Religion'),
  science('Science'),
  selfHelp('Self-help'),
  socialScience('Social Science'),
  sportRecreation('Sports & Recreations'),
  studyAid('Study Aids'),
  techEngineering('Technology & Engineering', searchTerm: 'engineering'),
  transportation('Transportation'),
  travel('Travel'),
  trueCrime('True Crime'),
  youngAdultFic('Young Adult Fiction'),
  youngAdultNonFic('Young Adult Nonfiction');

  const Category(this.specificName, {this.searchTerm});

  final String specificName;
  final String? searchTerm;
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
