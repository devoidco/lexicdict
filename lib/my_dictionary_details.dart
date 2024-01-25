import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:firebase_database/firebase_database.dart';

import 'search_result.dart';
import 'vocab_detail.dart';

class MyDictionaryDetailsPage extends StatefulWidget {
  const MyDictionaryDetailsPage({super.key});

  @override
  State<MyDictionaryDetailsPage> createState() => _MyDictionaryDetailsPageState();
}

class _MyDictionaryDetailsPageState extends State<MyDictionaryDetailsPage> {
  final _searchListsController = TextEditingController();

  @override
  void dispose() {
    _searchListsController.dispose();
    super.dispose();
  }

  Future<void> _showMyDialog(title, desc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$title'),
          content: Text('$desc'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _confirmDelete(dictVocabKey) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userKey = prefs.getString('userKey');
    final String? dictKey = prefs.getString('dictKey');

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Dictionary'),
          content: const Text("Yakin ingin menghapus kamus?"),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                try {
                  FirebaseDatabase.instance.ref("iot_dictionary/users/$userKey/kamus/$dictKey/vocabLists/$dictVocabKey").remove();
                  Navigator.of(context).pop();
                  _showMyDialog("Berhasil", "Kamus berhasil dihapus!");
                  setState(() {});
                } catch(error) {
                  print("firebase: $error");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> getMyDictionaryDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userKey = prefs.getString('userKey');
    final String? dictKey = prefs.getString('dictKey');

    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('iot_dictionary/users/$userKey/kamus/$dictKey').get();

    if (snapshot.exists) {
      return snapshot;
    } else {
      print('No data available.');
      return "";
    }
  }
  Future<dynamic> getMyDictVocabDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userKey = prefs.getString('userKey');
    final String? dictKey = prefs.getString('dictKey');

    var myLists = [];
    var vocabLists = await FirebaseDatabase.instance.ref().child('iot_dictionary/users/$userKey/kamus/$dictKey/vocabLists/').get();
    await FirebaseDatabase.instance.ref().child('iot_dictionary/vocabs/tkj').get().then((snapshot) {
      for (var dictVocab in vocabLists.children) {
        for (final vocab in snapshot.children) {
          if (_searchListsController.text == "") {
            if (dictVocab.child("vocabActualKey").value.toString() == vocab.child("key").value.toString()) {
              myLists.add({
                "dictVocabKey": dictVocab.child("dictVocabKey").value,
                "vocabKey": vocab.child("key").value,
                "vocabTitle": vocab.child("title").value,
              });
            }
          } else {
            if (dictVocab.child("vocabActualKey").value.toString() == vocab.child("key").value.toString() && vocab.child("title").value.toString().contains(_searchListsController.text.toString())) {
              myLists.add({
                "dictVocabKey": dictVocab.child("dictVocabKey").value,
                "vocabKey": vocab.child("key").value,
                "vocabTitle": vocab.child("title").value,
              });
            }
          }
        }
      }
    }, onError: (error) {
      setState(() {});
      print("164" + error.toString());
    });

    setState(() {});
    return myLists;
  }

  Future dictNameChecker() async {
    var dictDetails = await getMyDictionaryDetails();
    if (dictDetails != "") {
      return dictDetails.child("dictName").value;
    } else {
      return "";
    }
  }
  Future myDictVocabListsTotalChecker() async {
    var dictDetails = await getMyDictionaryDetails();
    if (dictDetails != "") {
      var lists_length = 0;
      if (dictDetails.child("vocabLists").value != null) {
        dictDetails.child("vocabLists").value.forEach((key, value) {
          lists_length++;
        });
      }
      return lists_length;
    } else {
      return "";
    }
  }
  Future myDictVocabListsChecker() async {
    var vocabLists = await getMyDictVocabDetails();
    if (vocabLists != "") {
      return vocabLists;
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Details Dictionary',
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          primarySwatch: Colors.red,
          fontFamily: 'Open_Sans'
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 10),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/bg2.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: FutureBuilder(
                            future: dictNameChecker(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data != "") {
                                  return Text(
                                    snapshot.data,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 40,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                } else {
                                  return Text(
                                    "Loading...",
                                    style: TextStyle(
                                      fontSize: 40,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                              } else {
                                return Transform.scale(
                                  scale: 0.1,
                                  child: LoadingIndicator(
                                      indicatorType: Indicator.ballPulse, /// Required, The loading type of the widget
                                      colors: const [Colors.black],       /// Optional, The color collections
                                      strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
                                      backgroundColor: Colors.transparent,      /// Optional, Background of the widget
                                      pathBackgroundColor: Colors.transparent   /// Optional, the stroke backgroundColor
                                  ),
                                );
                              }
                            },
                          ),
                          ),
                          Flexible(
                            child: FutureBuilder(
                              future: myDictVocabListsTotalChecker(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data != "") {
                                    return Text(
                                      snapshot.data.toString() + " Kosakata",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  } else {
                                    return Text(
                                      "Loading...",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                } else {
                                  return Transform.scale(
                                    scale: 0.1,
                                    child: LoadingIndicator(
                                        indicatorType: Indicator.ballPulse, /// Required, The loading type of the widget
                                        colors: const [Colors.black],       /// Optional, The color collections
                                        strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
                                        backgroundColor: Colors.transparent,      /// Optional, Background of the widget
                                        pathBackgroundColor: Colors.transparent   /// Optional, the stroke backgroundColor
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Text(
                        "Seperti layaknya anda menambahkan lagu ke playlist pribadi anda, tambahkan kosakata-kosakata yang ingin anda pelajari untuk kamus pribadi anda.",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10,),
                      TextField(
                        controller: _searchListsController,
                        onSubmitted: (searchList) async {
                          final SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString("searchList", searchList);
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Cari Kosakatamu',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFF7272),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MySearchResultPage()),
                            );
                          },
                          child: Text(
                            "Tambah Kosakata",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const Divider(
                          color: Colors.black
                      ),
                      FutureBuilder(
                        future: myDictVocabListsChecker(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data != "") {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10,),
                                  for (final vocab in snapshot.data)
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                                                    await prefs.setString("vocabKey", vocab["vocabKey"]);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => const MyVocabDetailPage()),
                                                    );
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        vocab["vocabTitle"],
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.all(5),
                                                        margin: const EdgeInsets.only(right: 10),
                                                        child: Icon(
                                                          Icons.visibility,
                                                          color: Theme.of(context).primaryColorDark,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      _confirmDelete(vocab["dictVocabKey"]);
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.all(5),
                                                      margin: const EdgeInsets.only(right: 10),
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: Theme.of(context).primaryColorDark,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20,),
                                          Divider(
                                              color: Colors.black
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                                    child: Center(child: Text("You Do Not Have Any Vocab Lists Yet"),),
                                  ),
                                  Divider(
                                      color: Colors.black
                                  ),
                                ],
                              );
                            }
                          } else {
                            return Transform.scale(
                              scale: 0.1,
                              child: LoadingIndicator(
                                  indicatorType: Indicator.ballPulse, /// Required, The loading type of the widget
                                  colors: const [Colors.black],       /// Optional, The color collections
                                  strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
                                  backgroundColor: Colors.transparent,      /// Optional, Background of the widget
                                  pathBackgroundColor: Colors.transparent   /// Optional, the stroke backgroundColor
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('dictKey');
            await prefs.remove('searchDict');
            Navigator.pop(context);
          },
          backgroundColor: Color(0xFFFF7272),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}