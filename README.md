# Ebook Application

A Flutter project created to supply a convenient application for reading ebook instead physical ones.
If you are a book lover, this application is for you. You can read books from Google Books, download them for offline reading, and save them to your library and shelf.

## Main Features

<li>Sign in/ Sign up with Email, Google and Facebook</li>

![sign_in_25](https://github.com/ltkien0105/EbookApplication/assets/83855013/556e4d03-44e1-4aea-a350-a2602d2b6c7d) ![sign_up_25](https://github.com/ltkien0105/EbookApplication/assets/83855013/0e6ebf09-fb1b-4041-8387-93cf4c4bdf48)

<li>A huge numbers of books from Google Books</li>

![huge_books_25](https://github.com/ltkien0105/EbookApplication/assets/83855013/87be561e-ee28-4559-bde9-9a8237eaba72)

<li>Download ebook for offline</li>

![download_25](https://github.com/ltkien0105/EbookApplication/assets/83855013/dca3cadd-506d-4f3b-abac-955dc3606fb0)

<li>Save book to library and shelf</li>

![library_25](https://github.com/ltkien0105/EbookApplication/assets/83855013/ab463a67-5107-4c32-a8e5-af51c2cc8e18) ![shelves_25](https://github.com/ltkien0105/EbookApplication/assets/83855013/4c219397-03c5-4a2e-8f5f-cc06532af2ac)

<li>Chatbot</li>

![chatbot_25](https://github.com/ltkien0105/EbookApplication/assets/83855013/fa65ec81-ab1d-4369-93ba-712f9b659016)

## TechStack used

<li>Dart</li>
<li>Flutter</li>
<li>Firebase</li>
<li>Google Books API</li>

## How do I run this project?

1. Clone this project.
2. Run `flutter pub get` command to install necessary package.
3. Create `.env` file in root directory
4. Modify content of `.env` file to match `.env.example` file (ANDROID and IOS API KEY are required, OPENAI API LEY is optional for chatbot feature)
5. In the lib folder, create `firebase-options.dart` file.
6. Modify content of `firebase-options.dart` file file to match `firebase-options.example.dart` file, you must replace ANDROID and IOS API KEY parameter.
7. Run `flutter run` command to run this project.
8. Enjoy this application (feel free to delete `.env.exanple` and `firebase-options.example.dart` file)
