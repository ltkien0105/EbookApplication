# Ebook Application

A Flutter project created to supply a convenient application for reading ebook instead physical ones.
If you are a book lover, this application is for you. You can read books from Google Books, download them for offline reading, and save them to your library and shelf.

## Main Features

<li>Sign in/ Sign up with Email, Google and Facebook</li>
<li>A huge numbers of books from Google Books</li>
<li>Download ebook for offline</li>
<li>Read ebook with night mode</li>
<li>Save book to library and shelf</li>

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
8. Enjoy this application (feel free to delete `.env.exanple` and `firebase-options.dart` file)
