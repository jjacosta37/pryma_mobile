import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:intl/intl.dart';
import 'package:chat_app/services/secure_storage.dart';

class ChatScreen extends StatelessWidget {
  static const id = 'chat_screen';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SecureStorage().readSecureData('token'),
      builder: (context, snapshot) {
        WebSocketChannel _channel = IOWebSocketChannel.connect(
            "ws://10.0.2.2:8000/ws/chat/lobby/",
            headers: {'authorization': 'Token $snapshot.data'});
        return ChatScreenStatefull(_channel);
      },
    );
  }
}

class ChatScreenStatefull extends StatefulWidget {
  final WebSocketChannel _channel;
  ChatScreenStatefull(this._channel);

  @override
  _ChatScreenStatefullState createState() => _ChatScreenStatefullState();
}

class _ChatScreenStatefullState extends State<ChatScreenStatefull> {
  final messageTextController = TextEditingController();
  late String messageText;
  List<MessageBubble> messageWidgets = [];
  late final WebSocketChannel _channel;

  @override
  void initState() {
    _channel = widget._channel;
    super.initState();
    var data = jsonEncode({
      "command": 'fetch_messages',
      "chatgroup": 'lobby',
    });
    _channel.sink.add(data);
  }

  List<MessageBubble> createBubbleList(List bubbleList) {
    List<MessageBubble> lst = [];
    for (var i in bubbleList.reversed) {
      lst.add(i);
    }
    return lst;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {});
              }),
        ],
        title: Text('⚡️Chat'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder(
                stream: _channel.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final codedMessages = snapshot.data as String;
                    final messages = jsonDecode(codedMessages);
                    for (var message in messages!) {
                      // TODO: Current user needs to be variable
                      final currentUser = 'jjacosta37@gmail.com';
                      final timeSent = new DateTime.now();

                      final messageText = message['message'];
                      final messageSender = message['sender'];
                      bool isMe = currentUser == messageSender;

                      // Got to fix this

                      final messageWidget = MessageBubble(
                        sender: messageSender,
                        text: messageText,
                        isMe: isMe,
                        timeSent: timeSent,
                      );
                      print(snapshot.connectionState);

                      messageWidgets.add(messageWidget);
                    }
                  }

                  return Expanded(
                    child: ListView(
                      reverse: true,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      children: createBubbleList(messageWidgets),
                    ),
                  );
                }),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      var data = jsonEncode({
                        "command": 'send_chat_message',
                        "message": messageText,
                        "sender": 'jjacosta37@gmail.com',
                        "chatgroup": 'lobby',
                      });
                      _channel.sink.add(data);
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: Text(
                      'Test',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {required this.sender,
      required this.text,
      required this.isMe,
      required this.timeSent});

  final String sender;
  final String text;
  final bool isMe;
  final DateTime timeSent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            DateFormat('yyyy-MM-dd kk:mm').format(timeSent),
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            elevation: 1.0,
            color: isMe ? Colors.blueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
