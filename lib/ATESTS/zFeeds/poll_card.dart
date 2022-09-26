import 'dart:async';

import 'package:aft/ATESTS/models/post.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../methods/auth_methods.dart';
import '../methods/firestore_methods.dart';
import '../models/user.dart';
import '../screens/profile_all_user.dart';
import '../utils/utils.dart';
import '../poll/poll_view.dart';
import '../provider/user_provider.dart';
import '../screens/full_message.dart';
import '../screens/full_message_poll.dart';
import '../screens/report_user_screen.dart';

import '../models/poll.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PollCard extends StatefulWidget {
  final Poll poll;
  final indexPlacement;

  const PollCard({
    Key? key,
    required this.poll,
    required this.indexPlacement,
  }) : super(key: key);

  @override
  State<PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  final AuthMethods _authMethods = AuthMethods();
  User? _userProfile;
  late Poll _poll;
  bool _isPollEnded = false;
  bool isLikeAnimating = false;
  int commentLen = 0;
  String placement = '';
  bool tileClick = false;
  // late Poll PollData;
  bool initialized = false;
  DateTime ntpTime = DateTime.now();
  var durationForMinutes = 0;
  var durationForHours = 0;
  var durationInDay = 0;
  Timer? timer;

  final TextStyle _pollOptionTextStyle =
      const TextStyle(fontSize: 14, overflow: TextOverflow.ellipsis);

  @override
  void initState() {
    super.initState();
    _poll = widget.poll;
    placement = '#${(widget.indexPlacement + 1).toString()}';
    getAllUserDetails();
    //make sure _initTimer is declared over _startTimer
    // _initTimer();
    // _startTimer();
  }

  getAllUserDetails() async {
    User userProfile = await _authMethods.getUserProfileDetails(_poll.uid);
    if (!mounted) return;
    setState(() {
      _userProfile = userProfile;
    });
  }

  // _startTimer() async {
  //   timer = Timer.periodic(const Duration(minutes: 1), (Timer t) async {
  //     var ntpTime = await NTP.now(lookUpAddress: '1.amazon.pool.ntp.org');
  //     // var dateNow = DateTime.now();
  //     setState(() {
  //       durationForMinutes = 59 - ntpTime.minute;
  //       durationForHours = 23 - ntpTime.hour;
  //     });
  //   });
  // }

  // _initTimer() async {
  //   var ntpTime = await NTP.now(lookUpAddress: '1.amazon.pool.ntp.org');
  //   // if (!initialized)
  //   setState(() {
  //     durationForMinutes = 59 - ntpTime.minute;
  //     durationForHours = 23 - ntpTime.hour;
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;
    // print('_poll.endDate: ${_poll.endDate.runtimeType}');

    _isPollEnded = (_poll.endDate as Timestamp)
        .toDate()
        .difference(
          DateTime.now(),
        )
        .isNegative;

    // return StreamBuilder(
    //   stream: FirebaseFirestore.instance
    //       .collection('polls')
    //       .doc(widget.poll.pollId)
    //       .snapshots(),
    //   builder: (context,
    //       AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Center(
    //         child: CircularProgressIndicator(),
    //       );
    //     }

    //     _poll = snapshot.data != null ? Poll.fromSnap(snapshot.data!) : _poll;

    //     _isPollEnded = (_poll.endDate as Timestamp)
    //       .toDate()
    //       .difference(
    //         DateTime.now(),
    //       )
    //       .isNegative;

    return Padding(
      key: Key(_poll.pollId),
      padding: const EdgeInsets.only(
        top: 10,
        right: 10,
        left: 10,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.5, color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: tileClick ? Color.fromARGB(255, 245, 245, 245) : Colors.white,
        ),
        child: Theme(
          data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Color.fromARGB(255, 245, 245, 245)),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                setState(() {
                  tileClick = true;
                });
                Future.delayed(const Duration(milliseconds: 50), () async {
                  await Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FullMessagePoll(
                              poll: _poll,
                              pollId: _poll.pollId,
                              indexPlacement: widget.indexPlacement,
                            )),
                  );
                  setState(() {
                    tileClick = false;
                  });
                });
              },
              child: Container(
                decoration: BoxDecoration(color: Colors.transparent),
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          // bottom: 6,
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) => ProfilePoll(
                                //             poll: _poll,
                                //           )),
                                // );
                              },
                              child: Stack(
                                children: [
                                  _userProfile?.photoUrl != null
                                      ? Material(
                                          color: Colors.grey,
                                          // elevation: 4.0,
                                          shape: CircleBorder(),
                                          clipBehavior: Clip.hardEdge,
                                          child: Ink.image(
                                            image: NetworkImage(
                                                _userProfile?.photoUrl ?? ''),

                                            fit: BoxFit.cover,
                                            width: 40,
                                            height: 40,
                                            // splashColor: Colors.blue,
                                            child: InkWell(
                                              splashColor:
                                                  Colors.white.withOpacity(0.5),
                                              onTap: () {
                                                Future.delayed(
                                                  const Duration(
                                                      milliseconds: 100),
                                                  () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProfileAllUser(
                                                                uid: _poll.uid,
                                                              )),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        )
                                      : Material(
                                          color: Colors.grey,
                                          // elevation: 4.0,
                                          shape: CircleBorder(),
                                          clipBehavior: Clip.hardEdge,
                                          child: Ink.image(
                                            image: AssetImage(
                                                'assets/avatarFT.jpg'),
                                            fit: BoxFit.cover,
                                            width: 40,
                                            height: 40,
                                            // splashColor: Colors.blue,
                                            child: InkWell(
                                              splashColor:
                                                  Colors.white.withOpacity(0.5),
                                              onTap: () {
                                                Future.delayed(
                                                  const Duration(
                                                      milliseconds: 100),
                                                  () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProfileAllUser(
                                                                uid: _poll.uid,
                                                              )),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                  Positioned(
                                    bottom: 0,
                                    right: 2.8,
                                    child: Container(
                                      child: Row(
                                        children: [
                                          _userProfile?.profileFlag == "true"
                                              ? Container(
                                                  width: 15.5,
                                                  height: 7.7,
                                                  child: Image.asset(
                                                      'icons/flags/png/${_userProfile?.country}.png',
                                                      package: 'country_icons'))
                                              : Row()
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 1,
                                    child: Row(
                                      children: [
                                        _userProfile?.profileBadge == "true"
                                            ? Stack(
                                                children: [
                                                  Positioned(
                                                    right: 3,
                                                    top: 3,
                                                    child: CircleAvatar(
                                                      radius: 4,
                                                      backgroundColor:
                                                          Colors.white,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    child: Container(
                                                      child: Icon(
                                                          Icons.verified,
                                                          color: Color.fromARGB(
                                                              255,
                                                              113,
                                                              191,
                                                              255),
                                                          size: 13),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Row()
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileAllUser(
                                                    uid: _poll.uid,
                                                  )),
                                        );
                                      },
                                      child: Text(
                                        _userProfile?.username ?? '',
                                        maxLines: 1,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            letterSpacing: 0.5),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      DateFormat.yMMMd().format(
                                        _poll.datePublished.toDate(),
                                      ),
                                      style: const TextStyle(
                                          fontSize: 12.5, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 30,
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              // alignment: Alignment.centerRight,
                              child: Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  splashColor: Colors.grey.withOpacity(0.5),
                                  onTap: () {
                                    Future.delayed(
                                        const Duration(milliseconds: 50), () {
                                      _poll.uid == user?.uid
                                          ? showDialog(
                                              context: context,
                                              builder: (context) {
                                                return SimpleDialog(
                                                  children: [
                                                    SimpleDialogOption(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                              Icons.delete),
                                                          Container(width: 10),
                                                          const Text(
                                                              'Delete Poll',
                                                              style: TextStyle(
                                                                  letterSpacing:
                                                                      0.2,
                                                                  fontSize:
                                                                      15)),
                                                        ],
                                                      ),
                                                      onPressed: () {},
                                                    ),
                                                  ],
                                                );
                                              })
                                          : showDialog(
                                              context: context,
                                              builder: (context) {
                                                return SimpleDialog(
                                                  children: [
                                                    SimpleDialogOption(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                              Icons.block),
                                                          Container(width: 10),
                                                          const Text(
                                                              'Block User',
                                                              style: TextStyle(
                                                                  letterSpacing:
                                                                      0.2,
                                                                  fontSize:
                                                                      15)),
                                                        ],
                                                      ),
                                                      onPressed: () {
                                                        Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    150), () {
                                                          performLoggedUserAction(
                                                            context: context,
                                                            action: () {},
                                                          );
                                                        });
                                                      },
                                                    ),
                                                    SimpleDialogOption(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      child: Row(
                                                        children: [
                                                          const Icon(Icons
                                                              .report_outlined),
                                                          Container(width: 10),
                                                          const Text(
                                                              'Report Poll',
                                                              style: TextStyle(
                                                                  letterSpacing:
                                                                      0.2,
                                                                  fontSize:
                                                                      15)),
                                                        ],
                                                      ),
                                                      onPressed: () {
                                                        Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  150),
                                                          () {
                                                            performLoggedUserAction(
                                                              context: context,
                                                              action: () {
                                                                // Future.delayed(
                                                                //     const Duration(
                                                                //         milliseconds:
                                                                //             150),
                                                                //     () {
                                                                // _poll.reportUIDs
                                                                //         .contains(user
                                                                //             ?.UID)
                                                                //     ? Navigator.pop(
                                                                //         context,
                                                                //         showSnackBar(
                                                                //             'Poll already reported.',
                                                                //             context))
                                                                //     // Navigator.pop(
                                                                //     //     context)
                                                                //     : reportShortDialog(
                                                                //         context:
                                                                //             context,
                                                                //         type:
                                                                //             'poll',
                                                                //         typeCapital:
                                                                //             'Poll',
                                                                //         action:
                                                                //             () async {
                                                                //           await FirestoreMethods().reportPoll(
                                                                //               _poll.pollId,
                                                                //               user?.UID ?? '',
                                                                //               _poll.reportUIDs,
                                                                //               _poll.reportUIDs.length == 0 ? 1 : _poll.reportUIDs.length + 1,
                                                                //               _poll.ZreportCounter);
                                                                //           showSnackBar('Poll successfully reported.',
                                                                //               context);
                                                                //           Navigator.pop(context);
                                                                //           Navigator.pop(context);
                                                                //         },
                                                                //       );
                                                                // });
                                                              },
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                );
                                              });
                                    });
                                  },
                                  child: const Icon(Icons.more_vert),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            _poll.pollTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        PollView(
                          pollId: _poll.pollId,
                          pollEnded: _isPollEnded,
                          hasVoted: _poll.allVotesUIDs.contains(user?.uid),
                          userVotedOptionId:
                              _getUserPollOptionId(user?.uid ?? ""),
                          onVoted:
                              (PollOption pollOption, int newTotalVotes) async {
                            if (!_isPollEnded) {
                              performLoggedUserAction(
                                  context: context,
                                  action: () async {
                                    await FirestoreMethods().poll(
                                      poll: _poll,
                                      uid: user?.uid ?? '',
                                      optionIndex: pollOption.id!,
                                    );
                                  });

                              // var PostTest = await FirebaseFirestore.instance
                              //     .collection("polls")
                              //     .doc(_poll.pollId);
                              // PostTest.get().then(
                              //   (DocumentSnapshot doc) {
                              //     final data =
                              //         doc.data() as Map<String, dynamic>;

                              //     PollData = Poll.fromMap(data);
                              //     print(
                              //         "_poll.allVotesUIDs ${PollData.votesUIDs}");
                              //     _poll = PollData;
                              //     print(
                              //         "_poll.allVotesUIDs ${_poll.votesUIDs}");
                              //   },
                              // );

                              DocumentSnapshot snap = await FirebaseFirestore
                                  .instance
                                  .collection('polls')
                                  .doc(widget.poll.pollId)
                                  .get();

                              setState(() {
                                _poll = Poll.fromSnap(snap);
                                print(_poll.toJson());
                              });
                            }

                            print('newTotalVotes: ${newTotalVotes}');
                            print('Voted: ${pollOption.id}');
                          },
                          leadingVotedProgessColor: Colors.blue.shade200,
                          pollOptionsSplashColor: Colors.white,
                          votedProgressColor: Colors.blueGrey.withOpacity(0.3),
                          votedBackgroundColor: Colors.grey.withOpacity(0.2),
                          votedCheckmark: const Icon(
                            Icons.check_circle_outline,
                            color: Color.fromARGB(255, 10, 147, 15),
                            size: 18,
                          ),
                          // pollTitle: Align(
                          //   alignment: Alignment.center,
                          //   child: Text(
                          //     _poll.pollTitle,
                          //     textAlign: TextAlign.center,
                          //     style: const TextStyle(
                          //       fontSize: 16,
                          //       fontWeight: FontWeight.w500,
                          //     ),
                          //   ),
                          // ),
                          pollOptions: [
                            PollOption(
                              id: 1,
                              title: Expanded(
                                child: Container(
                                  child: Text(_poll.option1,
                                      maxLines: 1, style: _pollOptionTextStyle),
                                ),
                              ),
                              // fontSize: _poll.option1.length == 25
                              //     ? 10.7
                              //     : _poll.option1.length == 24
                              //         ? 11.2
                              //         : _poll.option1.length == 23
                              //             ? 11.7
                              //             : _poll.option1.length == 22
                              //                 ? 12.2
                              //                 : _poll.option1.length == 21
                              //                     ? 12.7
                              //                     : _poll.option1.length == 20
                              //                         ? 13.2
                              //                         : _poll.option1.length ==
                              //                                 19
                              //                             ? 13.7
                              //                             : _poll.option1
                              //                                         .length ==
                              //                                     18
                              //                                 ? 14.2
                              //                                 : _poll.option1
                              //                                             .length ==
                              //                                         17
                              //                                     ? 14.2
                              //                                     : _poll.option1
                              //                                                 .length ==
                              //                                             16
                              //                                         ? 15.2
                              //                                         : 16)),
                              votes: _poll.vote1.length,
                            ),
                            PollOption(
                              id: 2,
                              title: Expanded(
                                child: Text(_poll.option2,
                                    maxLines: 1, style: _pollOptionTextStyle),
                              ),
                              votes: _poll.vote2.length,
                            ),
                            if (_poll.option3 != '')
                              PollOption(
                                id: 3,
                                title: Expanded(
                                  child: Text(_poll.option3,
                                      maxLines: 1, style: _pollOptionTextStyle),
                                ),
                                votes: _poll.vote3.length,
                              ),
                            if (_poll.option4 != '')
                              PollOption(
                                id: 4,
                                title: Expanded(
                                  child: Text(_poll.option4,
                                      maxLines: 1, style: _pollOptionTextStyle),
                                ),
                                votes: _poll.vote4.length,
                              ),
                            if (_poll.option5 != '')
                              PollOption(
                                id: 5,
                                title: Expanded(
                                  child: Text(_poll.option5,
                                      maxLines: 1, style: _pollOptionTextStyle),
                                ),
                                votes: _poll.vote5.length,
                              ),
                            if (_poll.option6 != '')
                              PollOption(
                                id: 6,
                                title: Expanded(
                                  child: Text(_poll.option6,
                                      maxLines: 1, style: _pollOptionTextStyle),
                                ),
                                votes: _poll.vote6.length,
                              ),
                            if (_poll.option7 != '')
                              PollOption(
                                id: 7,
                                title: Expanded(
                                  child: Text(_poll.option7,
                                      maxLines: 1, style: _pollOptionTextStyle),
                                ),
                                votes: _poll.vote7.length,
                              ),
                            if (_poll.option8 != '')
                              PollOption(
                                id: 8,
                                title: Expanded(
                                  child: Text(_poll.option8,
                                      maxLines: 1, style: _pollOptionTextStyle),
                                ),
                                votes: _poll.vote8.length,
                              ),
                            if (_poll.option9 != '')
                              PollOption(
                                id: 9,
                                title: Expanded(
                                  child: Text(_poll.option9,
                                      maxLines: 1, style: _pollOptionTextStyle),
                                ),
                                votes: _poll.vote9.length,
                              ),
                            if (_poll.option10 != '')
                              PollOption(
                                id: 10,
                                title: Expanded(
                                  child: Text(_poll.option10,
                                      maxLines: 1, style: _pollOptionTextStyle),
                                ),
                                votes: _poll.vote10.length,
                              ),
                          ],
                          // metaWidget: Container(
                          //   height: 40,
                          //   decoration: BoxDecoration(
                          //     // color: Colors.orange,
                          //     border: Border(
                          //       top: BorderSide(
                          //           width: 1,
                          //           color: Color.fromARGB(255, 218, 216, 216)),
                          //     ),
                          //   ),
                          //   child: Padding(
                          //     padding: const EdgeInsets.only(top: 4.0),
                          //     child: Container(
                          //       width: MediaQuery.of(context).size.width * 1,
                          //       child: Row(
                          //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //         children: [
                          //           Material(
                          //             color: Colors.transparent,
                          //             child: InkWell(
                          //               customBorder: const CircleBorder(),
                          //               splashColor: Colors.grey.withOpacity(0.3),
                          //               onTap: () {
                          //                 Future.delayed(
                          //                   const Duration(milliseconds: 50),
                          //                   () {
                          //                     _scoreDialog(context);
                          //                   },
                          //                 );
                          //               },
                          //               child: Container(
                          //                 // color: Colors.blue,
                          //                 child: Padding(
                          //                   padding: const EdgeInsets.only(left: 0.0),
                          //                   child: Text(placement,
                          //                       style: TextStyle(
                          //                           color: Colors.black,
                          //                           fontSize: 24,
                          //                           fontStyle: FontStyle.italic,
                          //                           fontWeight: FontWeight.bold)),
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //           const SizedBox(width: 0),
                          //           const Text(
                          //             '•',
                          //             style: TextStyle(
                          //               fontSize: 20,
                          //             ),
                          //           ),
                          //           const SizedBox(
                          //             width: 0,
                          //           ),
                          //           Padding(
                          //             padding: const EdgeInsets.only(right: 0.0),
                          //             child: Text(
                          //               _poll.totalVotes == 1
                          //                   ? '${_poll.totalVotes} Vote'
                          //                   : '${_poll.totalVotes} Votes',
                          //               style: TextStyle(
                          //                 fontSize: 14,
                          //                 fontWeight: FontWeight.w500,
                          //               ),
                          //             ),
                          //           ),
                          //           const SizedBox(width: 00),
                          //           const Text(
                          //             '•',
                          //             style: TextStyle(
                          //               fontSize: 20,
                          //             ),
                          //           ),
                          //           const SizedBox(
                          //             width: 00,
                          //           ),
                          //           Padding(
                          //             padding: const EdgeInsets.only(right: 0.0),
                          //             child: Text(
                          //               _pollTimeLeftLabel(poll: _poll),
                          //               style: const TextStyle(
                          //                 fontSize: 14,
                          //                 fontWeight: FontWeight.w500,
                          //               ),
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // metaWidget: Column(
                          //   children: [
                          //     Container(
                          //       decoration: BoxDecoration(
                          //         border: Border(
                          //           top: BorderSide(
                          //               width: 0.5, color: Colors.grey),
                          //         ),
                          //       ),
                          //       child: Padding(
                          //         padding: const EdgeInsets.only(top: 8.0),
                          //         child: Row(
                          //           mainAxisAlignment:
                          //               MainAxisAlignment.spaceEvenly,
                          //           children: [
                          //             Material(
                          //               color: Colors.transparent,
                          //               child: InkWell(
                          //                 borderRadius:
                          //                     BorderRadius.circular(5),
                          //                 // customBorder: const CircleBorder(),
                          //                 splashColor:
                          //                     Colors.grey.withOpacity(0.3),
                          //                 onTap: () {
                          //                   Future.delayed(
                          //                       const Duration(
                          //                           milliseconds: 50), () {
                          //                     scoreDialogPoll(context: context);
                          //                   });
                          //                 },
                          //                 child: Text(placement,
                          //                     style: const TextStyle(
                          //                         color: Colors.black,
                          //                         fontSize: 24,
                          //                         fontStyle: FontStyle.italic,
                          //                         fontWeight: FontWeight.bold)),
                          //               ),
                          //             ),
                          //             // const SizedBox(width: 0),
                          //             // const Text(
                          //             //   '•',
                          //             //   style: TextStyle(
                          //             //     fontSize: 20,
                          //             //   ),
                          //             // ),
                          //             // const SizedBox(
                          //             //   width: 0,
                          //             // ),
                          //             Padding(
                          //               padding:
                          //                   const EdgeInsets.only(right: 0.0),
                          //               child: Text(
                          //                 _poll.totalVotes == 1
                          //                     ? 'Score/Votes: ${_poll.totalVotes}'
                          //                     : 'Score/Votes: ${_poll.totalVotes}',
                          //                 style: const TextStyle(
                          //                   fontSize: 14,
                          //                   fontWeight: FontWeight.w500,
                          //                 ),
                          //               ),
                          //             ),
                          //             // const SizedBox(width: 00),
                          //             // const Text(
                          //             //   '•',
                          //             //   style: TextStyle(
                          //             //     fontSize: 20,
                          //             //   ),
                          //             // ),
                          //             // Padding(
                          //             //   padding:
                          //             //       const EdgeInsets.only(right: 0.0),
                          //             //   child: Text(
                          //             //     _pollTimeLeftLabel(poll: _poll),
                          //             //     style: const TextStyle(
                          //             //       fontSize: 14,
                          //             //       fontWeight: FontWeight.w500,
                          //             //     ),
                          //             //   ),
                          //             // ),
                          //           ],
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ),
                        // Positioned.fill(
                        //     child: Visibility(
                        //   visible: _isPollEnded,
                        //   child: Container(
                        //     color: Colors.cyanAccent.withOpacity(0.0),
                        //   ),
                        // )),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 0.0,
                        top: 0,
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 0.0, bottom: 0, right: 4, left: 4),
                          child: Container(
                            height: 0,
                            width: MediaQuery.of(context).size.width,
                            // alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(width: 0.5, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // color: Colors.blue,
                    Container(
                      padding: EdgeInsets.only(
                          bottom: 10, top: 8, right: 10, left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(5),
                              // customBorder: const CircleBorder(),
                              splashColor: Colors.grey.withOpacity(0.3),
                              onTap: () {
                                Future.delayed(const Duration(milliseconds: 50),
                                    () {
                                  // scoreDialogPoll(context: context);
                                });
                              },
                              child: Text(placement,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 143, 143, 143),
                                      fontSize: 24,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                'Votes',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Color.fromARGB(255, 132, 132, 132),
                                    letterSpacing: 0),
                              ),
                              Container(height: 0),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_box,
                                    size: 15,
                                    color: Color.fromARGB(255, 187, 187, 187),
                                  ),
                                  Container(width: 4),
                                  Text(
                                    _poll.totalVotes == 1
                                        ? '${_poll.totalVotes}'
                                        : '${_poll.totalVotes}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            Color.fromARGB(255, 132, 132, 132),
                                        letterSpacing: 0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                            child: InkWell(
                              splashColor: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(25),
                              onTap: () {
                                Future.delayed(
                                    const Duration(milliseconds: 100), () {
                                  // timerDialog(
                                  //     context: context,
                                  //     minutes: '${durationForMinutes}',
                                  //     hours: '${durationForHours}',
                                  //     days: '0',
                                  //     type: 'poll',
                                  //     votingEnd: false
                                  //        );
                                });
                              },
                              child: Container(
                                child: Column(
                                  children: [
                                    Text(
                                      'Time Left',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color.fromARGB(
                                              255, 132, 132, 132),
                                          letterSpacing: 0),
                                    ),
                                    Container(height: 0),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.timer,
                                          size: 15,
                                          color: Color.fromARGB(
                                              255, 187, 187, 187),
                                        ),
                                        Container(width: 4),
                                        Text(
                                          'None',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Color.fromARGB(
                                                  255, 132, 132, 132),
                                              letterSpacing: 0),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                'Comments',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color.fromARGB(255, 132, 132, 132),
                                    letterSpacing: 0),
                              ),
                              SizedBox(height: 0),
                              Row(
                                children: [
                                  Icon(
                                    Icons.comment,
                                    size: 14,
                                    color: Color.fromARGB(255, 187, 187, 187),
                                  ),
                                  Container(width: 8),
                                  Center(
                                    child: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('poll')
                                          .doc(_poll.pollId)
                                          .collection('comments')
                                          .snapshots(),
                                      builder: (content, snapshot) {
                                        print(
                                            'BEFORE SNAPSHOT _post.comments: ${widget.poll.comments}');

                                        return Text(
                                          '${(snapshot.data as dynamic)?.docs.length ?? 0}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color.fromARGB(
                                                  255, 132, 132, 132),
                                              letterSpacing: 0),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
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
          // Row(
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.only(
          //         bottom: 8.0,
          //         top: 0,
          //       ),
          //       child: Expanded(
          //         child: Padding(
          //           padding: const EdgeInsets.only(top: 0.0),
          //           child: Padding(
          //             padding: const EdgeInsets.only(top: 2.0),
          //             child: Container(
          //               height: 26,
          //               color: Colors.blue,
          //               child: Row(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 children: [
          //                   const Icon(
          //                     MyFlutterApp.comments,
          //                     size: 16,
          //                     color:
          //                         Color.fromARGB(255, 187, 187, 187),
          //                   ),
          //                   Container(width: 8),
          //                   Container(
          //                     child: Center(
          //                       child: StreamBuilder(
          //                         stream: FirebaseFirestore.instance
          //                             .collection('polls')
          //                             .doc(_poll.pollId)
          //                             .collection('comments')
          //                             .snapshots(),
          //                         builder: (content, snapshot) {
          //                           print(
          //                               'BEFORE SNAPSHOT _poll.comments: ${widget.poll.comments}');

          //                           return Text(
          //                             '${(snapshot.data as dynamic)?.docs.length ?? 0} Comments',
          //                             style: const TextStyle(
          //                                 fontSize: 13,
          //                                 color: Color.fromARGB(
          //                                     255, 132, 132, 132),
          //                                 letterSpacing: 0),
          //                           );
          //                         },
          //                       ),
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ),
      ),
    );

    //     }
    //   );
  }

  int? _getUserPollOptionId(String uid) {
    print("uid: $uid");
    int? optionId;
    for (int i = 1; i <= 10; i++) {
      switch (i) {
        case 1:
          if (_poll.vote1.contains(uid)) {
            optionId = i;
          }
          break;
        case 2:
          if (_poll.vote2.contains(uid)) {
            optionId = i;
          }
          break;
        case 3:
          if (_poll.vote3.contains(uid)) {
            optionId = i;
          }
          break;
        case 4:
          if (_poll.vote4.contains(uid)) {
            optionId = i;
          }
          break;
        case 5:
          if (_poll.vote5.contains(uid)) {
            optionId = i;
          }
          break;
        case 6:
          if (_poll.vote6.contains(uid)) {
            optionId = i;
          }
          break;
        case 7:
          if (_poll.vote7.contains(uid)) {
            optionId = i;
          }
          break;
        case 8:
          if (_poll.vote8.contains(uid)) {
            optionId = i;
          }
          break;
        case 9:
          if (_poll.vote9.contains(uid)) {
            optionId = i;
          }
          break;
        case 10:
          if (_poll.vote10.contains(uid)) {
            optionId = i;
          }
          break;
      }
    }
    print("POLLED optionId: $optionId");
    return optionId;
  }
}
