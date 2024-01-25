import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
// import 'package:file_picker/file_picker.dart';

import 'package:firebase_database/firebase_database.dart';

// import 'change_pass.dart';
// import 'change_email.dart';

class MyManageUserPage extends StatefulWidget {
  const MyManageUserPage({super.key});

  @override
  State<MyManageUserPage> createState() => _MyManageUserPageState();
}

class _MyManageUserPageState extends State<MyManageUserPage> {
  String username = "";

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  void dispose() {
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

  Future getUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userKey = prefs.getString('userKey');

    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('iot_dictionary/users/$userKey/').get();

    if (snapshot.exists) {
      username = snapshot.child("username").value.toString();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manage User LexicDict',
      theme: ThemeData(
          primarySwatch: Colors.red,
          fontFamily: 'Open_Sans',
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 100),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/bg3.png'),
                          fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                debugPrint("Ganti Gambar");
                              },
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: NetworkImage('https://googleflutter.com/sample_image.jpg'),
                                          fit: BoxFit.fill
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(1),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black,
                                        // borderRadius: BorderRadius.circular(6),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 30,
                                        minHeight: 30,
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFF4F4F4),
                          blurRadius: 4,
                          offset: Offset(0, 0), // Shadow position
                        ),
                      ],
                    ),
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(),
                          ),
                          child: Theme(
                            data: ThemeData().copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              title: Text('Data Diri'),
                              children: <Widget>[
                                ListTile(title: Text('$username')),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(),
                          ),
                          child: Theme(
                            data: ThemeData().copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: Text('Kelola Akun'),
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.only(bottom: 10, left: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(),
                                  ),
                                  child: Theme(
                                    data: ThemeData().copyWith(dividerColor: Colors.transparent),
                                    child: ExpansionTile(
                                      title: Text('Ganti Email'),
                                      children: <Widget>[
                                        ListTile(title: Text('This is tile number 1')),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 10, left: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(),
                                  ),
                                  child: Theme(
                                    data: ThemeData().copyWith(dividerColor: Colors.transparent),
                                    child: ExpansionTile(
                                      title: Text('Ganti Email'),
                                      children: <Widget>[
                                        ListTile(title: Text('This is tile number 1')),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 10, left: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(),
                                  ),
                                  child: Theme(
                                    data: ThemeData().copyWith(dividerColor: Colors.transparent),
                                    child: ExpansionTile(
                                      title: Text('Ganti Email'),
                                      children: <Widget>[
                                        ListTile(title: Text('This is tile number 1')),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(),
                          ),
                          child: Theme(
                            data: ThemeData().copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: Text('About'),
                              children: <Widget>[
                                ListTile(title: Text('Halaman ini merupakan halaman pengaturan pengguna, fitur-fitur di halaman ini mungkin belum selesai semua. Oleh karena itu kepada pengguna kamus ini, diharapkan dapat bersabar untuk menunggu update selanjutnya.')),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF7272),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.remove('login');
                        await prefs.remove('userKey');
                        print("Logout");
                        setState(() {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        });
                      },
                      child: Text(
                        "Logout",
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
          backgroundColor: const Color(0xFFFF7272),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}