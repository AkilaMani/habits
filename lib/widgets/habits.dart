import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sinusoidals/flutter_sinusoidals.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:habit/values/colors.dart';
import 'package:habit/values/styles.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:math' as math;

class Habits extends StatefulWidget {
  @override
  State<Habits> createState() => _HabitsState();
}

class _HabitsState extends State<Habits> {
  TextEditingController titleController = TextEditingController();

  TextEditingController descriptionController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  String uid = '';

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

  double randomValueForProgress(min, max) {
    print(min + math.Random().nextDouble());
    return min + math.Random().nextDouble();
  }

  @override
  Widget build(BuildContext context) {
    double circlularValue = randomValueForProgress(0.0, 0.9);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                  child: Text(
                'Habits',
                style: titleTextStyle(),
              )),
              FloatingActionButton(
                backgroundColor: lavender,
                onPressed: () {
                  _showAddHabitDialog(context);
                },
                child: const Icon(
                  MdiIcons.plus,
                  size: 20,
                ),
                tooltip: 'Add Habit',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            // color: Colors.red,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('habits')
                  .doc(uid)
                  .collection('myHabits')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  final listofDocs = snapshot.data!.docs;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: listofDocs.length,
                    itemBuilder: (context, index) {
                      var time = (listofDocs[index]['timestamp'] as Timestamp)
                          .toDate();
                      return Container(
                          margin: const EdgeInsets.all(10),
                          width: 130,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              // color: violet,
                              color: Color(
                                      (math.Random().nextDouble() * 0xFFFFFF)
                                          .toInt())
                                  .withOpacity(1.0)),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  // color: Colors.lightGreenAccent,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            titleController.text =
                                                listofDocs[index]['title'];
                                            descriptionController.text =
                                                listofDocs[index]
                                                    ['description'];
                                          });

                                          _showAddHabitDialog(context);

                                          print('edit');
                                        },
                                        child: Icon(
                                          MdiIcons.pencil,
                                          size: 20,
                                          color: white,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      InkWell(
                                        onTap: () async {
                                          await FirebaseFirestore.instance
                                              .collection('habits')
                                              .doc(uid)
                                              .collection('myHabits')
                                              .doc(listofDocs[index]['time'])
                                              .delete();
                                          print('delete');
                                        },
                                        child: Icon(
                                          MdiIcons.delete,
                                          size: 20,
                                          color: white,
                                        ),
                                      ),
                                      const SizedBox(width: 5)
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  DateFormat.yMMMMd('en_US').format(time),
                                  style: timeTextStyle(),
                                ),
                                Text(
                                  DateFormat.jm().format(time),
                                  style: timeTextStyle(),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  listofDocs[index]['title'],
                                  style: titleTextStyle(),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ]));
                    },
                  );
                }
              },
            ),
          ),
          SizedBox(height: 20),
          Container(
            child: DatePicker(
              DateTime.now(),
              height: 100,
              width: 80,
              initialSelectedDate: DateTime.now(),
              selectionColor: pink,
              deactivatedColor: white,
              dateTextStyle: dateTextStyle(),
              dayTextStyle: dayTextStyle(),
              monthTextStyle: monthTextStyle(),
            ),
          ),
        SizedBox(height: 5,),
         
        ],
      ),
    );
  }

  Future<void> _showAddHabitDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      MdiIcons.closeBox,
                      size: 20,
                      color: pink,
                    ),
                  ),
                ]),
                const SizedBox(height: 5),
                Center(
                    child: Text(
                  'Add Habit',
                  style: alertDialogTextStyle(),
                )),
                TextField(
                  onChanged: (value) {},
                  controller: titleController,
                  decoration: InputDecoration(
                      labelText: "Title", labelStyle: alertDialogTextStyle()),
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) {},
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: alertDialogTextStyle(),
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    if (titleController.text.isNotEmpty) {
                      addHabitToFirebase();
                      Navigator.pop(context);
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Title Cannot Be Empty',
                          backgroundColor: white,
                          textColor: pink);
                    }
                  },
                  child: Container(
                      width: 150,
                      height: 30,
                      decoration: BoxDecoration(
                        color: pink,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Center(
                          child: Text(
                        'Add Habit',
                        style: alertDialogSubmitTextStyle(),
                      ))),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        });
  }
}
