import 'package:flutter/material.dart';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/size_config.dart';
import 'package:ebook_application/models/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final OpenAI openAI;
  final TextEditingController _messageController = TextEditingController();

  void chatComplete() async {
    final messageRequest = _messageController.text;

    final request = ChatCompleteText(
      model: GptTurbo0301ChatModel(),
      messages: [Messages(role: Role.user, content: messageRequest)],
    );

    final response = await openAI.onChatCompletion(request: request);

    for (var element in response!.choices) {
      setState(() {
        messageHistory.insert(
          0,
          Message(
            content: element.message!.content,
            isUser: false,
          ),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();

    openAI = OpenAI.instance.build(
      token: openAiAPIKey,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
      enableLog: true,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icons/chatbot.png',
            ),
            const SizedBox(
              width: 16,
            ),
            const Text(
              'Chat Bot',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 65, 90, 118),
      ),
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Container(
              color: const Color.fromARGB(255, 52, 53, 65),
              padding: const EdgeInsets.only(bottom: 100),
              child: ListView.separated(
                reverse: true,
                itemCount: messageHistory.length,
                separatorBuilder: (context, index) => const SizedBox(
                  height: 16,
                ),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: messageBox(
                    content: messageHistory[index].content,
                    isUser: messageHistory[index].isUser,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: TextField(
                  controller: _messageController,
                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        setState(() {
                          messageHistory.insert(
                            0,
                            Message(
                              content: _messageController.text,
                              isUser: true,
                            ),
                          );
                        });
                        chatComplete();
                        _messageController.clear();
                      },
                    ),
                    suffixIconColor: Colors.grey,
                    filled: true,
                    fillColor: const Color.fromARGB(255, 68, 70, 84),
                    hintText: 'Send a message',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget messageBox({required String content, required bool isUser}) => Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isUser)
          Image.asset(
            'assets/icons/chatbot.png',
          ),
        const SizedBox(
          width: 8,
        ),
        Container(
          constraints: BoxConstraints(maxWidth: SizeConfig.screenWidth! * .7),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUser
                ? const Color.fromARGB(255, 68, 91, 120)
                : const Color.fromARGB(255, 235, 241, 246),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomRight: isUser ? Radius.zero : const Radius.circular(16),
              bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            ),
          ),
          child: Text(
            content,
            softWrap: true,
            style: TextStyle(
              fontSize: 16,
              color: isUser
                  ? Colors.white
                  : const Color.fromARGB(255, 112, 123, 136),
            ),
          ),
        ),
      ],
    );
