import 'dart:typed_data';
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
import 'profile_screen_edit.dart';
import 'report_user_screen.dart';

class ProfileAllUser extends StatefulWidget {
  ProfileAllUser({Key? key, required this.uid}) : super(key: key);
  String uid;
  @override
  State<ProfileAllUser> createState() => _ProfileAllUserState();
}

class _ProfileAllUserState extends State<ProfileAllUser>
    with SingleTickerProviderStateMixin {
  final AuthMethods _authMethods = AuthMethods();
  bool posts = true;
  bool comment = false;
  Uint8List? _image;
  int commentLen = 0;
  int _selectedIndex = 0;
  bool selectFlag = false;
  User? _userProfile;
  User? _userAdmin;
  User? _userP;
  int Score = 0;
  final ScrollController _scrollController = ScrollController();
  TabController? _tabController;
  // User? _user;

  List<dynamic> postList = [];
  List<dynamic> pollList = [];

  @override
  void initState() {
    super.initState();

    initTabController();
    // getUserDetails();
    getScore();

    Provider.of<UserProvider>(context, listen: false)
        .refreshAllUser(widget.uid);
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

  void getScore() async {
    int score = 0;
    // add polls votes
    QuerySnapshot<Map<String, dynamic>> pollsQuerySnapshot =
        await FirebaseFirestore.instance
            .collection('polls')
            .where('uid', isEqualTo: widget.uid)
            .get();
    List<Poll> polls =
        pollsQuerySnapshot.docs.map((e) => Poll.fromSnap(e)).toList();
    for (var element in polls) {
      score += element.totalVotes;
    }

    // add plus votes from messages
    QuerySnapshot<Map<String, dynamic>> postsQuerySnapshot =
        await FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: widget.uid)
            .get();
    List<Post> posts =
        postsQuerySnapshot.docs.map((e) => Post.fromSnap(e)).toList();
    for (var element in posts) {
      print('-------- ${element.plus.length}');
      score += element.plus.length;
    }
    setState(() {
      Score = score;
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
                  Future.delayed(const Duration(milliseconds: 150), () {
                    performLoggedUserAction(
                      context: context,
                      action: () {},
                    );
                  });
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
                  Future.delayed(
                    const Duration(milliseconds: 150),
                    () {
                      performLoggedUserAction(
                          context: context,
                          action: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ReportUserScreen()),
                            );
                          });
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
    _userAdmin = Provider.of<UserProvider>(context).getUser;
    _userProfile = Provider.of<UserProvider>(context).getAllUser;
    // print("_userProfile.uid");
    // print(_userAdmin?.uid);
    String data = _userAdmin?.uid ?? "";
    String userProfiledata = _userProfile?.uid ?? "";
    print(data);
    print(userProfiledata);

    User? user =
        userProfiledata == data ? _userAdmin ?? _userP : _userProfile ?? _userP;
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
                    toolbarHeight:
                        MediaQuery.of(context).size.width < 600 ? 305 : 190,
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
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            child: Material(
                                              shape: const CircleBorder(),
                                              color: Colors.white,
                                              child: InkWell(
                                                customBorder:
                                                    const CircleBorder(),
                                                splashColor: Colors.grey
                                                    .withOpacity(0.5),
                                                onTap: () {
                                                  Future.delayed(
                                                    const Duration(
                                                        milliseconds: 50),
                                                    () {
                                                      Navigator.pop(context);
                                                    },
                                                  );
                                                },
                                                child: const Icon(
                                                    Icons.arrow_back,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Container(width: 8),
                                        Text(
                                          user?.username ?? '',
                                          style: TextStyle(
                                            fontSize: user?.username.length ==
                                                    16
                                                ? 15
                                                : user?.username.length == 15
                                                    ? 16
                                                    : user?.username.length ==
                                                            14
                                                        ? 17
                                                        : user?.username
                                                                    .length ==
                                                                13
                                                            ? 18
                                                            : user?.username
                                                                        .length ==
                                                                    12
                                                                ? 19
                                                                : 20,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                        // IconButton(
                                        //     icon: Icon(Icons.create_outlined,
                                        //         color: Colors.black),
                                        //     onPressed: () {
                                        //       Navigator.push(
                                        //           context,
                                        //           MaterialPageRoute(
                                        //               builder: (context) =>
                                        //                   EditProfile()));
                                        //       //     .then((value) async {
                                        //       //   await getUserDetails();
                                        //       // });
                                        //     }),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5.0),
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            // color: Colors.blue,
                                            child: Material(
                                              shape: const CircleBorder(),
                                              color: Colors.white,
                                              child: InkWell(
                                                customBorder:
                                                    const CircleBorder(),
                                                splashColor: Colors.grey
                                                    .withOpacity(0.5),
                                                onTap: () {
                                                  Future.delayed(
                                                    const Duration(
                                                        milliseconds: 50),
                                                    () {
                                                      _userAdmin?.uid ==
                                                              _userProfile?.uid
                                                          ? Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          EditProfile()))
                                                          : _otherUsers(
                                                              context);
                                                    },
                                                  );
                                                },
                                                child: Icon(
                                                    _userAdmin?.uid ==
                                                            _userProfile?.uid
                                                        ? Icons.create_outlined
                                                        : Icons.more_vert,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  // color: Colors.green,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 4,
                                        bottom: 00.0,
                                        left:
                                            MediaQuery.of(context).size.width >
                                                    600
                                                ? 0
                                                : 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                          onTap: () {},
                                          child: Stack(
                                            children: [
                                              user?.photoUrl != null
                                                  ? Material(
                                                      color: Colors.grey,
                                                      elevation: 4.0,
                                                      shape: CircleBorder(),
                                                      clipBehavior:
                                                          Clip.hardEdge,
                                                      child: Ink.image(
                                                        image: NetworkImage(
                                                          '${user?.photoUrl}',
                                                        ),
                                                        fit: BoxFit.cover,
                                                        width: 120.0,
                                                        height: 120.0,
                                                        child: InkWell(
                                                          splashColor: Colors
                                                              .black
                                                              .withOpacity(0.5),
                                                          onTap: () {
                                                            Future.delayed(
                                                              const Duration(
                                                                  milliseconds:
                                                                      150),
                                                              () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          FullImageProfile(
                                                                              photo: user?.photoUrl)),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    )
                                                  : Material(
                                                      color: Colors.grey,
                                                      elevation: 4.0,
                                                      shape: CircleBorder(),
                                                      clipBehavior:
                                                          Clip.hardEdge,
                                                      child: Ink.image(
                                                        image: AssetImage(
                                                            'assets/avatarFT.jpg'),
                                                        fit: BoxFit.cover,
                                                        width: 120.0,
                                                        height: 120.0,
                                                        // splashColor: Colors.blue,
                                                        child: InkWell(
                                                          splashColor: Colors
                                                              .black
                                                              .withOpacity(0.5),
                                                          onTap: () {
                                                            Future.delayed(
                                                              const Duration(
                                                                  milliseconds:
                                                                      150),
                                                              () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          FullImageProfile(
                                                                              photo: user?.photoUrl)),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                              // CircleAvatar(
                                              //     radius: 60,
                                              //     backgroundColor:
                                              //         Colors.grey,
                                              //     child: CircleAvatar(
                                              //       radius: 60,
                                              //       backgroundImage: AssetImage(
                                              //           'assets/avatarFT.jpg'),
                                              //       backgroundColor:
                                              //           Color.fromARGB(255,
                                              //               245, 245, 245),
                                              //     ),
                                              //   ),
                                              Positioned(
                                                bottom: 0,
                                                right: 14,
                                                child: Container(
                                                  child: Row(
                                                    children: [
                                                      user?.profileFlag ==
                                                              "true"
                                                          ? Container(
                                                              width: 40,
                                                              height: 20,
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
                                                  bottom: 0,
                                                  right: 8,
                                                  child: user?.profileBadge ==
                                                          "true"
                                                      ? Stack(
                                                          children: [
                                                            Positioned(
                                                              left: 5,
                                                              bottom: 5,
                                                              child:
                                                                  CircleAvatar(
                                                                radius: 10,
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                            Positioned(
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
                                                                    size: 31),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : Row()),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: 115,
                                          width: 175,
                                          // color: Colors.blue,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                // color: Colors.orange,
                                                padding: EdgeInsets.all(4),
                                                color: Colors.transparent,
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
                                                        user != null
                                                            ? DateFormat.yMMMd()
                                                                .format(
                                                                user.dateCreated
                                                                    .toDate(),
                                                              )
                                                            : '',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14.5)),
                                                  ],
                                                ),
                                              ),
                                              Container(height: 3),
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Material(
                                                      color: Colors.white,
                                                      child: InkWell(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        splashColor: Colors.grey
                                                            .withOpacity(0.5),
                                                        onTap: () {},
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(4),
                                                          color: Colors
                                                              .transparent,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .monetization_on,
                                                                color:
                                                                    Colors.grey,
                                                                size: 20,
                                                              ),
                                                              Container(
                                                                  width: 5),
                                                              Text('Earned: ',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                  )),
                                                              Text("0.00\$",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          14.5)),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(height: 3),
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Material(
                                                      color: Colors.white,
                                                      child: InkWell(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        splashColor: Colors.grey
                                                            .withOpacity(0.5),
                                                        onTap: () {},
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(4),
                                                          color: Colors
                                                              .transparent,
                                                          child: Row(
                                                            children: [
                                                              // Icon(
                                                              //   MyFlutterApp
                                                              //       .medal,
                                                              //   color:
                                                              //       Colors.grey,
                                                              //   size: 19,
                                                              // ),
                                                              Container(
                                                                  width: 6),
                                                              Text('Score: ',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                  )),
                                                              Text('${Score}',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .normal,
                                                                    fontSize:
                                                                        14.5,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  )),
                                                            ],
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
                                        MediaQuery.of(context).size.width > 600
                                            ? Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            // top: 14.0,
                                                            // right: 10,
                                                            // left: 10,
                                                            bottom: 4),
                                                    child: Container(
                                                      // color: Colors.blue,
                                                      // width:
                                                      //     MediaQuery.of(context)
                                                      //         .size
                                                      //         .width,
                                                      child: Text(
                                                        user?.uid == user?.uid
                                                            ? 'About Me'
                                                            : 'About ${user?.username}',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Container(
                                                      height: 106,
                                                      width: 300,
                                                      padding: EdgeInsets.only(
                                                          bottom: 4,
                                                          right: 10,
                                                          left: 10,
                                                          top: 4),
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: Color.fromARGB(
                                                            255, 245, 245, 245),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                            width: 0,
                                                            color: Colors.grey),
                                                      ),
                                                      child: RawScrollbar(
                                                        // isAlwaysShown: true,
                                                        thumbColor: Colors.black
                                                            .withOpacity(0.25),
                                                        radius:
                                                            Radius.circular(25),
                                                        thickness: 3,

                                                        // showTrackOnHover: true,
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Flexible(
                                                            child: Text(
                                                              trimText(
                                                                          text: (user != null
                                                                              ? user.bio
                                                                                  as String
                                                                              : "")) ==
                                                                      ''
                                                                  ? 'Empty Bio'
                                                                  : trimText(
                                                                      text: user
                                                                              ?.bio
                                                                          as String),
                                                              // textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                  color: trimText(text: user != null ? user.bio as String : "") ==
                                                                          ''
                                                                      ? Color.fromARGB(
                                                                          255,
                                                                          126,
                                                                          126,
                                                                          126)
                                                                      : Colors
                                                                          .black,
                                                                  fontSize:
                                                                      trimText(text: user != null ? user.bio as String : "") ==
                                                                              ''
                                                                          ? 12
                                                                          : 13,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .normal),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Row()
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                    height:
                                        MediaQuery.of(context).size.width < 600
                                            ? 10
                                            : 0),
                                MediaQuery.of(context).size.width < 600
                                    ? Expanded(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  // top: 14.0,
                                                  // right: 10,
                                                  // left: 10,
                                                  bottom: 4),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Text(
                                                  user?.uid == user?.uid
                                                      ? 'About Me'
                                                      : 'About ${user?.username}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Center(
                                              child: Container(
                                                height: 92,
                                                width: 300,
                                                padding: EdgeInsets.only(
                                                    bottom: 4,
                                                    right: 10,
                                                    left: 10,
                                                    top: 4),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 245, 245, 245),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      width: 0,
                                                      color: Colors.grey),
                                                ),
                                                child: RawScrollbar(
                                                  // thumbVisibility: true,
                                                  thumbColor: Colors.black
                                                      .withOpacity(0.25),
                                                  radius: Radius.circular(25),
                                                  thickness: 3,
                                                  // isAlwaysShown: true,
                                                  // showTrackOnHover: true,
                                                  child: SingleChildScrollView(
                                                    child: Flexible(
                                                      child: Text(
                                                        trimText(
                                                                    text: (user !=
                                                                            null
                                                                        ? user.bio
                                                                            as String
                                                                        : "")) ==
                                                                ''
                                                            ? 'Empty Bio'
                                                            : trimText(
                                                                text: user?.bio
                                                                    as String),
                                                        // textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            color: trimText(
                                                                        text: user != null
                                                                            ? user.bio
                                                                                as String
                                                                            : "") ==
                                                                    ''
                                                                ? Color.fromARGB(
                                                                    255,
                                                                    126,
                                                                    126,
                                                                    126)
                                                                : Colors.black,
                                                            fontSize: trimText(
                                                                        text: user != null
                                                                            ? user.bio
                                                                                as String
                                                                            : "") ==
                                                                    ''
                                                                ? 12
                                                                : 13,
                                                            fontStyle: FontStyle
                                                                .normal),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Row()
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
                          .where('uid', isEqualTo: user?.uid)
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
                                      .where('uid', isEqualTo: user?.uid)
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
                                      .where('plus', arrayContains: user?.uid)
                                      .snapshots(),
                                  builder: (content, snapshot1) {
                                    return StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('posts')
                                            .where('minus',
                                                arrayContains: user?.uid)
                                            .snapshots(),
                                        builder: (content, snapshot2) {
                                          return StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection('posts')
                                                  .where('neutral',
                                                      arrayContains: user?.uid)
                                                  .snapshots(),
                                              builder: (content, snapshot3) {
                                                return StreamBuilder(
                                                    stream: FirebaseFirestore
                                                        .instance
                                                        .collection('polls')
                                                        .where('allVotesUIDs',
                                                            arrayContains:
                                                                user?.uid)
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
                                .where('uid', isEqualTo: user?.uid)
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
                                          snapshot.data!.docs[index],
                                          // index
                                        );
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
                                .where('uid', isEqualTo: user?.uid)
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
                                        arrayContains: user?.uid)
                                    .snapshots(),
                                FirebaseFirestore.instance
                                    .collection('polls')
                                    // .doc()
                                    // .collection('comments')
                                    .where('allVotesUIDs',
                                        arrayContains: user?.uid)
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
                                for (int i = 0; i < data0.docs.length; i++) {
                                  Post post = Post.fromSnap(
                                    data0.docs[i],
                                    // i
                                  );
                                  postPoll.add(
                                    PostPoll(
                                      datePublished:
                                          post.datePublished.toDate(),
                                      category: "post",
                                      item: data0.docs[i],
                                    ),
                                  );
                                }

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
                                              postPoll[index].item,
                                              // index
                                            );
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
