import 'package:flutter/material.dart';

class Help extends StatefulWidget {
  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0.0,
            title: Text(
              "Help",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
            leading: new IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 30.0,
                color: Colors.black,
              ),
              tooltip: 'back',
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: WillPopScope(
          onWillPop: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 28.0, left: 5),
            child: Column(children: <Widget>[
              // ListTile(
              //   title: new Text('Terms and Conditions'),
              //   leading: new Icon(Icons.assignment),
              //   onTap: () {
              //     Navigator.pushNamed(context, "/termsandconditions");
              //   },
              // ),
              ListTile(
                title: new Text('Privacy Policy'),
                leading: new Icon(Icons.description),
                onTap: () {
                  Navigator.pushNamed(context, "/privacy");
                },
              ),
              ListTile(
                title: new Text('Cancellation/Refund Policy'),
                leading: new Icon(Icons.autorenew),
                onTap: () {
                  Navigator.pushNamed(context, "/refund");
                },
              )
            ]),
          ),
        ));
  }
}
