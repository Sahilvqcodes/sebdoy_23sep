import 'dart:async';
import 'package:aft/ATESTS/screens/profile_user.dart';
import 'package:aft/ATESTS/screens/settings.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../methods/auth_methods.dart';
import '../zFeeds/poll_card.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../models/poll.dart';
import '../utils/utils.dart';
import '../provider/user_provider.dart';
import 'filter_screen.dart';
import 'filter_arrays.dart';
import '../zFeeds/message_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final AuthMethods _authMethods = AuthMethods();
  User? _userProfile;
  var messages = 'true';
  var global = 'true';
  bool loading = false;
  // bool filter = true;
  // var userData = {};
  // var timerWidth = 2;
  String oneValue = '';
  String twoValue = '';
  String threeValue = '';
  // int selectedCountryIndex = 0;
  String countryCode = "";
  User? user;

  // String flag = 'us';
  List<Post> postsList = [];
  StreamSubscription? loadDataStream;
  StreamController<Post> updatingStream = StreamController.broadcast();

  List<Poll> pollsList = [];
  StreamSubscription? loadDataStreamPoll;
  StreamController<Poll> updatingStreamPoll = StreamController.broadcast();

  // late Timer _timer;
  // int _start = 60;

  // late String _now;
  // late Timer _everySecond;

  // void startTimer() {
  //   const oneSec = const Duration(seconds: 1);
  //   _timer = new Timer.periodic(
  //     oneSec,
  //     (Timer timer) {
  //       if (_start == 0) {
  //         setState(() {
  //           timer.cancel();
  //         });
  //       } else {
  //         setState(() {
  //           _start--;
  //         });
  //       }
  //     },
  //   );
  // }

  @override
  void initState() {
    super.initState();
    loadCountryFilterValue();
    getValueG().then(((value) => getValueM().then((value) => initList())));
    getValueG().then(((value) => getValueM().then((value) => initPollList())));

    // this has to be like this, to wait for the get functions to be executed first
    //new changes
    //we are changed ACountries file,
    //-----old changes
    //we are initialy filling postList when page is loaded.
    //every elements is subscribed on loadDataStream and listening on the event that is meant to it. (look at the changes in the Post class)
  }

  @override
  void dispose() {
    super.dispose();
    if (loadDataStream != null) {
      loadDataStream!.cancel();
    }
    if (loadDataStreamPoll != null) {
      loadDataStreamPoll!.cancel();
    }
  }

  // Future<void>
  initList() async {
    if (loadDataStream != null) {
      loadDataStream!.cancel();
      postsList = [];
    }
    loadDataStream = (global == "true"
            ? FirebaseFirestore.instance.collection('posts')
            : FirebaseFirestore.instance
                .collection('posts')
                .where("country", isEqualTo: countryCode))
        .where("global", isEqualTo: global)
        .orderBy("score", descending: true)
        .orderBy("datePublished", descending: false)
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
    });
  }

  initPollList() async {
    if (loadDataStreamPoll != null) {
      loadDataStreamPoll!.cancel();
      pollsList = [];
    }
    loadDataStreamPoll = (global == "true"
            ? FirebaseFirestore.instance.collection('polls')
            : FirebaseFirestore.instance
                .collection('polls')
                .where("country", isEqualTo: countryCode))
        .where("global", isEqualTo: global)
        .orderBy("totalVotes", descending: true)
        .orderBy("datePublished", descending: false)
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            pollsList.add(Poll.fromMap({
              ...change.doc.data()!,
              'updatingStreamPoll': updatingStreamPoll
            })); // we are adding to a local list when the element is added in firebase collection
            break; //the Post element we will send on pair with updatingStream, because a Post constructor makes a listener on a stream.
          case DocumentChangeType.modified:
            updatingStreamPoll.add(Poll.fromMap({
              ...change.doc.data()!
            })); // we are sending a modified object in the stream.
            break;
          case DocumentChangeType.removed:
            pollsList.remove(Poll.fromMap({
              ...change.doc.data()!
            })); // we are removing a Post object from the local list.
            break;
        }
      }
      setState(() {});
    });
  }

  Future<void> getValueG() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('selected_radio3') != null) {
      setState(() {
        global = prefs.getString('selected_radio3')!;
      });
    }
  }

  Future<void> setValueG(String valueg) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      global = valueg.toString();
      prefs.setString('selected_radio3', global);
      initList();
      initPollList();
    });
  }

  Future<void> getValueM() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('selected_radio4') != null) {
      setState(() {
        messages = prefs.getString('selected_radio4')!;
      });
    }
  }

  // Future<void>
  setValueM(String valuem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      messages = valuem.toString();
      if (valuem == "true") {
        initList();
        initPollList();
      }
      prefs.setString('selected_radio4', messages);
    });
  }

  loadCountryFilterValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      int selectedCountryIndex = prefs.getInt('countryRadio') ?? 0;
      countryCode = short[selectedCountryIndex];
      print(countryCode);
      oneValue = prefs.getString('selected_radio') ?? '';
      twoValue = prefs.getString('selected_radio1') ?? '';
      threeValue = prefs.getString('selected_radio2') ?? '';
    });
  }

  // getUserDetails() async {
  //   User userProfile = await _authMethods.getUserProfileDetails(_user?.uid);
  //   setState(() {
  //     _userProfile = userProfile;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 245, 245, 245),
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              // elevation: 1.5,
              // forceElevated: true,
              toolbarHeight: 108,

              backgroundColor: const Color.fromARGB(255, 245, 245, 245),
              actions: [
                SafeArea(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10, right: 12, left: 12
                                // bottom: filter ? 8 : ,
                                ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Countries(),
                                      ),
                                    ).then((value) async {
                                      await loadCountryFilterValue();
                                      initList();
                                      initPollList();
                                    });
                                  },
                                  child: const Icon(Icons.filter_list,
                                      color: Colors.black),
                                ),
                                InkWell(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 250, 250, 250),
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        width: 0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 28.0, vertical: 4),
                                      child: Row(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 20,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '0',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color.fromARGB(
                                                        255, 124, 124, 124),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Container(
                                                width: 10,
                                                height: 20,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '0',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color.fromARGB(
                                                        255, 124, 124, 124),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 25),
                                          Container(
                                            width: 10,
                                            height: 20,
                                            alignment: Alignment.center,
                                            child: const Text(
                                              ':',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 124, 124, 124),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 25),
                                          Container(
                                            width: 10,
                                            height: 20,
                                            alignment: Alignment.center,
                                            child: const Text(
                                              '0',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color.fromARGB(
                                                    255, 124, 124, 124),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          Container(
                                            width: 10,
                                            height: 20,
                                            alignment: Alignment.center,
                                            child: const Text(
                                              '8',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color.fromARGB(
                                                    255, 124, 124, 124),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 25),
                                          Container(
                                            width: 10,
                                            height: 20,
                                            alignment: Alignment.center,
                                            child: const Text(
                                              ':',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 124, 124, 124),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 25),
                                          Container(
                                            width: 10,
                                            height: 20,
                                            alignment: Alignment.center,
                                            child: const Text(
                                              '2',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color.fromARGB(
                                                    255, 124, 124, 124),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          Container(
                                            width: 10,
                                            height: 20,
                                            alignment: Alignment.center,
                                            child: const Text(
                                              '3',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color.fromARGB(
                                                    255, 124, 124, 124),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => SimpleDialog(
                                        title:
                                            const Center(child: Text('Timer')),
                                        children: [
                                          const Center(
                                            child: Text(
                                              'The timer represents the total remaining time before the votings ends.',
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Close'),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SettingsScreen()),
                                    );
                                  },
                                  child: const Icon(Icons.settings,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 12.0, left: 12, top: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                global == 'true'
                                    ? Column(
                                        children: [
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 1.0),
                                            child: Text(
                                              'Global',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.5,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                          AnimatedToggleSwitch<
                                                  String>.rollingByHeight(
                                              height: 32,
                                              current: global,
                                              values: const [
                                                'true',
                                                'false',
                                              ],
                                              onChanged: (valueg) =>
                                                  setValueG(valueg.toString()),
                                              iconBuilder:
                                                  rollingIconBuilderStringThree,
                                              borderRadius:
                                                  BorderRadius.circular(25.0),
                                              borderWidth: 0,
                                              indicatorSize:
                                                  const Size.square(1.8),
                                              innerColor: const Color.fromARGB(
                                                  255, 228, 228, 228),
                                              indicatorColor:
                                                  const Color.fromARGB(
                                                      255, 157, 157, 157),
                                              borderColor: const Color.fromARGB(
                                                  255, 135, 135, 135),
                                              iconOpacity: 1),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          Row(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 1.0),
                                                child: Text(
                                                  'National',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.5,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              SizedBox(
                                                width: 24,
                                                height: 16,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 2.0),
                                                  child: Image.asset(
                                                    'icons/flags/png/$countryCode.png',
                                                    package: 'country_icons',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          AnimatedToggleSwitch<
                                              String>.rollingByHeight(
                                            height: 32,
                                            current: global,
                                            values: const [
                                              'true',
                                              'false',
                                            ],
                                            onChanged: (valueg) {
                                              setValueG(valueg.toString());
                                              // setState(() {
                                              //   loading == true;
                                              //   Future.delayed(
                                              //       const Duration(
                                              //           milliseconds:
                                              //               500), () {
                                              //     loading == false;
                                              //   });
                                              // });
                                            },
                                            iconBuilder:
                                                rollingIconBuilderStringThree,
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            borderWidth: 0,
                                            indicatorSize:
                                                const Size.square(1.8),
                                            innerColor: const Color.fromARGB(
                                                255, 228, 228, 228),
                                            indicatorColor:
                                                const Color.fromARGB(
                                                    255, 157, 157, 157),
                                            borderColor: const Color.fromARGB(
                                                255, 135, 135, 135),
                                            iconOpacity: 1,
                                          ),
                                        ],
                                      ),
                                InkWell(
                                  onTap: () {
                                    performLoggedUserAction(
                                      context: context,
                                      action: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ProfileUser(),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 53.0,
                                        height: 53.0,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(50.0)),
                                          color: Colors.grey,
                                          image: user?.photoUrl != null
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                      user?.photoUrl ?? ''),
                                                  fit: BoxFit.cover,
                                                )
                                              : const DecorationImage(
                                                  image: AssetImage(
                                                      'assets/avatarFT.jpg'),
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 5,
                                        child: Row(
                                          children: [
                                            user?.profileFlag == "true"
                                                ? SizedBox(
                                                    width: 19,
                                                    height: 9.5,
                                                    child: Image.asset(
                                                        'icons/flags/png/${user?.country}.png',
                                                        package:
                                                            'country_icons'))
                                                : Row()
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Row(
                                          children: [
                                            user?.profileBadge == "true"
                                                ? const CircleAvatar(
                                                    radius: 8,
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 245, 245, 245),
                                                    child: Icon(Icons.verified,
                                                        color: Color.fromARGB(
                                                            255, 113, 191, 255),
                                                        size: 15),
                                                  )
                                                : Row()
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 1.0),
                                      child: Text(
                                        messages == 'true'
                                            ? 'Messages'
                                            : 'Polls',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    AnimatedToggleSwitch<
                                            String>.rollingByHeight(
                                        height: 32,
                                        current: messages,
                                        values: const [
                                          'true',
                                          'false',
                                        ],
                                        onChanged: (valuem) {
                                          setValueM(valuem.toString());
                                        },
                                        iconBuilder:
                                            rollingIconBuilderStringTwo,
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        borderWidth: 0,
                                        indicatorSize: const Size.square(1.8),
                                        innerColor: const Color.fromARGB(
                                            255, 228, 228, 228),
                                        indicatorColor: const Color.fromARGB(
                                            255, 157, 157, 157),
                                        borderColor: const Color.fromARGB(
                                            255, 135, 135, 135),
                                        iconOpacity: 1),
                                  ],
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
          ],
          body: //global == "true" && messages == "true"
              // ?
              //global variable doesn't look into here, because we are using unique list(postsList) for filling up model
              //look at the function initList(), it is called when global variable is changed
              postsList.isNotEmpty && messages == "true"
                  ? ListView.builder(
                      itemCount: postsList.length,
                      itemBuilder: (context, index) {
                        // Post post = Post.fromSnap(snapshot.data!.docs[index]);
                        final User? user =
                            Provider.of<UserProvider>(context).getUser;
                        return PostCardTest(
                          post: postsList[index],
                          indexPlacement: index,
                        );
                      },
                    )
                  : postsList.isEmpty && messages == "true" && global == "true"
                      ? const Center(
                          child: Text(
                            'No messages yet.',
                            style: TextStyle(
                                color: Color.fromARGB(255, 114, 114, 114),
                                fontSize: 18),
                          ),
                        )
                      : postsList.isEmpty &&
                              messages == "true" &&
                              global == "false"
                          ? Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'No',
                                    style: TextStyle(
                                        fontSize: 18,

                                        // fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 114, 114, 114)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: SizedBox(
                                      width: 24,
                                      height: 16,
                                      child: Image.asset(
                                          'icons/flags/png/$countryCode.png',
                                          package: 'country_icons'),
                                    ),
                                  ),
                                  const Text(
                                    'messages yet.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      // fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 114, 114, 114),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : pollsList.isNotEmpty && messages == "false"
                              ? ListView.builder(
                                  itemCount: pollsList.length,
                                  itemBuilder: (context, index) {
                                    final User? user =
                                        Provider.of<UserProvider>(context)
                                            .getUser;

                                    return PollCard(
                                      poll: pollsList[index],
                                      indexPlacement: index,
                                    );
                                  })
                              : pollsList.isEmpty &&
                                      messages == "false" &&
                                      global == "true"
                                  ? const Center(
                                      child: Text(
                                        'No polls yet.',
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 114, 114, 114),
                                            fontSize: 18),
                                      ),
                                    )
                                  : Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'No',
                                            style: TextStyle(
                                                fontSize: 18,

                                                // fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 114, 114, 114)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: SizedBox(
                                              width: 24,
                                              height: 16,
                                              child: Image.asset(
                                                  'icons/flags/png/$countryCode.png',
                                                  package: 'country_icons'),
                                            ),
                                          ),
                                          const Text(
                                            'polls yet.',
                                            style: TextStyle(
                                              fontSize: 18,

                                              // fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 114, 114, 114),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
        ),
      ),
    );
  }

  Widget rollingIconBuilderStringTwo(
      String messages, Size iconSize, bool foreground) {
    IconData data = Icons.poll;
    if (messages == 'true') data = Icons.message;
    return Icon(data, size: iconSize.shortestSide, color: Colors.white);
  }

  Widget rollingIconBuilderStringThree(
      String global, Size iconSize, bool foreground) {
    IconData data = Icons.flag;
    if (global == 'true') data = Icons.public;
    return Icon(data, size: iconSize.shortestSide, color: Colors.white);
  }
}
