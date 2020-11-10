import 'package:flutter/material.dart';

class DefaultInformationScreen extends StatelessWidget {
  static const routeName = "/default_information_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Information"),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 32, 16, 40),
        child: ListView(
          children: [
            Text(
              "Informationen",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text("Hier können noch viele weitere Informationen untergebracht werden.")
          ],
        ),
      ),
    );
  }
}
