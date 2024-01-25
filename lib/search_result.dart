import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:firebase_database/firebase_database.dart';

import 'vocab_detail.dart';

class MySearchResultPage extends StatefulWidget {
  const MySearchResultPage({super.key});

  @override
  State<MySearchResultPage> createState() => _MySearchResultPageState();
}

class _MySearchResultPageState extends State<MySearchResultPage> {
  final _searchVocabController = TextEditingController();
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    searchFieldInitValue();
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _searchVocabController.dispose();
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

  Future<dynamic> getVocabResults() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? searchVocab = prefs.getString('searchVocab');
    var vocabResults = [];

    final ref = FirebaseDatabase.instance.ref();
    await ref.child('iot_dictionary/vocabs/tkj').get().then((snapshot) {
      for (final vocab in snapshot.children) {
        if (searchVocab.toString() == "all_special") {
          setState(() {
            vocabResults.add({
              "title": vocab.child("title").value,
              "key": vocab.child("key").value
            });
          });
        } else {
          if (vocab.child("en_term").value!.toString().contains(searchVocab.toString())) {
            setState(() {
              vocabResults.add({
                "title": vocab.child("title").value,
                "key": vocab.child("key").value
              });
            });
          }
        }
      }
    }, onError: (error) {
      // print("164" + error.toString());
    });

    return vocabResults;
  }
  Future<dynamic> _addToMyDictionary(vocabKey) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userKey = prefs.getString('userKey');
    final String? dictKey = prefs.getString('dictKey');

    var key = "";
    try {
      setState(() {
        key = FirebaseDatabase.instance.ref("iot_dictionary/users/$userKey/kamus/$dictKey/vocabLists/").push().key.toString();
      });
      print(key);
      FirebaseDatabase.instance.ref("iot_dictionary/users/$userKey/kamus/$dictKey/vocabLists/$key").set({
        "dictVocabKey": key,
        "vocabActualKey": vocabKey,
      });
      print("Push data to firebase succeed!");
      _showMyDialog("Berhasil", "Ditambahkan ke kamus");
      setState(() {});
    } catch(error) {
      print("firebase: $error");
    }

  }

  Future vocabResultsCechker() async {
    var vocabResults = await getVocabResults();
    if (vocabResults.isNotEmpty) {
      setState(() {});
      return vocabResults;
    } else {
      setState(() {});
      return "";
    }
  }
  Future fromDictDetailsChecker() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? dictKey = prefs.getString('dictKey');
    if (dictKey != null) {
      return true;
    } else {
      return "";
    }
  }

  Future searchFieldInitValue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? searchVocab = prefs.getString('searchVocab');

    if (searchVocab != "all_special") {
      _searchVocabController.text = searchVocab!;
    }

  }
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }
  void _onSpeechResult(SpeechRecognitionResult result) async {
    setState(() {
      _lastWords = result.recognizedWords;
      _searchVocabController.text = _lastWords;
    });

    if (_speechToText.isNotListening) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("searchVocab", _lastWords);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocab Search Results',
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          primarySwatch: Colors.red,
          fontFamily: 'Open_Sans'
      ),
      home: Scaffold(
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 10),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg1.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchVocabController,
                    onSubmitted: (searchVocab) async {
                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString("searchVocab", searchVocab);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Cari Kosakata',
                      suffixIcon: IconButton(
                        onPressed: () async {
                          if (_speechToText.isNotListening) {
                            _startListening();
                          } else {
                            _stopListening();
                          }
                        },
                        icon: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    child: const Text(
                        "Search Results:",
                        style: TextStyle(color: Colors.white)
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  constraints: BoxConstraints(
                    maxHeight: double.infinity,
                  ),
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: FutureBuilder(
                    future: vocabResultsCechker(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data != "") {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 30,),
                              for (final vocab in snapshot.data)
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                final SharedPreferences prefs = await SharedPreferences.getInstance();
                                                await prefs.setString("vocabKey", vocab["key"]);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => const MyVocabDetailPage()),
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.fromLTRB(10, 10, 10, 25),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(vocab["title"]),
                                                    Icon(
                                                      Icons.visibility,
                                                      color: Theme.of(context).primaryColorDark,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          FutureBuilder(
                                            future: fromDictDetailsChecker(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                if (snapshot.data != "") {
                                                  return Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () async {
                                                          _addToMyDictionary(vocab["key"]);
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.only(top: 10, bottom: 25, left: 5),
                                                          margin: const EdgeInsets.only(right: 10, left: 5),
                                                          child: Icon(
                                                            Icons.add,
                                                            color: Theme.of(context).primaryColorDark,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                } else {
                                                  return Text("");
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
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                                child: Text("Data Not Found"),
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
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('searchVocab');
            await prefs.remove('fromListKosakataMenu');
            Navigator.pop(context);
          },
          backgroundColor: const Color(0xFFFF7272),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}