import 'package:admin/constants.dart';
import 'package:admin/models/chat.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class GeminiChatBot extends StatefulWidget {
  const GeminiChatBot({super.key});
  @override
  State<GeminiChatBot> createState() => _GeminiChatBotState();
}

class _GeminiChatBotState extends State<GeminiChatBot> {
  TextEditingController promprController = TextEditingController();
  static const apiKey = "AIzaSyC5N5r-hqgyVIRUXitZ7AgKMKJXH_1YhMU";
  final model = GenerativeModel(model: "gemini-1.5-flash", apiKey: apiKey);

  final List<ModelMessage> prompt = [];

  Future<void> sendMessage() async {
    final message = promprController.text;
    // for prompt
    setState(() {
      promprController.clear();
      prompt.add(
        ModelMessage(
          isPrompt: true,
          message: message,
          time: DateTime.now(),
        ),
      );
    });
    // for respond
    final content = [Content.text(message)];
    final response = await model.generateContent(content);
    setState(() {
      prompt.add(
        ModelMessage(
          isPrompt: false,
          message: response.text ?? "",
          time: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blue[100],
      appBar: AppBar(
        elevation: 3,
        // backgroundColor: Colors.blue[100],
        title: const Text("AI ChatBot"),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: prompt.length,
                  itemBuilder: (context, index) {
                    final message = prompt[index];
                    return UserPrompt(
                      isPrompt: message.isPrompt,
                      message: message.message,
                      date: DateFormat('hh:mm a').format(
                        message.time,
                      ),
                    );
                  })),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Row(
              children: [
                Expanded(
                  flex: 20,
                  child: TextField(
                      controller: promprController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          hintText: "Enter a prompt here"),
                      onSubmitted: (value) {
                        sendMessage();
                      }),
                ),
                SizedBox(width: defaultPadding),
                GestureDetector(
                  onTap: () {
                    sendMessage();
                  },
                  child: const CircleAvatar(
                    radius: 29,
                    backgroundColor: Colors.purpleAccent,
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container UserPrompt({
    required final bool isPrompt,
    required String message,
    required String date,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isPrompt ? 80 : 15,
        right: isPrompt ? 15 : 80,
      ),
      decoration: BoxDecoration(
        color: isPrompt ? Colors.purpleAccent : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: const Radius.circular(12),
          bottomRight: const Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // for prompt and respond
          Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: isPrompt ? Colors.white : Colors.black,
            ),
          ),
          // for prompt and respond time
          SizedBox(height: defaultPadding),
          Text(
            date,
            style: TextStyle(
              fontSize: 10,
              color: isPrompt ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
