import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chat_app/screens/chat_screen.dart';

class SupplierScreen extends StatelessWidget {
  static const id = 'suppliers_screen';

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
              tiles: [
                SupplierCard(),
                SupplierCard(),
                SupplierCard(),
                SupplierCard(),
              ],
            ).toList(),
          ),
        ),
      ),
    );
  }
}

class SupplierCard extends StatelessWidget {
  const SupplierCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, ChatScreen.id);
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
            'Proveedor Carnes',
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
            Text(
              'Listo, ya se le envio el envio',
              style: TextStyle(color: Colors.black38),
            ),
          ],
        ),
        horizontalTitleGap: 25,
        trailing: Text(
          '7.15 pm',
          style: TextStyle(color: Colors.black38),
        ),
      ),
    );
  }
}
