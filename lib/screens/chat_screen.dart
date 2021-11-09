import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:intl/intl.dart';
import 'package:chat_app/services/secure_storage.dart';
import 'package:chat_app/services/http_requests.dart';

class ChatScreen extends StatelessWidget {
  static const id = 'chat_screen';
  String groupName;
  String supplierName;
  String userName;

  ChatScreen(
      {required this.groupName,
      required this.supplierName,
      required this.userName});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SecureStorage().readSecureData('token'),
      builder: (context, snapshot) {
        WebSocketChannel _channel = IOWebSocketChannel.connect(
            "ws://10.0.2.2:8000/ws/chat/$groupName/",
            headers: {'authorization': 'Token $snapshot.data'});
        return ChatScreenStatefull(_channel, groupName, supplierName, userName);
      },
    );
  }
}

class ChatScreenStatefull extends StatefulWidget {
  final WebSocketChannel _channel;
  String groupName;
  String supplierName;
  String userName;
  ChatScreenStatefull(
      this._channel, this.groupName, this.supplierName, this.userName);

  @override
  _ChatScreenStatefullState createState() => _ChatScreenStatefullState();
}

class _ChatScreenStatefullState extends State<ChatScreenStatefull> {
  final messageTextController = TextEditingController();
  late String messageText;
  late final WebSocketChannel _channel;
  final httpRequestBack = HttpRequestBack();

  @override
  void initState() {
    _channel = widget._channel;
    super.initState();
    var data = jsonEncode({
      "command": 'fetch_messages',
      "chatgroup": widget.groupName,
    });
    _channel.sink.add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                dynamic data = await httpRequestBack.getSupplierScreenData();
                dynamic decodedData = jsonDecode(data.body);
                Navigator.pop(context, decodedData);
              }),
        ],
        title: Text(
          widget.supplierName,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(_channel, widget.userName),
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
                        "sender": widget.userName,
                        "chatgroup": widget.groupName,
                      });
                      _channel.sink.add(data);
                    },
                    child: Text(
                      'Send',
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

class MessageStream extends StatelessWidget {
  final WebSocketChannel _channel;
  List<MessageBubble> messageWidgets = [];
  String username;

  MessageStream(this._channel, this.username);

  List<MessageBubble> createBubbleList(List bubbleList) {
    List<MessageBubble> lst = [];
    for (var i in bubbleList.reversed) {
      lst.add(i);
    }
    return lst;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _channel.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final codedMessages = snapshot.data as String;
            final messages = jsonDecode(codedMessages);
            for (var message in messages!) {
              final currentUser = username;
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
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              children: createBubbleList(messageWidgets),
            ),
          );
        });
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
            borderRadius: BorderRadius.all(Radius.circular(20)),
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
