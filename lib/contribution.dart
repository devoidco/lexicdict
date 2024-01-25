import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:firebase_database/firebase_database.dart';

import 'vocab_detail.dart';
import 'create_contribution.dart';

class MyContributionPage extends StatefulWidget {
  const MyContributionPage({super.key});

  @override
  State<MyContributionPage> createState() => _MyContributionPageState();
}

class _MyContributionPageState extends State<MyContributionPage> {
  final _searchYourVocabsController = TextEditingController();

  @override
  void dispose() {
    _searchYourVocabsController.dispose();
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
  Future<void> _confirmDelete(contribKey, vocabKey) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userKey = prefs.getString('userKey');

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Dictionary'),
          content: const Text("Yakin ingin menghapus kosakata?"),
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
                print(contribKey);
                try {
                  FirebaseDatabase.instance.ref("iot_dictionary/users/$userKey/kontribusi/$contribKey").remove();
                  Navigator.of(context).pop();
                  setState(() {});
                } catch(error) {
                  print("firebase: $error");
                }

                try {
                  FirebaseDatabase.instance.ref("iot_dictionary/vocabs/tkj/$vocabKey").remove();
                  _showMyDialog("Berhasil", "Kosakata berhasil dihapus!");
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

  Future<dynamic> getContribDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userKey = prefs.getString('userKey');

    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('iot_dictionary/users/$userKey/kontribusi/').get();

    if (snapshot.exists) {
      return snapshot;
    } else {
      return 0;
    }
  }
  Future<dynamic> getContribVocabDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userKey = prefs.getString('userKey');

    var myLists = [];
    var contribLists = await FirebaseDatabase.instance.ref().child('iot_dictionary/users/$userKey/kontribusi/').get();
    await FirebaseDatabase.instance.ref().child('iot_dictionary/vocabs/tkj').get().then((snapshot) {
      for (var dictContrib in contribLists.children) {
        for (final vocab in snapshot.children) {
          if (_searchYourVocabsController.text == "") {
            if (dictContrib.child("vocabKey").value.toString() == vocab.child("key").value.toString()) {
              myLists.add({
                "contribKey": dictContrib.child("contribKey").value,
                "vocabKey": vocab.child("key").value,
                "vocabTitle": vocab.child("title").value,
              });
            }
          } else {
            if (dictContrib.child("vocabKey").value.toString() == vocab.child("key").value.toString() && vocab.child("title").value.toString().contains(_searchYourVocabsController.text.toString())) {
              myLists.add({
                "contribKey": dictContrib.child("contribKey").value,
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

  Future myDictContribTotalChecker() async {
    var contribDetails = await getContribDetails();
    var lists_length = 0;
    if (contribDetails != 0) {
      if (contribDetails.value != 0) {
        contribDetails.value.forEach((key, value) {
          lists_length++;
        });
      }
    }
    return lists_length;
  }
  Future myDictContribChecker() async {
    var contribLists = await getContribVocabDetails();
    if (contribLists != "") {
      return contribLists;
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contributions',
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
                          Text(
                            "Contribs",
                            style: TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Flexible(
                            child: FutureBuilder(
                              future: myDictContribTotalChecker(),
                              builder: (context, snapshot) {
                                // print(snapshot.data);
                                if (snapshot.hasData) {
                                  // print(snapshot.data.toString());
                                  return Text(
                                    snapshot.data.toString() + " Kontribusi",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
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
                        "Seperti layaknya anda dapat mengupload lagu anda pada sebuah platform musik, di sini anda dapat menambahkan kosakata-kosakata yang anda baru temukan dan belum terdapat pada kamus ini.",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10,),
                      TextField(
                        controller: _searchYourVocabsController,
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
                              MaterialPageRoute(builder: (context) => const MyCreateContributionPage()),
                            );
                          },
                          child: Text(
                            "Buat Kontribusi Kosakata",
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
                        future: myDictContribChecker(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data != "") {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10,),
                                  for (final contrib in snapshot.data)
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
                                                    await prefs.setString("vocabKey", contrib["vocabKey"]);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => const MyVocabDetailPage()),
                                                    );
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        contrib["vocabTitle"],
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
                                                      _confirmDelete(contrib["contribKey"], contrib["vocabKey"]);
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
                                                  GestureDetector(
                                                    onTap: () async {
                                                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                                                      await prefs.setBool("edit", true);
                                                      await prefs.setString("vocabKey", contrib["vocabKey"]);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => const MyCreateContributionPage()),
                                                      );
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.all(5),
                                                      margin: const EdgeInsets.only(right: 10),
                                                      child: Icon(
                                                        Icons.edit,
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