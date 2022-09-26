import 'dart:async';
import 'dart:typed_data';

import 'package:aft/ATESTS/methods/firestore_methods.dart';
import 'package:aft/ATESTS/screens/profile_screen.dart';
import 'package:aft/ATESTS/screens/profile_screen_edit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../methods/auth_methods.dart';
import '../models/poll.dart';
import '../models/post.dart';
import '../models/postPoll.dart';
import '../models/user.dart';
import '../provider/user_provider.dart';
import '../utils/utils.dart';
import '../zFeeds/message_card.dart';
import '../zFeeds/poll_card.dart';
import 'full_image_profile.dart';

class UserList extends StatefulWidget {
  final List plus;
  const UserList(
    this.plus, {
    Key? key,
  }) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList>
    with SingleTickerProviderStateMixin {
  StreamSubscription? loadDataStream;
  List<Post> postsList = [];
  StreamController<Post> updatingStream = StreamController.broadcast();
  List<User> _userDetails = [];
  final AuthMethods _authMethods = AuthMethods();
  @override
  void initState() {
    super.initState();
    _userDetails.clear();
    for (int i = 0; i < widget.plus.length; i++) {
      getUserDetails(widget.plus[i]);
    }

    initList();
  }

  // Future<void>
  initList() async {
    if (loadDataStream != null) {
      loadDataStream!.cancel();
      postsList = [];
    }
    loadDataStream = (FirebaseFirestore.instance
        .collection('posts')
        .orderBy("datePublished", descending: true)
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            postsList.add(Post.fromMap({
              ...change.doc.data()!,
              'updatingStream': updatingStream
            })); // we are adding to a local list when the element is added in firebase collection
            break; //the Post element we will send on pair with updatingStream, because a Post constructor makes a listener on a stream.
          case DocumentChangeType.modified:
            updatingStream.add(Post.fromMap({
              ...change.doc.data()!
            })); // we are sending a modified object in the stream.
            break;
          case DocumentChangeType.removed:
            postsList.remove(Post.fromMap({
              ...change.doc.data()!
            })); // we are removing a Post object from the local list.
            break;
        }
      }
      setState(() {});
    }));
  }

  getUserDetails(uid) async {
    User userProfile = await _authMethods.getUserProfileDetails(uid);
    if (mounted) {
      setState(() {
        //_userProfile = userProfile;
        _userDetails.add(userProfile);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? _user = Provider.of<UserProvider>(context).getUser;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 245, 245, 245),
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Container(
                  height: 50,
                  padding: const EdgeInsets.only(bottom: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ],
                  ),
                ),
                Container(
                    height: MediaQuery.of(context).size.height - 80,
                    child: ListView.builder(
                        itemCount: _userDetails.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Profile(
                                          null, _userDetails[index],
                                          key: GlobalKey())),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    _userDetails[index].photoUrl != null &&
                                            _userDetails[index].photoUrl != ""
                                        ? CircleAvatar(
                                            radius: 20,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 227, 227, 227),
                                            backgroundImage: NetworkImage(
                                                _userDetails[index].photoUrl ??
                                                    ""),
                                          )
                                        : const CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Color.fromARGB(
                                                255, 227, 227, 227),
                                            backgroundImage: AssetImage(
                                                'assets/avatarFT.jpg'),
                                          ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(_userDetails[index].username),
                                  ],
                                ),
                              ));
                        }))
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (loadDataStream != null) {
      loadDataStream!.cancel();
    }
    super.dispose();
  }
}
