class Message {
  final String content;
  final bool isUser;
  final DateTime sendTime;

  Message({
    required this.content,
    required this.isUser,
  }) : sendTime = DateTime.now();

  String get formattedTime => '${sendTime.hour}:${sendTime.minute}';
}
