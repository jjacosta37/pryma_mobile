import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chat_app/screens/chat_screen.dart';

class SupplierScreen extends StatefulWidget {
  static const id = 'suppliers_screen';
  dynamic data;
  SupplierScreen({this.data});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  List<SupplierCard> supplierList = [];

  @override
  void initState() {
    super.initState();
    createSupplierList(widget.data);
  }

// Callback to be called by Supplier Card when Chat Screen Pops
  void callBack(data) {
    supplierList = [];
    setState(() {
      createSupplierList(data);
    });
  }

// Function that creates Supplier list <Cards>
  void createSupplierList(dynamic data) {
    if (data != null) {
      for (var supplier in data[1]) {
        String groupName =
            widget.data[0]['id'].toString() + '_' + supplier['id'].toString();

        SupplierCard card = SupplierCard(
          name: supplier['name'],
          groupName: groupName,
          userName: data[2],
          lastMessage: data[3][groupName],
          rebuildCards: callBack,
        );
        supplierList.add(card);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Suppliers',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: supplierList,
            ).toList(),
          ),
        ),
      ),
    );
  }
}

class SupplierCard extends StatelessWidget {
  String name;
  String groupName;
  String userName;
  String lastMessage;
  void Function(dynamic) rebuildCards;

  SupplierCard(
      {required this.name,
      required this.groupName,
      required this.userName,
      required this.lastMessage,
      required this.rebuildCards});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListTile(
        onTap: () async {
          dynamic newData = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                  groupName: groupName, supplierName: name, userName: userName),
            ),
          );
          // Call back that draws cards with newest meesages once Chat screen pops
          rebuildCards(newData);
        },
        leading: SizedBox(
          width: 40,
          child: Icon(
            FontAwesomeIcons.fish,
            size: 40,
            color: Colors.lightBlue[400],
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            name + groupName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              FontAwesomeIcons.check,
              size: 13,
              color: Colors.black38,
            ),
            SizedBox(
              width: 10.0,
            ),
            LatestMessage(
              lastMessage: lastMessage,
            ),
          ],
        ),
        horizontalTitleGap: 25,
        trailing: Column(
          children: [
            Text(
              '7.15 pm',
              style: TextStyle(color: Colors.blueAccent),
            ),
            SizedBox(height: 14),
            CircleAvatar(
              backgroundColor: Colors.blueAccent,
              radius: 10,
              child: Text(
                '2',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TODO: This should have a streambuilder that listens for new messages
class LatestMessage extends StatelessWidget {
  String lastMessage;
  LatestMessage({required this.lastMessage});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        lastMessage,
        style: TextStyle(color: Colors.black38),
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
    );
  }
}
