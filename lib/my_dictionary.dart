import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:firebase_database/firebase_database.dart';

import 'my_dictionary_details.dart';

class MyDictionaryPage extends StatefulWidget {
  const MyDictionaryPage({super.key});

  @override
  State<MyDictionaryPage> createState() => _MyDictionaryPageState();
}

class _MyDictionaryPageState extends State<MyDictionaryPage> {
  final _dictionaryNameController = TextEditingController();
  final _searchDictionaryController = TextEditingController();

  @override
  void dispose() {
    _dictionaryNameController.dispose();
    _searchDictionaryController.dispose();
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
  Future<void> _createDictionary() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userKey = prefs.getString('userKey');

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Dictionary'),
          content: TextFormField(
            keyboardType: TextInputType.text,
            controller: _dictionaryNameController, //This will obscure text dynamically
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Dictionary Name',
              hintText: 'Enter your Dictionary Name',
              // Here is key idea
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () async {
                var key = "";
                try {
                  setState(() {
                    key = FirebaseDatabase.instance.ref("iot_dictionary/users/$userKey/kamus/").push().key.toString();
                  });
                  print(key);
                  FirebaseDatabase.instance.ref("iot_dictionary/users/$userKey/kamus/$key").set({
                    "dictKey": key,
                    "dictName": _dictionaryNameController.text,
                    "vocabLists": {},
                  });
                  print("Push data to firebase succeed!");
                  Navigator.of(context).pop();
                  _showMyDialog("Berhasil", "Kamus berhasil dibuat!");
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
  Future<void> _confirmDelete() async {
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
                  print(dictKey);
                  FirebaseDatabase.instance.ref("iot_dictionary/users/$userKey/kamus/$dictKey/").remove();
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
  Future<void> _editDictionary(dictName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userKey = prefs.getString('userKey');
    final String? dictKey = prefs.getString('dictKey');

    setState(() {
      _dictionaryNameController.text = dictName;
    });

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Dictionary'),
          content: TextFormField(
            keyboardType: TextInputType.text,
            controller: _dictionaryNameController, //This will obscure text dynamically
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Dictionary Name',
              hintText: 'Enter your Dictionary Name',
              // Here is key idea
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Edit'),
              onPressed: () async {
                try {
                  FirebaseDatabase.instance.ref("iot_dictionary/users/$userKey/kamus/$dictKey").update({
                    "dictName": _dictionaryNameController.text,
                  });
                  Navigator.of(context).pop();
                  _showMyDialog("Berhasil", "Kamus berhasil diedit!");
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
  Future<dynamic> getMyDictionaries() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userKey = prefs.getString('userKey');
    var myDictionaries = [];

    final ref = FirebaseDatabase.instance.ref();
    await ref.child('iot_dictionary/users/$userKey/kamus').get().then((snapshot) {
      for (final kamus in snapshot.children) {
        if (_searchDictionaryController.text.trim() == "") {
          setState(() {
            myDictionaries.add({
              "dictKey": kamus.child("dictKey").value,
              "dictName": kamus.child("dictName").value,
              "listsTotal": (kamus.child("vocabLists").value != null) ? myDictVocabListsTotalChecker(kamus.child("vocabLists")) : 0,
            });
          });
        } else {
          if (kamus.child("dictName").value.toString().contains(_searchDictionaryController.text)) {
            myDictionaries.add({
              "dictKey": kamus.child("dictKey").value,
              "dictName": kamus.child("dictName").value,
              "listsTotal": (kamus.child("vocabLists").value != null) ? myDictVocabListsTotalChecker(kamus.child("vocabLists")) : 0,
            });
          }
        }
      }
    }, onError: (error) {
      print("164" + error.toString());
    });

    return myDictionaries;
  }

  Future myDictionariesChecker() async {
    var vocabResults = await getMyDictionaries();
    if (vocabResults.isNotEmpty) {
      setState(() {});
      return vocabResults;
    } else {
      setState(() {});
      return "";
    }
  }

  int myDictVocabListsTotalChecker(vocabLists) {
    var lists_length = 0;
    // print();
    vocabLists.value.forEach((key, value) {
      lists_length++;
    });
    setState(() {});
    return lists_length;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Dictionary',
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
                      Text(
                        "My Dictionary",
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Kostumasi kamus anda, dengan memasukkan list-list kata-kata yang anda butuhkan sendiri, seperti halnya playlist anda sendiri pada aplikasi musik. Fitur ini diharapkan dapat memudahkan anda untuk mempelajari kosakata-kosakata yang ingin anda pelajari.",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10,),
                      TextField(
                        controller: _searchDictionaryController,
                        onSubmitted: (searchDict) async {
                          final SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString("searchDict", searchDict);
                          print(_searchDictionaryController.text);
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Cari Kamusmu',
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
                            setState(() {
                              _dictionaryNameController.text = "";
                            });
                            _createDictionary();
                            print("Tambah Kamus");
                          },
                          child: Text(
                            "Tambah Kamus",
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
                        future: myDictionariesChecker(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data != "") {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10,),
                                  for (final dict in snapshot.data)
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
                                                    print("detail kamus");
                                                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                                                    await prefs.setString("dictKey", dict["dictKey"]);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => const MyDictionaryDetailsPage()),
                                                    );
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            dict["dictName"],
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          SizedBox(height: 5,),
                                                          Text(
                                                            "Total Vocabs: " + dict["listsTotal"].toString(),
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ],
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
                                                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                                                      await prefs.setString("dictKey", dict["dictKey"]);
                                                      _confirmDelete();
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
                                                      print("edit kamus");
                                                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                                                      await prefs.setString("dictKey", dict["dictKey"]);
                                                      _editDictionary(dict["dictName"]);
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
                                    child: Center(child: Text("You Do Not Have Any Dictionary"),),
                                  ),
                                  Divider(
                                      color: Colors.black
                                  ),
                                ],
                              );
                            }
                          } else {
                            return const LoadingIndicator(
                                indicatorType: Indicator.ballPulse, /// Required, The loading type of the widget
                                colors: const [Colors.black],       /// Optional, The color collections
                                strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
                                backgroundColor: Colors.white,      /// Optional, Background of the widget
                                pathBackgroundColor: Colors.white   /// Optional, the stroke backgroundColor
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