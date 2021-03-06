import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nutshell/database.dart';
import 'package:nutshell/users.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'details.dart';
import 'currentUser.dart';
import 'package:nutshell/model/userdetails.dart';
import 'account.dart';
import 'orderConfirmation.dart';
import 'global.dart' as global;

bool selection1 = false;

String sID;
Razorpay razorpay;
int payfree = 0;
int payone = 0;
int paytwo = 0;
int paythree = 0;
final CollectionReference users = Firestore.instance.collection('users');
Users _currentUser = Users();
Users get getCurrentUser => _currentUser;

class Subscription extends StatefulWidget {
  @override
  _SubscriptionState createState() => _SubscriptionState();
}

enum en { f, b, s, p }
Map pay = {0: payfree, 1: payone, 2: paytwo, 3: paythree};

class _SubscriptionState extends State<Subscription> {
  var oneval = false;
  var twoval = false;
  bool isVisible = false;
  int svgIndex;
  var threeval = false;

  static const List<String> svgNames = <String>[
    "assets/images/7Days.svg",
    "assets/images/2Months.svg",
    "assets/images/6Months.svg",
    "assets/images/1Year.svg",
  ];
  @override
  Widget build(BuildContext context) {
    callSet(String sv) {
      setState(() {
        isVisible == true && svgIndex != svgNames.indexOf(sv)
            ? isVisible = true
            : isVisible = !isVisible;
        svgIndex = svgNames.indexOf(sv);
      });
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Text(
              "Pick your subscription plan",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 45.0, fontWeight: FontWeight.bold),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.65,
              width: MediaQuery.of(context).size.width * 1.4,
              child: CarouselSlider(
                  options: CarouselOptions(
                    aspectRatio: 8 / 25,
                    autoPlay: false,
                    enableInfiniteScroll: false,
                  ),
                  items: svgNames.map((sv) {
                    return Builder(
                      builder: (BuildContext context) {
                        return GestureDetector(
                            onTap: () {
                              callSet(sv);
                            },
                            child: Stack(
                              children: <Widget>[
                                Align(
                                  child: SvgPicture.asset(
                                    "$sv",
                                  ),
                                ),
                                Visibility(
                                    visible: isVisible
                                        ? svgNames.indexOf(sv) == svgIndex
                                            ? true
                                            : false
                                        : false,
                                    child: Positioned(
                                      left: MediaQuery.of(context).size.width *
                                          0.32,
                                      top: MediaQuery.of(context).size.height *
                                          0.05,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Color.fromRGBO(191, 30, 46, 1),
                                        size: 60,
                                      ),
                                    ))
                              ],
                            ));
                      },
                    );
                  }).toList()),
            ),
            Container(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.4,
                  right: 10.0,
                  bottom: 10),

              child: RaisedButton(
                padding: EdgeInsets.only(
                    left: 22.0, right: 20.0, top: 10.0, bottom: 10.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0)),
                onPressed: isVisible == true
                    ? () {
                        setState(() {
                          global.subPlan = en.values[svgIndex].toString();
                          print("index of svg $svgIndex");
                          switch (svgIndex) {
                            case 0:
                              {
                                payfree = 1;
                                break;
                              }
                            case 1:
                              {
                                payone = 1;
                                break;
                              }

                            case 2:
                              {
                                paytwo = 1;
                                break;
                              }
                            case 3:
                              {
                                paythree = 1;
                                break;
                              }
                          }
                        });

                        print(pay.values.toList()[svgIndex].toString());
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Details()));
                      }
                    : null,
                disabledColor: Colors.grey,
                color: Color.fromRGBO(109, 0, 109, 1),
                child: Center(
                  child: Text(
                    'Continue',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // ),
            )
          ],
        )
        // )
        );
  }

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
    setState(() {
      selection1 = false;
      payone = 0;
      paythree = 0;
      paytwo = 0;
    });
  }
}

void openCheckout(BuildContext context) async {
  _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(
      msg: "SUCCESS: " + response.paymentId,
    );

    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      print("current user id");
      print(user.uid);

      final Firestore fireStore = Firestore.instance;
      DateTime expiryDate = DateTime.now().add(Duration(days: 61));
      await fireStore.collection("users").document(user.uid).updateData({
        "subPlan": global.subPlan,
        "subscription": true,
        "expiryDate": expiryDate
      });
      print("updated");
    } catch (e) {
      print(e.toString());
    }

    print("account page");
    razorpay.clear();
    Provider.of<UserDetails>(context, listen: false)
        .setnoOfPaper(global.subPlan);

    Provider.of<UserDetails>(context, listen: false).setnoOfPaper(global.group);
    QuerySnapshot qs = await Firestore.instance
        .collection("Group" + global.group)
        .orderBy("name")
        .getDocuments();
    print("doc");
    Provider.of<UserDetails>(context, listen: false).setQuery(qs); //changes
    Navigator.pushReplacementNamed(context, '/bottombar');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "ERROR: " + response.code.toString() + " - " + response.message,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: "EXTERNAL_WALLET: " + response.walletName,
    );
  }

  print("Just came to opencheckout function");
  print(_currentUser.uid);

  var onemonth = {
    'key': 'rzp_live_A94dLEeQb2Cj5s',
    'currency': "INR",
    'amount': 110, //in the smallest currency sub-unit.
    'name': 'Nutshell',
    'description': 'One month Nutshell Subscription',
    'prefill': {'contact': '+91' + global.phone, 'email': global.email}
  };

  try {
    print("Trying to go to razorpay");
    razorpay.open(onemonth);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  } catch (e) {
    print("catch block jp");
    debugPrint(e);
  }
}

void openCheckoutthree(BuildContext context) async {
  _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(
      msg: "SUCCESS: " + response.paymentId,
    );

    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      print("current user id");
      print(user.uid);

      final Firestore fireStore = Firestore.instance;
      DateTime expiryDate = DateTime.now().add(Duration(days: 183));
      await fireStore.collection("users").document(user.uid).updateData({
        "subPlan": global.subPlan,
        "subscription": true,
        "expiryDate": expiryDate
      });
      print("updated");
    } catch (e) {
      print(e.toString());
    }

    print("account page");
    razorpay.clear();
    Provider.of<UserDetails>(context, listen: false)
        .setnoOfPaper(global.subPlan);

    Provider.of<UserDetails>(context, listen: false).setnoOfPaper(global.group);
    QuerySnapshot qs = await Firestore.instance
        .collection("Group" + global.group)
        .orderBy("name")
        .getDocuments();
    print("doc");
    Provider.of<UserDetails>(context, listen: false).setQuery(qs);
    Navigator.pushReplacementNamed(context, '/bottombar');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "ERROR: " + response.code.toString() + " - " + response.message,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: "EXTERNAL_WALLET: " + response.walletName,
    );
  }

  print("Just came to checkout3 function");
  var threemonths = {
    'key': 'rzp_live_A94dLEeQb2Cj5s',
    'currency': "INR",
    'amount': 120, //in the smallest currency sub-unit.
    'name': 'Nutshell',
    'description': 'Nutshell Subscription',
    'prefill': {'contact': '+91' + global.phone, 'email': global.email}
  };
  try {
    print("Trying to go to razorpay");
    razorpay.open(threemonths);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  } catch (e) {
    print("catch block jp");
    debugPrint(e);
  }
}

void openCheckoutyear(BuildContext context) async {
  _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(
      msg: "SUCCESS: " + response.paymentId,
    );

    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      print("current user id");
      print(user.uid);

      final Firestore fireStore = Firestore.instance;
      DateTime expiryDate = DateTime.now().add(Duration(days: 365));
      await fireStore
          .collection("users")
          .document(user.uid)
          .updateData({"subPlan": global.subPlan, "subscription": true});
      print("updated");
    } catch (e) {
      print(e.toString());
    }

    print("account page");
    razorpay.clear();
    Provider.of<UserDetails>(context, listen: false)
        .setnoOfPaper(global.subPlan);

    Provider.of<UserDetails>(context, listen: false).setnoOfPaper(global.group);
    QuerySnapshot qs = await Firestore.instance
        .collection("Group" + global.group)
        .orderBy("name")
        .getDocuments();
    print("doc");
    Provider.of<UserDetails>(context, listen: false).setQuery(qs);
    Navigator.pushReplacementNamed(context, '/bottombar');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "ERROR: " + response.code.toString() + " - " + response.message,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: "EXTERNAL_WALLET: " + response.walletName,
    );
  }

  print("Just came to checkoutyear function");
  var oneyear = {
    'key': 'rzp_live_A94dLEeQb2Cj5s',
    'currency': "INR",
    'amount': 130, //in the smallest currency sub-unit.
    'name': 'Nutshell',
    'description': 'Nutshell Subscription',
    'prefill': {'contact': '+91' + global.phone, 'email': global.email}
  };
  try {
    print("Trying to go to razorpay");
    razorpay.open(oneyear);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  } catch (e) {
    print("catch block jp");
    debugPrint(e);
  }
}

void openCheckoutweek(BuildContext context) async {
  // _handlePaymentSuccess(PaymentSuccessResponse response) async {
  //   // String selectedPlan=global.subPlan;
  //   Fluttertoast.showToast(
  //     msg: "SUCCESS: " + response.paymentId,
  //   );

  try {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    print("current user id");
    print(user.uid);

    final Firestore fireStore = Firestore.instance;
    DateTime expiryDate = DateTime.now().add(Duration(days: 7));
    await fireStore.collection("users").document(user.uid).updateData({
      "subPlan": global.subPlan,
      "subscription": true,
      "expiryDate": expiryDate
    });
    print("updated");
  } catch (e) {
    print(e.toString());
  }

//     print("account page");
//     razorpay.clear();
//     Provider.of<UserDetails>(context, listen: false)
//         .setnoOfPaper(global.subPlan);

//     Provider.of<UserDetails>(context, listen: false).setnoOfPaper(global.group);
//     QuerySnapshot qs = await Firestore.instance
//         .collection("Group" + global.group)
//         .orderBy("name")
//         .getDocuments();
//     print("doc");
//     Provider.of<UserDetails>(context, listen: false).setQuery(qs);
//     Navigator.pushReplacementNamed(context, '/bottombar');
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     Fluttertoast.showToast(
//       msg: "ERROR: " + response.code.toString() + " - " + response.message,
//     );
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     Fluttertoast.showToast(
//       msg: "EXTERNAL_WALLET: " + response.walletName,
//     );
//   }

//   print("Just came to checkout functionfds");
//   print(global.phone);
//   var oneweek = {
//     'key': 'rzp_live_A94dLEeQb2Cj5s',
//     'currency': "INR",
//     'amount': 00, //in the smallest currency sub-unit.
//     'name': 'Nutshell',
//     'description': 'Nutshell Subscription',
//     'prefill': {'contact': '+91' + global.phone, 'email': global.email}
//   };
//   try {
//     print("Trying to go to razorpay");
//   } catch (e) {
//     print("catch block jp");
//     debugPrint(e);
//   }
// }

// void _handlePaymentError(PaymentFailureResponse response) {
//   Fluttertoast.showToast(
//     msg: "ERROR: " + response.code.toString() + " - " + response.message,
//   );
// }

// void _handleExternalWallet(ExternalWalletResponse response) {
//   Fluttertoast.showToast(
//     msg: "EXTERNAL_WALLET: " + response.walletName,
//   );
}
