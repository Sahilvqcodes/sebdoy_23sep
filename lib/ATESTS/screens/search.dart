import 'dart:async';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/poll.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../provider/user_provider.dart';
import '../zFeeds/message_card.dart';
import '../zFeeds/poll_card.dart';
import 'filter_arrays.dart';
import 'filter_screen.dart';
import 'profile_all_user.dart';
import 'settings.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class Customer {
  String tagName;
  int tagValue;
  Customer(this.tagName, this.tagValue);
  @override
  String toString() {
    return '{ ${this.tagName}, ${this.tagValue} }';
  }
}

class _SearchState extends State<Search> {
  final TextEditingController searchController = TextEditingController();
  bool isHome = false;
  bool isAllKey = false;
  bool isSearchAllKey = false;
  bool isUser = false;
  bool searchFieldSelected = false;
  bool showMessages = true;
  bool showPolls = false;
  var messages = 'true';
  var global = 'true';
  String oneValue = '';
  String twoValue = '';
  String threeValue = '';
  String countryCode = "";
  String? trendkeystore;
  String? trendkeystorePoll;

  List<Post> postsList = [];
  StreamSubscription? loadDataStream;
  StreamController<Post> updatingStream = StreamController.broadcast();

  List<Poll> pollsList = [];
  StreamSubscription? loadDataStreamPoll;
  StreamController<Poll> updatingStreamPoll = StreamController.broadcast();
  @override
  void initState() {
    super.initState();
    isHome = true;
    isAllKey = true;
    isSearchAllKey = true;
    showMessages = false;

    trendkeystore == ""
        ? getValueG().then(
            ((value) => getValueM().then((value) => initList(trendkeystore!))))
        : "";
    trendkeystore == ""
        ? getValueG().then(((value) =>
            getValueM().then((value) => initPollList(trendkeystore!))))
        : "";
    loadCountryFilterValue();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    if (loadDataStream != null) {
      loadDataStream!.cancel();
    }
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
      if (showMessages == true) {
        initList(trendkeystore!);
        initPollList(trendkeystore!);
      }
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

  Future<void> setValueM(String valuem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      messages = valuem.toString();
      if (valuem == "true") {
        // initList(searchController.text);
        // initList(trendkeystore!);
      }
      prefs.setString('selected_radio4', messages);
    });
  }

  CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('posts');
  var AllList = [];
  var fetchedList = [];
  List trendingKey = [];
  List trendingkeyvalue = [];
  List list = [];
  var AllList1 = [];
  var fetchedList1 = [];
  List trendingKey1 = [];
  List trendingkeyvalue1 = [];
  List list1 = [];
  Future<void> getData() async {
    // Get docas from collection reference

    await (global == "true"
            ? FirebaseFirestore.instance.collection('posts')
            : FirebaseFirestore.instance
                .collection('posts')
                .where("country", isEqualTo: countryCode))
        .where("global", isEqualTo: global)
        .orderBy("tags")
        .get()
        .then((QuerySnapshot querySnapshot) {
      AllList.clear();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        fetchedList = querySnapshot.docs[i]["tags"];
        // print("fetchedlist");
        // print(fetchedList);
        var result = fetchedList.toSet().toList();

        AllList.addAll(result);
      }

      final myMap = Map();

      AllList.forEach(
        (element) {
          if (!myMap.containsKey(element)) {
            myMap[element] = 1;
          } else {
            myMap[element] += 1;
          }
        },
      );
      list.clear();
      Map listMap = myMap;
      myMap.forEach((k, v) => list.add(Customer(k, v)));
      list.sort((b, a) => a.tagValue.compareTo(b.tagValue));
      return AllList;
    });
  }

  CollectionReference _collectionRefPoll =
      FirebaseFirestore.instance.collection('polls');
  var AllListPoll = [];
  var fetchedListPoll = [];
  List trendingKeyPoll = [];
  List trendingkeyvaluePoll = [];
  List listPoll = [];
  var AllList1Poll = [];
  var fetchedList1Poll = [];
  List trendingKey1Poll = [];
  List trendingkeyvalue1Poll = [];
  List list1Poll = [];
  Future<void> getDataPoll() async {
    // Get docas from collection reference

    await (global == "true"
            ? FirebaseFirestore.instance.collection('polls')
            : FirebaseFirestore.instance
                .collection('polls')
                .where("country", isEqualTo: countryCode))
        .where("global", isEqualTo: global)
        .orderBy("tags")
        .get()
        .then((QuerySnapshot querySnapshot) {
      AllListPoll.clear();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        fetchedListPoll = querySnapshot.docs[i]["tags"];
        // print("fetchedlist");
        // print(fetchedList);
        var result = fetchedListPoll.toSet().toList();

        AllListPoll.addAll(result);
      }

      final myMap = Map();

      AllListPoll.forEach(
        (element) {
          if (!myMap.containsKey(element)) {
            myMap[element] = 1;
          } else {
            myMap[element] += 1;
          }
        },
      );
      listPoll.clear();
      Map listMap = myMap;
      myMap.forEach((k, v) => listPoll.add(Customer(k, v)));
      listPoll.sort((b, a) => a.tagValue.compareTo(b.tagValue));
      return AllListPoll;
    });
  }

  List _searchResult = [];
  Future<void> getsearchData(String text) async {
    await (global == "true"
            ? FirebaseFirestore.instance.collection('posts')
            : FirebaseFirestore.instance
                .collection('posts')
                .where("country", isEqualTo: countryCode))
        .where("global", isEqualTo: global)
        .orderBy("tags")
        .get()
        .then((QuerySnapshot querySnapshot) {
      AllList1.clear();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        fetchedList1 = querySnapshot.docs[i]["tags"];
        // print("fetchedlist");
        // print(fetchedList);
        var result = fetchedList1.toSet().toList();

        AllList1.addAll(result);
      }

      final myMap = Map();

      AllList1.forEach(
        (element) {
          if (!myMap.containsKey(element)) {
            myMap[element] = 1;
          } else {
            myMap[element] += 1;
          }
        },
      );
      list1.clear();
      Map listMap = myMap;
      myMap.forEach((k, v) => list1.add(Customer(k, v)));
      list1.sort((b, a) => a.tagValue.compareTo(b.tagValue));

      _searchResult = list1
          .where((user) =>
              user.tagName.toLowerCase().startsWith(text.toLowerCase()))
          .toList();
    });
  }

  List _searchResultPoll = [];
  Future<void> getsearchDataPoll(String text) async {
    await (global == "true"
            ? FirebaseFirestore.instance.collection('polls')
            : FirebaseFirestore.instance
                .collection('polls')
                .where("country", isEqualTo: countryCode))
        .where("global", isEqualTo: global)
        .orderBy("tags")
        .get()
        .then((QuerySnapshot querySnapshot) {
      AllList1Poll.clear();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        fetchedList1Poll = querySnapshot.docs[i]["tags"];
        // print("fetchedlist");
        // print(fetchedList);
        var result = fetchedList1Poll.toSet().toList();

        AllList1Poll.addAll(result);
      }

      final myMap = Map();

      AllList1Poll.forEach(
        (element) {
          if (!myMap.containsKey(element)) {
            myMap[element] = 1;
          } else {
            myMap[element] += 1;
          }
        },
      );
      list1Poll.clear();
      Map listMap = myMap;
      myMap.forEach((k, v) => list1Poll.add(Customer(k, v)));
      list1Poll.sort((b, a) => a.tagValue.compareTo(b.tagValue));

      _searchResultPoll = list1Poll
          .where((user) =>
              user.tagName.toLowerCase().startsWith(text.toLowerCase()))
          .toList();
    });
  }

  initList(String trendKey) async {
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
        // .orderBy("score", descending: true)
        // .orderBy("datePublished", descending: false)
        // .orderBy("tags")
        .where("tags", arrayContains: trendKey)
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
      setState(() {
        trendkeystore = trendKey;
      });
    });
  }

  initPollList(String trendKey) async {
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
        .where("tags", arrayContains: trendKey)
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
      setState(() {
        trendkeystore = trendKey;
      });
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

  @override
  Widget build(BuildContext context) {
    var safePadding = MediaQuery.of(context).padding.top;
    var appBarPadding = AppBar().preferredSize.height;
    final User? user = Provider.of<UserProvider>(context).getUser;

    return SafeArea(
      child: Scaffold(
          backgroundColor: Color.fromARGB(255, 245, 245, 245),
          appBar: AppBar(
            toolbarHeight: 142,
            elevation: 0,
            backgroundColor: Color.fromARGB(255, 245, 245, 245),
            actions: [
              Container(
                padding: const EdgeInsets.only(top: 4),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0, bottom: 8),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width * 0.135,
                              child: Material(
                                shape: const CircleBorder(),
                                color: Color.fromARGB(255, 245, 245, 245),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  splashColor: Colors.grey.withOpacity(0.5),
                                  onTap: () {
                                    Future.delayed(
                                        const Duration(milliseconds: 50), () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Countries(),
                                        ),
                                      ).then((value) async {
                                        await loadCountryFilterValue();
                                      });
                                    });
                                  },
                                  child: const Icon(Icons.filter_list,
                                      color: Color.fromARGB(255, 80, 80, 80)),
                                ),
                              ),
                            ),
                            global == 'true'
                                ? Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 1.0),
                                        child: Text(
                                          'Global',
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 45, 45, 45),
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
                                          indicatorSize: const Size.square(1.8),
                                          innerColor: const Color.fromARGB(
                                              255, 228, 228, 228),
                                          indicatorColor: const Color.fromARGB(
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
                                            padding:
                                                EdgeInsets.only(bottom: 1.0),
                                            child: Text(
                                              'National',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 45, 45, 45),
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
                                              padding: const EdgeInsets.only(
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
                                        },
                                        iconBuilder:
                                            rollingIconBuilderStringThree,
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
                                        iconOpacity: 1,
                                      ),
                                    ],
                                  ),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 1.0),
                                  child: Text(
                                    messages == 'true' ? 'Messages' : 'Polls',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 45, 45, 45),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                AnimatedToggleSwitch<String>.rollingByHeight(
                                    height: 32,
                                    current: messages,
                                    values: const [
                                      'true',
                                      'false',
                                    ],
                                    onChanged: (valuem) {
                                      setValueM(valuem.toString());
                                      // setState(() {
                                      //   messages == "true"
                                      //       ? trendkeystorePoll = trendkeystore
                                      //       : trendkeystore = trendkeystorePoll;
                                      // });
                                    },
                                    iconBuilder: rollingIconBuilderStringTwo,
                                    borderRadius: BorderRadius.circular(25.0),
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
                            Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width * 0.135,
                              // alignment: Alignment.centerRight,
                              child: Material(
                                shape: const CircleBorder(),
                                color: Color.fromARGB(255, 245, 245, 245),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  splashColor: Colors.grey.withOpacity(0.5),
                                  onTap: () {
                                    Future.delayed(
                                        const Duration(milliseconds: 50), () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SettingsScreen()),
                                      );
                                    });
                                  },
                                  child: const Icon(Icons.settings,
                                      color: Color.fromARGB(255, 80, 80, 80)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 4.0,
                              ),
                              child: Container(
                                height: 45,
                                width: MediaQuery.of(context).size.width * 0.6,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(width: 0, color: Colors.grey),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                                child: Theme(
                                  data: ThemeData(
                                    colorScheme:
                                        ThemeData().colorScheme.copyWith(
                                              primary: const Color.fromARGB(
                                                  255, 131, 135, 138),
                                            ),
                                  ),
                                  child: TextField(
                                    onChanged: (val) {
                                      setState(() {});
                                      // initList(searchController.text);
                                      setState(() {
                                        showMessages = false;
                                      });
                                      isAllKey == false &&
                                              searchController.text.isEmpty
                                          ? setState(() {
                                              isAllKey = true;
                                            })
                                          : null;
                                    },

                                    onTap: () {
                                      setState(() {
                                        searchFieldSelected = true;
                                        showMessages = false;
                                      });
                                      isAllKey == false &&
                                              searchController.text.isEmpty
                                          ? setState(() {
                                              isAllKey = true;
                                            })
                                          : null;
                                      print('isAllKey $isAllKey');
                                      print('showMessages $showMessages');
                                    },
                                    // onSubmitted: (t) {
                                    //   setState(() {
                                    //     textfield1selected = false;
                                    //   });
                                    // },
                                    maxLines: 1,
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.search,
                                          color: Colors.grey, size: 25),
                                      hintText: isHome
                                          ? "Search Home"
                                          : "Search User",
                                      labelStyle: const TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.normal,
                                      ),
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.only(
                                        top: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isHome = true;

                                    isUser = false;
                                  });
                                },
                                child: Container(
                                    width: 35,
                                    height: 45,
                                    padding: EdgeInsets.only(
                                        top: 6, bottom: 6, left: 0, right: 0),
                                    decoration: BoxDecoration(
                                      color: isHome
                                          ? Colors.blue.withOpacity(0.3)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: isHome
                                          ? Border.all(
                                              width: 1, color: Colors.blue)
                                          : Border.all(
                                              width: 0, color: Colors.grey),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(Icons.home,
                                            color: isHome
                                                ? Colors.black
                                                : Colors.grey,
                                            size: 27),
                                      ],
                                    )),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isHome = false;

                                    isUser = true;
                                  });
                                },
                                child: Container(
                                  width: 35,
                                  height: 45,
                                  padding: const EdgeInsets.only(
                                      top: 6, bottom: 6, left: 0, right: 0),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? Colors.blue.withOpacity(0.3)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: isUser
                                        ? Border.all(
                                            width: 1, color: Colors.blue)
                                        : Border.all(
                                            width: 0, color: Colors.grey),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(Icons.person,
                                          color: isUser
                                              ? Colors.black
                                              : Colors.grey,
                                          size: 27),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 9),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            searchController.text.isEmpty && isAllKey && isHome
                                ? Icons.trending_up
                                : isUser
                                    ? Icons.person
                                    : Icons.key,
                            color: Colors.grey,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            searchController.text.isEmpty && isAllKey && isHome
                                ? 'Trending Keywords'
                                : isHome && showMessages == true
                                    ? 'Showing Results: ${trendkeystore}'
                                    : isHome &&
                                            showMessages == true &&
                                            messages != "true"
                                        ? 'Showing Results: ${trendkeystore}'
                                        : isAllKey == true &&
                                                searchController
                                                    .text.isNotEmpty &&
                                                isHome
                                            ? 'Searching for keyword: "${searchController.text}"'
                                            : isAllKey == false &&
                                                    searchController
                                                        .text.isNotEmpty &&
                                                    isHome
                                                ? 'Searching for keyword: "${searchController.text}"'
                                                : isUser &&
                                                        searchController
                                                            .text.isNotEmpty
                                                    ? 'Searching for users: "${searchController.text}"'
                                                    : isUser &&
                                                            searchController
                                                                .text.isEmpty
                                                        ? 'Searching for users: " "'
                                                        : '',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          body: isUser && searchController.text.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No Users Found.',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                      Text('Search text field is empty.',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : isUser
                  ? FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .orderBy(
                            'usernameLower',
                          )
                          .startAt(
                              [searchController.text.toLowerCase()]).endAt([
                        searchController.text.toLowerCase() + '\uf8ff'
                      ]).get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return (snapshot.data! as dynamic).docs.length == 0
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'No Users Found.',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 18),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount:
                                    (snapshot.data! as dynamic).docs.length,
                                itemBuilder: (context, index) {
                                  String? uid = (snapshot.data! as dynamic)
                                          .docs[index]["uid"] ??
                                      "";
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 2),
                                    child: Material(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      child: InkWell(
                                        splashColor:
                                            Colors.grey.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () {
                                          print("ontapdata");

                                          // Future.delayed(
                                          //     const Duration(
                                          //         milliseconds: 150), () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileAllUser(
                                                      uid: uid ?? ""),
                                            ),
                                          );
                                          // });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                width: 0, color: Colors.grey),
                                          ),
                                          child: Row(
                                            children: [
                                              Stack(
                                                children: [
                                                  (snapshot.data! as dynamic)
                                                                  .docs[index]
                                                              ['photoUrl'] !=
                                                          null
                                                      ? CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(
                                                          (snapshot.data!
                                                                      as dynamic)
                                                                  .docs[index]
                                                              ['photoUrl'],
                                                        ))
                                                      : const CircleAvatar(
                                                          backgroundImage:
                                                              AssetImage(
                                                                  'assets/avatarFT.jpg')),
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 4,
                                                    child: Row(
                                                      children: [
                                                        (snapshot.data! as dynamic)
                                                                            .docs[
                                                                        index][
                                                                    'profileFlag'] ==
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
                                                        (snapshot.data! as dynamic)
                                                                            .docs[
                                                                        index][
                                                                    'profileBadge'] ==
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
                                                                child:
                                                                    Container(
                                                                  child: const Icon(
                                                                      Icons
                                                                          .verified,
                                                                      color: Color.fromARGB(
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
                                              SizedBox(width: 12),
                                              Text(
                                                  (snapshot.data! as dynamic)
                                                      .docs[index]['username'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                      },
                    )
                  // : messages == "false" && searchController.text.isEmpty
                  //     ? ListView.builder(
                  //         itemCount: pollsList.length,
                  //         itemBuilder: (context, index) {
                  //           final User? user =
                  //               Provider.of<UserProvider>(context).getUser;

                  //           return PollCard(
                  //             poll: pollsList[index],
                  //             indexPlacement: index,
                  //           );
                  //         })
                  : searchController.text.isEmpty && isAllKey
                      ? Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.72,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0.0, vertical: 4),
                                child: FutureBuilder(
                                  future: messages == "true"
                                      ? getData()
                                      : getDataPoll(),
                                  builder: (BuildContext context, snapshot) {
                                    return ListView.builder(
                                      itemCount: messages == "true"
                                          ? list.length
                                          : listPoll.length,
                                      itemBuilder: (context, index) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 2),
                                        child: GestureDetector(
                                          onTap: () async {
                                            await messages == "true"
                                                ? initList(
                                                    list[index].tagName ?? "")
                                                : initPollList(
                                                    listPoll[index].tagName ??
                                                        "");
                                            setState(() {
                                              isAllKey = false;
                                              showMessages = true;
                                            });
                                          },
                                          child: NoRadioListTile<String>(
                                              start: (index + 1).toString(),
                                              center: messages == "true"
                                                  ? list[index].tagName ?? ""
                                                  : listPoll[index].tagName ??
                                                      "",
                                              end: messages == "true"
                                                  ? list[index]
                                                      .tagValue
                                                      .toString()
                                                  : listPoll[index]
                                                      .tagValue
                                                      .toString()),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : showMessages == true && isHome
                          ? ListView.builder(
                              itemCount: messages == "true"
                                  ? postsList.length
                                  : pollsList.length,
                              itemBuilder: (context, index) {
                                // Post post = Post.fromSnap(snapshot.data!.docs[index]);
                                final User? user =
                                    Provider.of<UserProvider>(context).getUser;

                                return messages == "true"
                                    ? PostCardTest(
                                        post: postsList[index],
                                        indexPlacement: index,
                                        // currentUserId: null,
                                      )
                                    : PollCard(
                                        poll: pollsList[index],
                                        indexPlacement: index,
                                        // currentUserId: null,
                                      );
                              },
                            )
                          : isAllKey == false &&
                                  searchController.text.isNotEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.72,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0.0, vertical: 4),
                                        child: FutureBuilder(
                                            future: messages == "true"
                                                ? getsearchData(
                                                    searchController.text)
                                                : getsearchDataPoll(
                                                    searchController.text),
                                            builder: (BuildContext context,
                                                snapshot) {
                                              return _searchResult.isNotEmpty
                                                  ? ListView.builder(
                                                      itemCount: messages ==
                                                              "true"
                                                          ? _searchResult.length
                                                          : _searchResultPoll
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) =>
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        4,
                                                                    vertical:
                                                                        2),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    setState(
                                                                        () {
                                                                      // searchController
                                                                      //     .clear();
                                                                      isAllKey =
                                                                          false;
                                                                      showMessages =
                                                                          true;
                                                                      messages ==
                                                                              "true"
                                                                          ? initList(_searchResult[index].tagName ??
                                                                              "")
                                                                          : initPollList(_searchResultPoll[index].tagName ??
                                                                              "");

                                                                      print(
                                                                          isAllKey);
                                                                    });
                                                                  },
                                                                  child:
                                                                      NoRadioListTile<
                                                                          String>(
                                                                    start: (index +
                                                                            1)
                                                                        .toString(),
                                                                    center: messages ==
                                                                            "true"
                                                                        ? _searchResult[index].tagName ??
                                                                            ""
                                                                        : _searchResultPoll[index].tagName ??
                                                                            "",
                                                                    end: messages ==
                                                                            "true"
                                                                        ? _searchResult[index]
                                                                            .tagValue
                                                                            .toString()
                                                                        : _searchResultPoll[index]
                                                                            .tagValue
                                                                            .toString(),
                                                                  ),
                                                                ),
                                                              ))
                                                  : Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: const [
                                                          Text(
                                                            'No Keywords Found.',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 18),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                            }),
                                      ),
                                    ),
                                  ),
                                )
                              : isAllKey == true &&
                                      searchController.text.isNotEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.72,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0.0, vertical: 4),
                                            child: FutureBuilder(
                                                future: messages == "true"
                                                    ? getsearchData(
                                                        searchController.text)
                                                    : getsearchDataPoll(
                                                        searchController.text),
                                                builder: (BuildContext context,
                                                    snapshot) {
                                                  return
                                                      // _searchResult
                                                      //             .isEmpty ||
                                                      //         _searchResultPoll
                                                      //             .isEmpty
                                                      //     ? Center(
                                                      //         child: Column(
                                                      //           mainAxisAlignment:
                                                      //               MainAxisAlignment
                                                      //                   .center,
                                                      //           children: const [
                                                      //             Text(
                                                      //               'No Keywords Found.',
                                                      //               style: TextStyle(
                                                      //                   color: Colors
                                                      //                       .grey,
                                                      //                   fontSize:
                                                      //                       18),
                                                      //             ),
                                                      //           ],
                                                      //         ),
                                                      //       )
                                                      //     :
                                                      ListView.builder(
                                                    itemCount: messages ==
                                                            "true"
                                                        ? _searchResult.length
                                                        : _searchResultPoll
                                                            .length,
                                                    itemBuilder:
                                                        (context, index) =>
                                                            Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 4,
                                                          vertical: 2),
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          setState(() {
                                                            // searchController
                                                            //     .clear();
                                                            // isAllKey =
                                                            //     false;
                                                            showMessages = true;
                                                            messages == "true"
                                                                ? initList(_searchResult[
                                                                            index]
                                                                        .tagName ??
                                                                    "")
                                                                : initPollList(
                                                                    _searchResultPoll[index]
                                                                            .tagName ??
                                                                        "");
                                                            print(isAllKey);
                                                          });
                                                        },
                                                        child: NoRadioListTile<
                                                                String>(
                                                            start: (index + 1)
                                                                .toString(),
                                                            center: messages ==
                                                                    "true"
                                                                ? _searchResult[
                                                                            index]
                                                                        .tagName ??
                                                                    ""
                                                                : _searchResultPoll[
                                                                            index]
                                                                        .tagName ??
                                                                    "",
                                                            end: messages ==
                                                                    "true"
                                                                ? _searchResult[
                                                                        index]
                                                                    .tagValue
                                                                    .toString()
                                                                : _searchResultPoll[
                                                                        index]
                                                                    .tagValue
                                                                    .toString()),
                                                      ),
                                                    ),
                                                  );
                                                  // : ListView.builder(
                                                  //     itemCount:
                                                  //         _searchResultPoll
                                                  //             .length,
                                                  //     itemBuilder:
                                                  //         (context,
                                                  //                 index) =>
                                                  //             Padding(
                                                  //       padding: const EdgeInsets
                                                  //               .symmetric(
                                                  //           horizontal:
                                                  //               4,
                                                  //           vertical:
                                                  //               2),
                                                  //       child:
                                                  //           GestureDetector(
                                                  //         onTap:
                                                  //             () async {
                                                  //           setState(
                                                  //               () {
                                                  //             showMessages =
                                                  //                 true;
                                                  //             initPollList(
                                                  //                 _searchResultPoll[index].tagName ??
                                                  //                     "");
                                                  //           });
                                                  //         },
                                                  //         child:
                                                  //             NoRadioListTile<
                                                  //                 String>(
                                                  //           start: (index +
                                                  //                   1)
                                                  //               .toString(),
                                                  //           center:
                                                  //               _searchResultPoll[index].tagName ??
                                                  //                   "",
                                                  //           end: _searchResultPoll[
                                                  //                   index]
                                                  //               .tagValue
                                                  //               .toString(),
                                                  //         ),
                                                  //       ),
                                                  //     ),
                                                  //   );
                                                }),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container()),
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

class NoRadioListTile<T> extends StatefulWidget {
  final String start;
  final String center;
  final String end;

  const NoRadioListTile({
    required this.start,
    required this.center,
    required this.end,
  });

  @override
  State<NoRadioListTile<T>> createState() => _NoRadioListTileState<T>();
}

class _NoRadioListTileState<T> extends State<NoRadioListTile<T>> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: SizedBox(
        height: 35,
        child: Container(
          // width: MediaQuery.of(context).size.width * 0.92,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 0.3, color: Colors.grey),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.start,
                style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                widget.center,
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                widget.end,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
