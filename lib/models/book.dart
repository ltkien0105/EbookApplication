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
  popular('Popular', 'popular'),
  psychology('Psychology', 'psychology'),
  reference('Reference', 'reference'),
  recent('Recent', 'recent'),
  science('Science', 'science'),
  techEngineering('Technology & Engineering', 'engineering'),
  travel('Travel', 'travel');

  const Category(this.specificName, this.searchTerm);

  final String specificName;
  final String searchTerm;
}

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
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final List<String> authors;
  final List<String> categories;
  final String description;
  final String? imageUrl;
  bool isPopular;
  bool isRecent;
  bool isFavorite;

  factory Book.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] as String;
    final String title = json['volumeInfo']['title'] as String;
    final List<String> authors = json['volumeInfo'].containsKey('authors')
        ? List<String>.from(
            json['volumeInfo']['authors'].map((author) => author))
        : [];
    final List<String> categories = json['volumeInfo'].containsKey('categories')
        ? List<String>.from(
            json['volumeInfo']['categories'].map((category) => category))
        : [];
    final String description = json['volumeInfo'].containsKey('description')
        ? json['volumeInfo']['description'] as String
        : 'No description';
    final String? imageUrl = json['volumeInfo'].containsKey('imageLinks')
        ? json['volumeInfo']['imageLinks']['thumbnail'] as String
        : null;

    return Book(
      id: id,
      title: title,
      authors: authors,
      categories: categories,
      description: description,
      imageUrl: imageUrl,
    );
  }

  factory Book.fetchSpecificBook(Map<String, dynamic> json) {
    final String id = json['id'] as String;
    final String title = json['title'] as String;
    final List<String> authors = json.containsKey('authors')
        ? List<String>.from(json['authors'].map((author) => author))
        : [];
    final List<String> categories = json.containsKey('categories')
        ? List<String>.from(json['categories'].map((category) => category))
        : [];
    final String description = json.containsKey('description')
        ? json['description'] as String
        : 'No description';
    final String? imageUrl = json.containsKey('imageLinks')
        ? json['imageLinks']['thumbnail'] as String
        : null;

    return Book(
      id: id,
      title: title,
      authors: authors,
      categories: categories,
      description: description,
      imageUrl: imageUrl,
    );
  }
}
