import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class UserDetails extends ChangeNotifier {
  String _grpName;

  int _noOfPaper;
  int get noOfPaper => _noOfPaper;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  void changeIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  List<DocumentSnapshot> _topicDoc;
  List<DocumentSnapshot> get topicDoc => _topicDoc;
  void topicDocs(List<DocumentSnapshot> ds) {
    _topicDoc = ds;
    notifyListeners();
  }

  QuerySnapshot _q;
  List<MapEntry<String, dynamic>> _topicList;
  List<MapEntry<String, dynamic>> get topicL => _topicList;
  void sortedList(List<MapEntry<String, dynamic>> list) {
    _topicList = list;
    notifyListeners();
  }

  String get grpName => _grpName;

  void onGrpTap(String grp) {
    _grpName = grp;
    notifyListeners();
  }

  setnoOfPaper(String plan) {
    switch (plan) {
      case "f":
        _noOfPaper = 2;
        break;
      case "b":
        _noOfPaper = 3;
        break;
      case "s":
        _noOfPaper = 5;
        break;
      case "p":
        _noOfPaper = 8;
        break;
    }
    notifyListeners();
  }

  DocumentSnapshot _doc;
  DocumentSnapshot get doc => _doc;

  void onPaperTap(DocumentSnapshot d) {
    _doc = d;
    notifyListeners();
  }

  QuerySnapshot get qs => _q;
  void setQuery(QuerySnapshot q) {
    _q = q;
    notifyListeners();
  }

  int _topicIndex;

  int get topicIndex => _topicIndex;
  void topicTap(int ind) {
    _topicIndex = ind;
    notifyListeners();
  }
}
