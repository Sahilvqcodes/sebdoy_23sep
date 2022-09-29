import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../provider/user_provider.dart';
import '../utils/utils.dart';

class BlockedList extends StatefulWidget {
  const BlockedList({Key? key}) : super(key: key);

  @override
  State<BlockedList> createState() => _BlockedListState();
}

class _BlockedListState extends State<BlockedList> {
  void initState() {
    super.initState();
  }

  List Result = [];
  late QuerySnapshot getuserProfile;
  userBlockList(String? uid) async {
    Result.clear();
    var querySnapshot =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    for (int i = 0; i < querySnapshot["blockList"].length; i++) {
      getuserProfile = await FirebaseFirestore.instance
          .collection("users")
          .where("uid", isEqualTo: querySnapshot["blockList"][i])
          .get();
      getuserProfile.docs.forEach((element) {
        Result.add(element.data());
      });
    }
    print("BlockList ${querySnapshot["blockList"]}");
    return querySnapshot;
  }

  // late QuerySnapshot getuserProfile;
  // getAllBlockUser() async {
  //   print("BlockListResult $Result");

  //   Result.clear();
  //   print("BlockListclear $Result");
  //   for (int i = 0; i < querySnapshot["blockList"].length; i++) {
  //     Result.clear();
  //     getuserProfile = await FirebaseFirestore.instance
  //         .collection("users")
  //         .where("uid", isEqualTo: querySnapshot["blockList"][i])
  //         .get();
  //     getuserProfile.docs.forEach((element) {
  //       Result.add(element.data());
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Blocked List'),
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: FutureBuilder(
              future: userBlockList(user?.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return (snapshot.data as dynamic)["blockList"].length != 0
                    ? ListView.builder(
                        itemCount: Result.length,
                        itemBuilder: ((context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 2),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                splashColor: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  print("ontapdata");

                                  // Future.delayed(
                                  //     const Duration(
                                  //         milliseconds: 150), () {
                                  // Navigator.of(context).push(
                                  //   MaterialPageRoute(
                                  //     builder: (context) =>
                                  //         ProfileAllUser(
                                  //             uid: uid ?? ""),
                                  //   ),
                                  // );
                                  // });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        width: 0, color: Colors.grey),
                                  ),
                                  child: ListTile(
                                      leading: Stack(
                                        children: [
                                          Result[index]['photoUrl'] != null
                                              ? CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                  Result[index]['photoUrl'],
                                                ))
                                              : const CircleAvatar(
                                                  backgroundImage: AssetImage(
                                                      'assets/avatarFT.jpg')),
                                          Positioned(
                                            bottom: 0,
                                            right: 4,
                                            child: Row(
                                              children: [
                                                Result[index]['profileFlag'] ==
                                                        "true"
                                                    ? SizedBox(
                                                        width: 15.5,
                                                        height: 7.7,
                                                        child: Image.asset(
                                                            'icons/flags/png/${(snapshot.data! as dynamic).docs[index]['country']}.png',
                                                            package:
                                                                'country_icons'),
                                                      )
                                                    : Row()
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Row(
                                              children: [
                                                Result[index]['profileBadge'] ==
                                                        "true"
                                                    ? CircleAvatar(
                                                        radius: 6,
                                                        backgroundColor:
                                                            const Color
                                                                    .fromARGB(
                                                                255,
                                                                245,
                                                                245,
                                                                245),
                                                        child: Container(
                                                          child: const Icon(
                                                              Icons.verified,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      113,
                                                                      191,
                                                                      255),
                                                              size: 12),
                                                        ),
                                                      )
                                                    : Row()
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      title: Text(
                                        Result[index]['username'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: TextButton(
                                          onPressed: () {
                                            performLoggedUserAction(
                                              context: context,
                                              action: () async {
                                                FirebaseFirestore.instance
                                                    .collection("users")
                                                    .doc(user?.uid)
                                                    .update({
                                                  'blockList':
                                                      FieldValue.arrayRemove([
                                                    Result[index]['uid']
                                                  ])
                                                });
                                                // QuerySnapshot<
                                                //         Map<String, dynamic>>
                                                //     pollsQuerySnapshot =
                                                //     await FirebaseFirestore
                                                //         .instance
                                                //         .collection('posts')
                                                //         .where('uid',
                                                //             isEqualTo:
                                                //                 Result[index]
                                                //                     ['uid'])
                                                //         .get();
                                                // for (var element
                                                //     in pollsQuerySnapshot
                                                //         .docs) {
                                                //   await element.reference
                                                //       .update({
                                                //     'blockList':
                                                //         FieldValue.arrayRemove(
                                                //             [user?.uid])
                                                //   });
                                                // }
                                                setState(() {});
                                              },
                                            );
                                          },
                                          child: Text("Remove"))),
                                ),
                              ),
                            ),
                          );
                        }),
                      )
                    : Center(
                        child: Text("Data Not Found!"),
                      );
              },
            ),
          ),
        ),
      ),
    );
  }
}
