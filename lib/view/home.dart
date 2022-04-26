import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sinusoidals/flutter_sinusoidals.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:habit/helper/authentication_helper.dart';
import 'package:habit/values/colors.dart';
import 'package:habit/values/styles.dart';
import 'package:habit/view/login.dart';
import 'package:habit/widgets/habits.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:math' as math;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

enum DrawerType { habits, dashBoard }

class _HomeState extends State<Home> {
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  var currentDrawerType = DrawerType.habits;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  String uid = '';
  double randomValueForProgress(min, max) {
    print(min + math.Random().nextDouble());
    return min + math.Random().nextDouble();
  }

  @override
  void initState() {
    getuid();
    super.initState();
  }

  getuid() async {
    final User? user = auth.currentUser;
    uid = user!.uid;
  }

  addHabitToFirebase() async {
    final User? user = auth.currentUser;

    String uid = user!.uid;
    var time = DateTime.now();
    await FirebaseFirestore.instance
        .collection('habits')
        .doc(uid)
        .collection('myHabits')
        .doc(time.toString())
        .set({
      'title': titleController.text,
      'description': descriptionController.text,
      'time': time.toString(),
      'timestamp': time
    });
    // Fluttertoast.showToast(msg: 'Habit Added', backgroundColor: white);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        key: _scaffoldState,
        drawer: Drawer(
            child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: pink,
              ),
              child: Center(
                  child: Text(
                user.email!,
                style: drawerHeaderListTextStyle(),
              )),
            ),
            ListTile(
              title: Text(
                'Habits',
                style: drawerListTextStyle(),
              ),
              onTap: () {
                setState(() {
                  currentDrawerType = DrawerType.habits;
                });

                Navigator.pop(context);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (contex) => Habits()),
                // );
              },
              leading: Icon(
                MdiIcons.barley,
                color: pink,
              ),
            ),
            ListTile(
              title: Text('Dashboard', style: drawerListTextStyle()),
              onTap: () {
                setState(() {
                  currentDrawerType = DrawerType.dashBoard;
                });

                Navigator.pop(context);
              },
              leading: Icon(
                MdiIcons.barn,
                color: pink,
              ),
            ),
            ListTile(
              title: Text('Logout', style: drawerListTextStyle()),
              onTap: () {
                AuthenticationHelper()
                    .signOut()
                    .then((_) => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (contex) => Login()),
                        ));
              },
              leading: Icon(
                Icons.flare,
                color: pink,
              ),
            ),
          ],
        )),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  icon: Icon(MdiIcons.apps, color: white, size: 25),
                  onPressed: () {
                    _scaffoldState.currentState!.openDrawer();
                  },
                ),
              ],
            ),
            if (currentDrawerType == DrawerType.habits)
              Container(
                // color: Colors.lightGreenAccent,
                child: Habits(),
              ),
            if (currentDrawerType == DrawerType.dashBoard)
              Container(
                // color: Colors.lightGreenAccent,
                child: Dashboard,
              ),

            // else if(drawerType == DrawerData.dashBoard)
          ],
        ),
      ),
    );
  }

  late double circlularValue = randomValueForProgress(0.0, 0.9);
  Widget get Dashboard => Container(
        margin: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Container(
                  child: Text(
                'Learn 5 new words',
                style: titleTextStyle(),
                textAlign: TextAlign.start,
              )),
            ),
            Container(
                height: 80,
                // color: Colors.lightGreenAccent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(circlularValue * 100).toStringAsPrecision(2)}%',

                      // (randomValueForProgress(0.0, 0.9)*100).toStringAsPrecision(2),
                      style: circularProgressTextStyle(),
                    ),
                    LinearProgressIndicator(
                      value: circlularValue,
                      // value: randomValueForProgress(0.0, 0.9),
                      backgroundColor:
                          Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                              .withOpacity(1.0),
                    ),
                  ],
                )),
            SizedBox(height: 20),
            Divider(
              color: grey,
              thickness: 0.8,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Container(
                  child: Text(
                'Strength',
                style: titleTextStyle(),
                textAlign: TextAlign.start,
              )),
            ),
            Container(
                height: 80,
                // color: Colors.lightGreenAccent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Text(
                      '${(circlularValue * 100).toStringAsPrecision(2)}%',

                      // (randomValueForProgress(0.0, 0.9)*100).toStringAsPrecision(2),
                      style: circularProgressTextStyle(),
                    )),
                    CircularProgressIndicator(
                      value: circlularValue,
                      // value: randomValueForProgress(0.0, 0.9),
                      backgroundColor:
                          Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                              .withOpacity(1.0),
                    ),
                  ],
                )),
            Divider(
              color: grey,
              thickness: 0.8,
            ),

            //this needs to flutter run --no-sound-null-safety
          //    Sinusoidal(
          //   child:Container(
          //     height: 200,
          //     color: pink,
          //   )
          // ),
          ],
        ),
      );
}
