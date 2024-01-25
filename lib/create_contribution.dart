import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_database/firebase_database.dart';

class MyCreateContributionPage extends StatefulWidget {
  const MyCreateContributionPage({super.key});

  @override
  State<MyCreateContributionPage> createState() => _MyCreateContributionPageState();
}

class _MyCreateContributionPageState extends State<MyCreateContributionPage> {
  var pageTitle = "";
  var buttonText = "";

  final _titleController = TextEditingController();
  final _enTermController = TextEditingController();
  final _descController = TextEditingController();
  final _imgController = TextEditingController();
  final _sourceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkIfEdit();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _enTermController.dispose();
    _descController.dispose();
    _imgController.dispose();
    _sourceController.dispose();
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
              onPressed: () async {
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('edit');

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future createVocabContribution() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userKey = prefs.getString('userKey');
    var author = await FirebaseDatabase.instance.ref().child('iot_dictionary/users/$userKey/username').get();

    var vocabKey = "";
    try {
      setState(() {
        vocabKey = FirebaseDatabase.instance.ref("iot_dictionary/vocabs/tkj/").push().key.toString();
      });
      print(vocabKey);
      FirebaseDatabase.instance.ref("iot_dictionary/vocabs/tkj/$vocabKey").set({
        "key": vocabKey,
        "title": _titleController.text,
        "en_term": _enTermController.text,
        "desc": _descController.text,
        "img": _imgController.text,
        "source": _sourceController.text,
        "author": author.value,
      });
      print("Push data to firebase succeed!");
      setState(() {});
    } catch(error) {
      print("firebase: $error");
    }

    var contribKey = "";
    try {
      setState(() {
        contribKey = FirebaseDatabase.instance.ref("iot_dictionary/users/$userKey/kontribusi/").push().key.toString();
      });
      print(contribKey);
      FirebaseDatabase.instance.ref("iot_dictionary/users/$userKey/kontribusi/$contribKey").update({
        "contribKey": contribKey,
        "vocabKey": vocabKey,
      });
      print("Push data to firebase succeed!");
      _showMyDialog("Berhasil", "Kosakata berhasil dibuat!").then((value) {
        Navigator.of(context).pop();
      });
      setState(() {});
    } catch(error) {
      print("firebase: $error");
    }
  }
  Future editVocabContribution() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? vocabKey = prefs.getString('vocabKey');

    try {
      FirebaseDatabase.instance.ref("iot_dictionary/vocabs/tkj/$vocabKey").update({
        "title": _titleController.text,
        "en_term": _enTermController.text,
        "desc": _descController.text,
        "img": _imgController.text,
        "source": _sourceController.text,
      });
      print("Update data to firebase succeed!");
      _showMyDialog("Berhasil", "Kosakata berhasil diedit!").then((value) {
        Navigator.of(context).pop();
      });
      setState(() {});
    } catch(error) {
      print("firebase: $error");
    }
  }

  Future<void> checkIfEdit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? edit = prefs.getBool('edit');
    final String? vocabKey = prefs.getString('vocabKey');

    if (edit != null && edit == true) {
      pageTitle = "Edit Contribution";
      buttonText = "Edit Kosakata";
      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('iot_dictionary/vocabs/tkj/$vocabKey/').get();

      if (snapshot.exists) {
        _titleController.text = snapshot.child("title").value.toString();
        _enTermController.text = snapshot.child("en_term").value.toString();
        _descController.text = snapshot.child("desc").value.toString();
        _imgController.text = snapshot.child("img").value.toString();
        _sourceController.text = snapshot.child("source").value.toString();
      }
    } else {
      pageTitle = "Create Contribution";
      buttonText = "Daftar Kosakata";
      _titleController.text = "";
      _enTermController.text = "";
      _descController.text = "";
      _imgController.text = "";
      _sourceController.text = "";
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: pageTitle,
      theme: ThemeData(
          primarySwatch: Colors.red,
          fontFamily: 'Open_Sans'
      ),
      home: Scaffold(
        // resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(20, 80, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    pageTitle,
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  SizedBox(height: 25,),
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: _titleController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Title',
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: _enTermController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'English Term',
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: _descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Descriptions',
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: _imgController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Image Link',
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: _sourceController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Source Link',
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFF7272),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                        final bool? edit = prefs.getBool('edit');

                        if (edit != null && edit == true) {
                          editVocabContribution();
                        } else {
                          createVocabContribution();
                        }
                      },
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('edit');
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