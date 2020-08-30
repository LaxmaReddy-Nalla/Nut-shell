import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nutshell/bottomNav.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show rootBundle;

class Refund extends StatefulWidget {
  @override
  _RefundState createState() => _RefundState();
}

class _RefundState extends State<Refund> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
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
        ),
        title: Text(
          "Refund/Cancellation Policy",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: WillPopScope(
        child: ListView(
          children: <Widget>[
            _buildRefund(),
          ],
        ),
      ),
    );
  }

  // TODO: refactor the code
  _buildRefund() {
    print("called me");
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 1,
      child: FutureBuilder<Directory>(
        future: getApplicationDocumentsDirectory(),
        builder: (BuildContext context, AsyncSnapshot<Directory> snapshot) {
          if (snapshot.hasData) {
            return Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(
                  color: Colors.green,
                )),
                child: Container(
                  child: FutureBuilder<String>(
                      future: rootBundle.loadString('assets/refund.html'),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return SingleChildScrollView(
                            child: Html(
                              data: '''
                            ${snapshot.data}
                          ''',
                            ),
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      }),
                ));
          }
          return IgnorePointer();
        },
      ),
    );
  }
}
