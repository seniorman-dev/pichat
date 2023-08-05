import 'package:flutter/material.dart';








class ChatScreen2 extends StatefulWidget {
  @override
  _ChatScreen2State createState() => _ChatScreen2State();
}

class _ChatScreen2State extends State<ChatScreen2> with WidgetsBindingObserver{
  List<Message> _messages = [];
  TextEditingController _textEditingController = TextEditingController();

  void _addMessage(String text, bool isUser1) {
    setState(() {
      _messages.add(Message(text: text, isUser1: isUser1));
      _textEditingController.clear();
    });
  }

  double keyboardHeight = 0;
  double keyboardTop = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final topInset = WidgetsBinding.instance.window.viewInsets.top;
    setState(() {
      keyboardHeight = bottomInset;
      keyboardTop = topInset; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat Screen')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Align(
                    alignment:
                        message.isUser1 ? Alignment.topLeft : Alignment.topRight,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            message.isUser1 ? Colors.blue : Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: keyboardTop,
              //bottom: keyboardHeight - MediaQuery.of(context).padding.bottom,
              bottom: keyboardHeight > MediaQuery.of(context).padding.bottom + 10
              ? keyboardHeight - MediaQuery.of(context).padding.bottom - 250
              : 0,
            ),
            child: Row(    ///conta
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_textEditingController.text.isNotEmpty) {
                      _addMessage(_textEditingController.text, true);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class Message {
  final String text;
  final bool isUser1;

  Message({required this.text, required this.isUser1});
}




