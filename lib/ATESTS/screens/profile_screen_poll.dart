import 'dart:async';
import 'dart:typed_data';

import 'package:aft/ATESTS/screens/profile_screen_edit.dart';
import 'package:aft/ATESTS/screens/report_user_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../provider/user_provider.dart';
import '../utils/utils.dart';
import '../zFeeds/message_card.dart';
import '../zFeeds/poll_card.dart';

import '../models/poll.dart';
import '../models/post.dart';
import '../models/postPoll.dart';
import '../models/user.dart';

import '../methods/auth_methods.dart';

import 'full_image_profile.dart';

class ProfilePoll extends StatefulWidget {
  final Poll poll;
  const ProfilePoll({Key? key, required this.poll}) : super(key: key);

  @override
  State<ProfilePoll> createState() => _ProfilePollState();
}

class _ProfilePollState extends State<ProfilePoll>
    with SingleTickerProviderStateMixin {
  final AuthMethods _authMethods = AuthMethods();
  late Poll _poll;
  Uint8List? _image;
  int commentLen = 0;
  int _selectedIndex = 0;
  bool selectFlag = false;
  User? _userProfile;
  final ScrollController _scrollController = ScrollController();
  TabController? _tabController;

  List<dynamic> postList = [];
  List<dynamic> pollList = [];
  StreamSubscription? loadDataStream;

  @override
  void initState() {
    super.initState();
    _poll = widget.poll;
    initTabController();
    getUserDetails();
    // initList(0);
  }

  initTabController() {
    if (_tabController != null) {
      _tabController!.dispose();
    }

    _tabController = TabController(length: 3, vsync: this);

    _tabController?.addListener(() {
      setState(() {
        _selectedIndex = _tabController!.index;
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        // initList(_selectedIndex);
      });
    });
  }

  getUserDetails() async {
    User userProfile = await _authMethods.getUserProfileDetails(_poll.uid);
    setState(() {
      _userProfile = userProfile;
    });
  }

  _otherUsers(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.block),
                    Container(width: 10),
                    const Text('Block User',
                        style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
                  ],
                ),
                onPressed: () {
                  performLoggedUserAction(
                    context: context,
                    action: () {},
                  );
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.report),
                    Container(width: 10),
                    const Text('Report User',
                        style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
                  ],
                ),
                onPressed: () {
                  performLoggedUserAction(
                    context: context,
                    action: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ReportUserScreen()),
                      );
                    },
                  );
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context).getUser;

    return DefaultTabController(
      length: 3,
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            // backgroundColor: Color.fromARGB(255, 245, 245, 245),
            backgroundColor: Color.fromARGB(255, 245, 245, 245),
            body: NestedScrollView(
              controller: _scrollController,
              floatHeaderSlivers: false,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                Container(
                  child: SliverAppBar(
                    backgroundColor: Colors.white,
                    toolbarHeight: 300,
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    // pinned: false,
                    // floating: true,
                    // snap: true,
                    // shape: Border(
                    //   bottom: BorderSide(
                    //     color: Color.fromARGB(255, 201, 201, 201),
                    //   ),
                    // ),

                    actions: [
                      SafeArea(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 0.0),
                                  child: Container(
                                    // color: Colors.blue,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                            icon: Icon(Icons.arrow_back,
                                                color: Colors.black),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            }),
                                        // Container(width: 8),
                                        Text(
                                          _poll.username,
                                          style: TextStyle(
                                            fontSize: _poll.username.length ==
                                                    16
                                                ? 15
                                                : _poll.username.length == 15
                                                    ? 16
                                                    : _poll.username.length ==
                                                            14
                                                        ? 17
                                                        : _poll.username
                                                                    .length ==
                                                                13
                                                            ? 18
                                                            : _poll.username
                                                                        .length ==
                                                                    12
                                                                ? 19
                                                                : 20,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                        IconButton(
                                            icon: Icon(
                                                user?.uid == _poll.uid
                                                    ? Icons.create_outlined
                                                    : Icons.more_vert,
                                                color: Colors.black),
                                            onPressed: () {
                                              user?.uid == _poll.uid
                                                  ? Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditProfile())).then(
                                                      (value) async {
                                                      await getUserDetails();
                                                    })
                                                  : _otherUsers(context);
                                            }),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  // color: Colors.green,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4, bottom: 4.0, left: 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        FullImageProfile(
                                                            photo: _userProfile
                                                                ?.photoUrl))).then(
                                                (value) async {
                                              await getUserDetails();
                                            });
                                          },
                                          child: Stack(
                                            children: [
                                              _userProfile?.photoUrl != null
                                                  ? CircleAvatar(
                                                      radius: 59,
                                                      backgroundColor:
                                                          Color.fromARGB(255,
                                                              215, 215, 215),
                                                      child: CircleAvatar(
                                                        radius: 57,
                                                        backgroundImage:
                                                            NetworkImage(
                                                                '${_userProfile?.photoUrl}'),
                                                        backgroundColor:
                                                            Color.fromARGB(255,
                                                                245, 245, 245),
                                                      ),
                                                    )
                                                  : CircleAvatar(
                                                      radius: 59,
                                                      backgroundColor:
                                                          Color.fromARGB(255,
                                                              215, 215, 215),
                                                      child: CircleAvatar(
                                                        radius: 57,
                                                        backgroundImage: AssetImage(
                                                            'assets/avatarFT.jpg'),
                                                        backgroundColor:
                                                            Color.fromARGB(255,
                                                                245, 245, 245),
                                                      ),
                                                    ),
                                              Positioned(
                                                bottom: 1.5,
                                                right: 18,
                                                child: Container(
                                                  child: Row(
                                                    children: [
                                                      user?.profileFlag ==
                                                              "true"
                                                          ? Container(
                                                              width: 34,
                                                              height: 18,
                                                              child: Image.asset(
                                                                  'icons/flags/png/${user?.country}.png',
                                                                  package:
                                                                      'country_icons'))
                                                          : Row()
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 4,
                                                right: 4,
                                                child: Container(
                                                  child: Row(
                                                    children: [
                                                      user?.profileBadge ==
                                                              "true"
                                                          ? CircleAvatar(
                                                              radius: 15,
                                                              backgroundColor:
                                                                  Color
                                                                      .fromARGB(
                                                                          255,
                                                                          245,
                                                                          245,
                                                                          245),
                                                              child: Container(
                                                                child: Icon(
                                                                    Icons
                                                                        .verified,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            113,
                                                                            191,
                                                                            255),
                                                                    size: 30),
                                                              ),
                                                            )
                                                          : Row()
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: 115,
                                          width: 165,
                                          // color: Colors.blue,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                // color: Colors.orange,

                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .perm_contact_calendar,
                                                      size: 20,
                                                      color: Colors.grey,
                                                      // size: 22,
                                                    ),
                                                    Container(width: 5),
                                                    Text('Joined: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        )),
                                                    Text(
                                                        DateFormat.yMMMd()
                                                            .format(
                                                          user?.dateCreated
                                                              .toDate(),
                                                        ),
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14.5)),
                                                  ],
                                                ),
                                              ),
                                              Container(height: 10),
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.monetization_on,
                                                      color: Colors.grey,
                                                      size: 20,
                                                    ),
                                                    Container(width: 5),
                                                    Text('Earned: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        )),
                                                    Text("0.00\$",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14.5)),
                                                  ],
                                                ),
                                              ),
                                              Container(height: 10),
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.stars,
                                                      color: Colors.grey,
                                                      size: 20,
                                                    ),
                                                    Container(width: 5),
                                                    Text('Score: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        )),
                                                    Text('0',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14.5)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(height: 10),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            // top: 14.0,
                                            right: 12,
                                            left: 12,
                                            bottom: 4),
                                        child: Container(
                                          // color: Colors.blue,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Text(
                                            _poll.uid == user?.uid
                                                ? 'About Me'
                                                : 'About ${_poll.username}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                        ),
                                        child: Center(
                                          child: Container(
                                            height: 96,
                                            width: 300,
                                            padding: EdgeInsets.only(
                                                bottom: 0,
                                                right: 10,
                                                left: 10,
                                                top: 4),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 250, 250, 250),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  width: 0, color: Colors.grey),
                                            ),
                                            child: RawScrollbar(
                                              isAlwaysShown: true,
                                              thumbColor: Colors.black
                                                  .withOpacity(0.15),
                                              radius: Radius.circular(25),
                                              thickness: 3,
                                              // isAlwaysShown: true,
                                              // showTrackOnHover: true,
                                              child: SingleChildScrollView(
                                                child: Flexible(
                                                  child: Text(
                                                    trimText(
                                                                text: (_userProfile !=
                                                                        null
                                                                    ? _userProfile
                                                                            ?.bio
                                                                        as String
                                                                    : "")) ==
                                                            ''
                                                        ? 'Empty Bio'
                                                        : trimText(
                                                            text: _userProfile
                                                                    ?.bio
                                                                as String),
                                                    // textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: trimText(
                                                                    text: _userProfile != null
                                                                        ? _userProfile?.bio
                                                                            as String
                                                                        : "") ==
                                                                ''
                                                            ? Color.fromARGB(
                                                                255, 126, 126, 126)
                                                            : Colors.black,
                                                        fontSize: trimText(
                                                                    text: _userProfile !=
                                                                            null
                                                                        ? _userProfile?.bio
                                                                            as String
                                                                        : "") ==
                                                                ''
                                                            ? 12
                                                            : 13,
                                                        fontStyle:
                                                            FontStyle.normal),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // body: Text('1'),
              body: Column(
                children: [
                  Container(
                    height: 75,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                            width: 1,
                            color: Color.fromARGB(255, 196, 196, 196)),
                      ),
                    ),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .where('uid', isEqualTo: _poll.uid)
                          .snapshots(),
                      builder: (content, snapshot) {
                        return Container(
                          child: TabBar(
                            // isScrollable: true,
                            tabs: [
                              Container(
                                height: 75,
                                // color: Colors.orange,
                                child: Container(
                                  child: Tab(

                                      // icon: Icon(Icons.message_outlined),
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.message_outlined,
                                      ),
                                      Container(
                                        // height: 9,
                                        child: Text('Messages',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 13.5)),
                                      ),
                                      Text(
                                          '(${(snapshot.data as dynamic)?.docs.length ?? 0})',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  )),
                                ),
                              ),
                              StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('polls')
                                      .where('uid', isEqualTo: _poll.uid)
                                      .snapshots(),
                                  builder: (content, snapshot) {
                                    return Container(
                                      height: 75,
                                      child: Tab(
                                          child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.poll_outlined),
                                          Container(
                                            // height: 9,
                                            child: Text('Polls',
                                                textAlign: TextAlign.center,
                                                style:
                                                    TextStyle(fontSize: 13.5)),
                                          ),
                                          Text(
                                              '(${(snapshot.data as dynamic)?.docs.length ?? 0})',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 12)),
                                        ],
                                      )),
                                    );
                                  }),
                              //      Row(
                              //                                             children: [
                              //                                               Text(
                              //                                                 '${((snapshot1.data as dynamic)?.docs.length ?? 0) + ((snapshot2.data as dynamic)?.docs.length ?? 0) + ((snapshot3.data as dynamic)?.docs.length ?? 0) + ((snapshot4.data as dynamic)?.docs.length ?? 0)} ',
                              //                                                 style:
                              StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('posts')
                                      .where('plus', arrayContains: _poll.uid)
                                      .snapshots(),
                                  builder: (content, snapshot1) {
                                    return StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('posts')
                                            .where('minus',
                                                arrayContains: _poll.uid)
                                            .snapshots(),
                                        builder: (content, snapshot2) {
                                          return StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection('posts')
                                                  .where('neutral',
                                                      arrayContains: _poll.uid)
                                                  .snapshots(),
                                              builder: (content, snapshot3) {
                                                return StreamBuilder(
                                                    stream: FirebaseFirestore
                                                        .instance
                                                        .collection('polls')
                                                        .where('allVotesUIDs',
                                                            arrayContains:
                                                                _poll.uid)
                                                        .snapshots(),
                                                    builder:
                                                        (content, snapshot4) {
                                                      return Container(
                                                        height: 75,
                                                        child: Tab(
                                                            child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(Icons
                                                                .check_box_outlined),
                                                            Container(
                                                              // height: 9,
                                                              child: Text(
                                                                  'Votes',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13.5)),
                                                            ),
                                                            Text(
                                                                '(${((snapshot1.data as dynamic)?.docs.length ?? 0) + ((snapshot2.data as dynamic)?.docs.length ?? 0) + ((snapshot3.data as dynamic)?.docs.length ?? 0) + ((snapshot4.data as dynamic)?.docs.length ?? 0)})',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12)),
                                                          ],
                                                        )),
                                                      );
                                                    });
                                              });
                                        });
                                  }),
                            ],
                            indicatorColor: Colors.black,
                            indicatorWeight: 4,
                            labelColor: Colors.black,
                            // onTap: (index) {
                            //   _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                            //   initList(index);
                            // },
                            controller: _tabController,
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      // width: double.maxFinite,
                      // height: MediaQuery.of(context).size.height,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                // .doc()
                                // .collection('comments')
                                .where('uid', isEqualTo: _poll.uid)
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<
                                        QuerySnapshot<Map<String, dynamic>>>
                                    snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return snapshot.data!.docs.length != 0
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        Post post = Post.fromSnap(
                                            snapshot.data!.docs[index]);
                                        // DocumentSnapshot snap = (snapshot.data! as dynamic).docs[index];

                                        return PostCardTest(
                                          post: post,
                                          indexPlacement: index,
                                        );
                                      },
                                    )
                                  : Center(
                                      child: Text(
                                        'No messages yet.',
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 114, 114, 114),
                                            fontSize: 18),
                                      ),
                                    );
                            },
                          ),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('polls')
                                // .doc()
                                // .collection('comments')
                                .where('uid', isEqualTo: _poll.uid)
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<
                                        QuerySnapshot<Map<String, dynamic>>>
                                    snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return snapshot.data!.docs.length != 0
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        Poll poll = Poll.fromSnap(
                                            snapshot.data!.docs[index]);
                                        // DocumentSnapshot snap = (snapshot.data! as dynamic).docs[index];

                                        return PollCard(
                                          poll: poll,
                                          indexPlacement: index,
                                        );
                                      },
                                    )
                                  : Center(
                                      child: Text(
                                        'No polls yet.',
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 114, 114, 114),
                                            fontSize: 18),
                                      ),
                                    );
                            },
                          ),
                          // postList.isNotEmpty
                          //     ? ListView.builder(
                          //         shrinkWrap: true,
                          //         itemCount: postList.length,
                          //         itemBuilder: (context, index) {
                          //           Post post = Post?.fromMap(postList[index] ?? '');
                          //           return PostCardTest(
                          //             post: post,
                          //             indexPlacement: index,
                          //           );
                          //         },
                          //       )
                          //     : Container(),
                          // pollList.isNotEmpty
                          //     ? ListView.builder(
                          //         shrinkWrap: true,
                          //         itemCount: pollList.length,
                          //         itemBuilder: (context, index) {
                          //           Poll poll = Poll.fromMap(pollList[index]);
                          //           return PollCard(
                          //             poll: poll,
                          //             indexPlacement: index,
                          //           );
                          //         },
                          //       )
                          //     : Container(),
                          Builder(builder: (context) {
                            return StreamBuilder(
                              stream: CombineLatestStream.list([
                                FirebaseFirestore.instance
                                    .collection('posts')
                                    // .doc()
                                    // .collection('comments')
                                    .where('allVotesUIDs',
                                        arrayContains: _poll.uid)
                                    .snapshots(),
                                FirebaseFirestore.instance
                                    .collection('polls')
                                    // .doc()
                                    // .collection('comments')
                                    .where('allVotesUIDs',
                                        arrayContains: _poll.uid)
                                    .snapshots(),
                              ]),
                              builder: (context,
                                  AsyncSnapshot<
                                          List<
                                              QuerySnapshot<
                                                  Map<String, dynamic>>>>
                                      snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final data0 = snapshot.data![0];
                                final data1 = snapshot.data![1];

                                List<PostPoll> postPoll = [];
                                postPoll.clear();
                                data0.docs.forEach((element) {
                                  Post post = Post.fromSnap(element);
                                  postPoll.add(PostPoll(
                                      datePublished:
                                          post.datePublished.toDate(),
                                      category: "post",
                                      item: element));
                                });

                                data1.docs.forEach((element) {
                                  Poll poll = Poll.fromSnap(element);
                                  postPoll.add(PostPoll(
                                      datePublished:
                                          poll.datePublished.toDate(),
                                      category: "poll",
                                      item: element));
                                });

                                postPoll.sort((a, b) {
                                  return b.datePublished
                                      .compareTo(a.datePublished);
                                });

                                postPoll.forEach((e) {
                                  print(e.datePublished.toString());
                                });

                                return postPoll.length != 0
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: postPoll.length,
                                        itemBuilder: (context, index) {
                                          if (postPoll[index].category ==
                                              "post") {
                                            Post post = Post.fromSnap(
                                                postPoll[index].item);
                                            return PostCardTest(
                                              post: post,
                                              indexPlacement: index,
                                            );
                                          } else {
                                            Poll poll = Poll.fromSnap(
                                                postPoll[index].item);
                                            return PollCard(
                                              poll: poll,
                                              indexPlacement: index,
                                            );
                                          }
                                        },
                                      )
                                    : Center(
                                        child: Text(
                                          'No votes yet.',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 114, 114, 114),
                                              fontSize: 18),
                                        ),
                                      );
                              },
                            );
                          }),

                          // Text('list of all voted polls + messages'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
