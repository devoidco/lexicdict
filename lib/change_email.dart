import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_database/firebase_database.dart';

class MyChangeEmailPage extends StatefulWidget {
  const MyChangeEmailPage({super.key});

  @override
  State<MyChangeEmailPage> createState() => _MyChangeEmailPageState();
}

class _MyChangeEmailPageState extends State<MyChangeEmailPage> {
  bool _passwordVisible = false;

  final _userUsernameController = TextEditingController();
  final _userEmailController = TextEditingController();
  final _userPasswordController = TextEditingController();

  @override
  void initState() {
    _passwordVisible = false;

    super.initState();
  }

  @override
  void dispose() {
    _userUsernameController.dispose();
    _userEmailController.dispose();
    _userPasswordController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manage User LexicDict',
      theme: ThemeData(
          primarySwatch: Colors.red,
          fontFamily: 'Open_Sans'
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 150, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Pengaturan Pengguna",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(height: 40,),
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: _userUsernameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Username',
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: _userEmailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _userPasswordController,
                    obscureText: !_passwordVisible,//This will obscure text dynamically
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
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
                      Text("Belum Punya Akun?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MyChangeEmailPage()),
                          );
                        },
                        child: Text("Register"),
                      ),
                    ],
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF7272),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        var login = 0;
                        var email_terdaftar = 0;
                        var userKey = '';

                        final email_login = _userEmailController.text.trim();
                        if (email_login.contains('@') != true || email_login == "") {
                          _showMyDialog("Error", "Masukkan Email yang Valid!");
                        } else if (_userPasswordController.text.length < 8) {
                          _showMyDialog("Error", "Password Tidak Valid!");
                        } else {
                          final ref = FirebaseDatabase.instance.ref();
                          await ref.child('iot_dictionary/users/').get().then((snapshot) {
                            for (final user in snapshot.children) {
                              if (user.child("email").value == email_login) {
                                setState(() { email_terdaftar = 1; });
                                if (user.child("password").value == _userPasswordController.text) {
                                  setState(() {
                                    login = 1;
                                    userKey = user.child("userKey").value.toString();
                                  });
                                } else {
                                  _showMyDialog("Error", "Password salah!");
                                }
                              }
                            }
                          }, onError: (error) {
                            print("164" + error.toString());
                          });

                          if (login == 1) {
                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setInt('login', 1);
                            await prefs.setString('userKey', userKey);
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          } else {
                            if (email_terdaftar == 0) {
                              _showMyDialog("Error", "Email tidak terdaftar!");
                            } else {
                              _showMyDialog("Error", "Gagal login!");
                            }
                          }
                        }
                      },
                      child: const Text(
                        "Simpan",
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