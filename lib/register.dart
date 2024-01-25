import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_database/firebase_database.dart';

import 'dart:math';

import 'activation.dart';
import 'login.dart';

class MyRegisterPage extends StatefulWidget {
  const MyRegisterPage({super.key});

  @override
  State<MyRegisterPage> createState() => _MyRegisterPageState();
}

class _MyRegisterPageState extends State<MyRegisterPage> {
  bool _errorMessage = false;
  bool _passwordVisible = false;

  final _userUsernameController = TextEditingController();
  final _userNimController = TextEditingController();
  final _userEmailController = TextEditingController();
  final _userPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _errorMessage = false;
    _passwordVisible = false;
  }

  @override
  void dispose() {
    _errorMessage = false;
    _userUsernameController.dispose();
    _userNimController.dispose();
    _userEmailController.dispose();
    _userPasswordController.dispose();
    super.dispose();
  }

  Future<dynamic> checkEmailExists(passed_email_data) async {
    var email_exists = false;
    try {
      final ref = FirebaseDatabase.instance.ref();
      await ref.child('iot_dictionary/users/').get().then((snapshot) {
        for (final user in snapshot.children) {
          if (user.child("email").value == passed_email_data) {
            print("Ada email yang sama");
            setState(() {
              email_exists = true;
            });
          } else {
            print("Tidak ada email yang sama");
            setState(() {
              email_exists = false;
            });
          }
        }
      }, onError: (error) {
        print(StackTrace.current.toString() + error.toString());
      });
    } catch(error) {
      print(StackTrace.current.toString() + "firebase: $error");
      _errorMessage = true;
    }
    return email_exists;
  }
  Future<dynamic> checkNimExists(passed_nim_data) async {
    var nim_exists = false;
    try {
      final ref = FirebaseDatabase.instance.ref();
      await ref.child('iot_dictionary/users/').get().then((snapshot) {
        for (final user in snapshot.children) {
          if (user.child("nim").value == passed_nim_data) {
            print("Ada nim yang sama");
            setState(() {
              nim_exists = true;
            });
          } else {
            print("Tidak ada nim yang sama");
            setState(() {
              nim_exists = false;
            });
          }
        }
      }, onError: (error) {
        print(StackTrace.current.toString() + error.toString());
      });
    } catch(error) {
      print(StackTrace.current.toString() + "firebase: $error");
      _errorMessage = true;
    }
    return nim_exists;
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

  void _sendToEmail(email, subject, code) async {
    final serviceId = 'service_rt5vnqi';
    final templateId = 'template_4xfxhi7';
    final publicKey = '4sxbBNqiwArW3sj3I';
    final privateKey = '1iEiQAqotcJyvMS0jAxi3';

    Map<String, dynamic> templateParams = {
      'user_subject': 'LexicDict Account Registration',
      'user_message': 'Your Activation Code' + code.toString(),
    };

    try {
      final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
      await http.post(
          url,
          headers: {
            'origin': 'http://localhost',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'service_id': serviceId,
            'template_id': templateId,
            'user_id': publicKey,
            'template_params': {
              'user_subject': 'LexicDict Account Registration',
              'user_message': 'Your Activation Code: ' + code.toString(),
              'user_email': email,
            }
          }),
      );
      print('SUCCESS!');
    } catch (error) {
      print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register LexicDict',
      theme: ThemeData(
          primarySwatch: Colors.red,
          fontFamily: 'Open_Sans'
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(20, 150, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Daftarkan Akun Anda",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  SizedBox(height: 40,),
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: _userUsernameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Username',
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: _userNimController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'NIM',
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: _userEmailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Email',
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _userPasswordController,
                    obscureText: !_passwordVisible,//This will obscure text dynamically
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      // Here is key idea
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Sudah Punya Akun?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MyLoginPage()),
                          );
                        },
                        child: Text ("Login"),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFF7272),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        var code = 0;
                        var key = "";
                        if (_userUsernameController.text.trim() == "") {
                          _showMyDialog("Error", "Username Harus Diisi!");
                        } else if (_userNimController.text.trim() == "") {
                        _showMyDialog("Error", "NIM Harus Diisi!");
                        } else if (_userEmailController.text.trim().contains('@') != true) {
                          _showMyDialog("Error", "Masukkan Email yang Valid!");
                        } else if (_userPasswordController.text.length < 8) {
                          _showMyDialog("Error", "Gunakan Password yang Lebih Panjang!");
                        } else {
                          var email_exist = await checkEmailExists(_userEmailController.text);
                          print(email_exist);

                          if (email_exist) {
                            _showMyDialog("Error", "Email Telah Terdaftar!");
                          } else {
                            var nim_exist = await checkNimExists(_userNimController.text);
                            print(nim_exist);

                            if (nim_exist) {
                              _showMyDialog("Error", "NIM Telah Terdaftar!");
                            } else {
                              var rng = new Random();
                              setState(() {
                                code = rng.nextInt(900000) + 100000;
                              });
                              print(code);
                              try {
                                setState(() {
                                  key = FirebaseDatabase.instance.ref("iot_dictionary/users/").push().key.toString();
                                });
                                print(key);
                                FirebaseDatabase.instance.ref("iot_dictionary/users/$key").set({
                                  "userKey": key,
                                  "username": _userUsernameController.text,
                                  "nim": _userNimController.text,
                                  "email": _userEmailController.text,
                                  "password": _userPasswordController.text,
                                  "active": 0,
                                  "activationCode": code,
                                });
                                print("Push data to firebase succeed!");
                              } catch(error) {
                                print("firebase: $error");
                                _errorMessage = true;
                              }
                              if (_errorMessage != true) {
                                try {
                                  _sendToEmail(_userEmailController.text, 'LexicDict Account Registration', code);
                                } catch(error) {
                                  print(error);
                                  _errorMessage = true;
                                }
                              }
                              if (_errorMessage != true) {
                                try {
                                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.setInt('actCode', code);
                                  await prefs.setString('init_time', "${DateTime.now()}");
                                  await prefs.setString("userKey", key);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const MyActivationPage()),
                                  );
                                } catch(error) {
                                  print(error);
                                  _errorMessage = true;
                                }
                              }
                            }
                          }
                        }

                        print(_userUsernameController.text);
                        print(_userNimController.text);
                        print(_userEmailController.text);
                        print(_userPasswordController.text);
                      },
                      child: Text(
                        "Daftar",
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
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          backgroundColor: Color(0xFFFF7272),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}