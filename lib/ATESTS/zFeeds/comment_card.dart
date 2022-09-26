import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../methods/auth_methods.dart';
import '../methods/firestore_methods.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../utils/utils.dart';
import '../provider/user_provider.dart';
import '../screens/full_message.dart';
import '../screens/like_animation.dart';
import '../screens/report_user_screen.dart';
import 'dart:ui' as ui;

class CommentCard extends StatefulWidget {
  // Comment
  final postId;
  final postUId;
  final snap;
  final bool? plus;
  final bool? neutral;
  final bool? minus;
  final Function parentSetState;

  // Reply
  final bool isReply;
  final Post? parentPost;
  final String? parentCommentId;
  // final FocusNode? parentFocusNode;
  // final TextEditingController? parentReplyTextController;
  final String? parentReplyId;

  const CommentCard({
    Key? key,

    // Reply
    this.isReply = false,
    this.parentCommentId,
    // this.parentFocusNode,
    // this.parentReplyTextController,
    this.parentPost,
    this.parentReplyId,

    // Comment
    required this.postId,
    required this.postUId,
    required this.snap,
    this.plus,
    this.neutral,
    this.minus,
    required this.parentSetState,
  }) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  // late Post _post;
  User? user;
  final TextEditingController _replyController = TextEditingController();
  FocusNode currentReplyFocusNode = FocusNode();
  bool isReadmore = false;
  bool showMoreButton = true;
  bool _replyingOnComment = false;
  bool _showCommentReplies = false;
  int _likes = 0;
  int _dislikes = 0;
  dynamic commentReplies;
  final AuthMethods _authMethods = AuthMethods();
  User? _userProfile;
  var postUID = "";

  @override
  void dispose() {
    super.dispose();
    _replyController.dispose();
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

  _deletePost(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    Container(width: 10),
                    Text(widget.isReply ? 'Delete Reply' : 'Delete Comment',
                        style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
                  ],
                ),
                onPressed: () async {
                  widget.isReply
                      ? FirestoreMethods().deleteReply(widget.postId,
                          widget.parentCommentId!, widget.snap['replyId'])
                      : FirestoreMethods().deleteComment(
                          widget.postId,
                          widget.snap['commentId'],
                        );
                  Navigator.of(context).pop();
                  showSnackBar(
                      widget.isReply ? 'Reply Deleted' : 'Comment Deleted',
                      context);
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    // _post = widget.parentPost!;
    getUserDetails();
    postUID = widget.postUId ?? "";
    print("test--2" + (widget.postUId ?? ""));
  }

  getUserDetails() async {
    User userProfile =
        await _authMethods.getUserProfileDetails(widget.snap['uid']);
    setState(() {
      _userProfile = userProfile;
    });
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserProvider>(context).getUser;
    print('widget.snap: ${widget.snap}');

    _replyingOnComment = widget.isReply
        ? widget.parentReplyId == currentReplyCommentId
        : widget.snap['commentId'] == currentReplyCommentId;

    _likes = widget.snap['likes']?.length ?? 0;
    _dislikes = widget.snap['dislikes']?.length ?? 0;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: widget.isReply ? 42 : 0,
            bottom: widget.isReply ? 6 : 0,
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  // color: Colors.blue,
                  border: Border(
                    top: BorderSide(
                        width: 1,
                        color: widget.isReply
                            ? Colors.white
                            : Color.fromARGB(255, 218, 216, 216)),
                  ),
                ),
                child: Container(
                  color: Color.fromARGB(255, 236, 234, 234),
                ),
              ),
              Padding(
                padding: widget.isReply
                    ? const EdgeInsets.only(
                        right: 16.0,
                        left: 24,
                        top: 8,
                        bottom: 10,
                      )
                    : const EdgeInsets.only(
                        right: 16.0,
                        left: 16,
                        top: 16,
                        bottom: 10,
                      ),
                child: Row(
                  children: [
                    InkWell(
                      child: Stack(
                        children: [
                          _userProfile?.photoUrl != null
                              ? CircleAvatar(
                                  backgroundColor:
                                      Color.fromARGB(255, 227, 227, 227),
                                  backgroundImage:
                                      NetworkImage('${_userProfile?.photoUrl}'),
                                  radius: widget.isReply ? 16 : 20,
                                )
                              : CircleAvatar(
                                  backgroundColor:
                                      Color.fromARGB(255, 227, 227, 227),
                                  backgroundImage:
                                      AssetImage('assets/avatarFT.jpg'),
                                  radius: widget.isReply ? 16 : 20,
                                ),
                          Positioned(
                            bottom: 0,
                            right: widget.isReply ? 2 : 2.8,
                            child: Container(
                              child: Row(
                                children: [
                                  _userProfile?.profileFlag == "true"
                                      ? Container(
                                          width: widget.isReply ? 13.5 : 15.5,
                                          height: widget.isReply ? 6.75 : 7.7,
                                          child: Image.asset(
                                              'icons/flags/png/${user?.country}.png',
                                              package: 'country_icons'))
                                      : Row()
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              child: Row(
                                children: [
                                  _userProfile?.profileBadge == "true"
                                      ? CircleAvatar(
                                          radius: widget.isReply ? 5 : 6,
                                          backgroundColor: Color.fromARGB(
                                              255, 245, 245, 245),
                                          child: Container(
                                            child: Icon(Icons.verified,
                                                color: Color.fromARGB(
                                                    255, 113, 191, 255),
                                                size: widget.isReply ? 10 : 12),
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      widget.snap['name'],
                                      maxLines: 1,
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  // color: Colors.brown,
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: widget.snap['uid'] == user?.uid
                                        ? () => _deletePost(context)
                                        : () => _otherUsers(context),
                                    child:
                                        const Icon(Icons.more_vert, size: 18),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 0),
                                  child: Text(
                                    DateFormat.yMMMd().format(
                                        widget.snap['datePublished'].toDate()),
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                ),
                                Visibility(
                                  visible: widget.minus ?? false,
                                  child: Row(
                                    children: [
                                      SizedBox(width: 8),
                                      const Text(
                                        '•',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 3.5),
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 245, 245, 245),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Voted: ',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                color: Color.fromARGB(
                                                    255, 111, 111, 111),
                                              ),
                                            ),
                                            Icon(
                                              Icons.do_not_disturb_on,
                                              color: Colors.red,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: widget.plus ?? false,
                                  child: Row(
                                    children: [
                                      SizedBox(width: 8),
                                      const Text(
                                        '•',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 3.5),
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 245, 245, 245),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Voted: ',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                color: Color.fromARGB(
                                                    255, 111, 111, 111),
                                              ),
                                            ),
                                            Icon(
                                              Icons.add_circle,
                                              color: Colors.green,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: widget.neutral ?? false,
                                  child: Row(
                                    children: [
                                      SizedBox(width: 8),
                                      const Text(
                                        '•',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 3.5),
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 245, 245, 245),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Voted: ',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                color: Color.fromARGB(
                                                    255, 111, 111, 111),
                                              ),
                                            ),
                                            RotatedBox(
                                              quarterTurns: 1,
                                              child: Icon(
                                                Icons.pause_circle_filled,
                                                color: Color.fromARGB(
                                                    255, 111, 111, 111),
                                                size: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //FIX BETWEEN REPLIES AND COMMENTS
              // widget.isReply
              //     ? Row(
              //         mainAxisAlignment: MainAxisAlignment.start,
              //         children: [
              //           Container(
              //             // alignment: Alignment.centerLeft,
              //             padding: const EdgeInsets.only(left: 62, right: 16),
              //             child: buildText('${widget.snap['text']}'),
              //           ),
              //         ],
              //       )
              //     : Row(
              //         mainAxisAlignment: MainAxisAlignment.start,
              //         children: [
              //           Container(
              //             // alignment: Alignment.centerLeft,
              //             padding: const EdgeInsets.only(left: 70, right: 16),
              //             child: buildText('${widget.snap['text']}'),
              //           ),
              //         ],
              //       ),
              Container(
                // alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 68, right: 16),
                child: buildText('${widget.snap['text']}'),
              ),
              Container(height: 4),
              // '${widget.snap['text']}'.length > 100
              //     ?
              // Padding(
              //   padding: const EdgeInsets.only(left: 68, right: 8),
              //   child: InkWell(
              //     onTap: () {
              //       setState(() {
              //         isReadmore = !isReadmore;
              //       });
              //     },
              //     child: Text(isReadmore ? 'Show Less' : 'Show More',
              //         style: TextStyle(color: Colors.blueAccent)),
              //   ),
              // ),
              // : Container(),
              Container(height: 12),
              Padding(
                padding: widget.isReply
                    ? const EdgeInsets.only(bottom: 8.0, right: 16, left: 62)
                    : const EdgeInsets.only(bottom: 8.0, right: 16, left: 70),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          LikeAnimation(
                            isAnimating:
                                widget.snap['likes']?.contains(user?.uid) ??
                                    false,
                            child: InkWell(
                              onTap: () async {
                                performLoggedUserAction(
                                    context: context,
                                    action: () async {
                                      widget.isReply
                                          ? await FirestoreMethods().likeReply(
                                              widget.postId,
                                              widget.parentCommentId!,
                                              user?.uid ?? '',
                                              widget.snap['likes'],
                                              widget.snap['dislikes'],
                                              widget.snap['replyId'],
                                              postUID)
                                          : await FirestoreMethods()
                                              .likeComment(
                                              widget.postId,
                                              widget.snap['commentId'],
                                              user?.uid ?? '',
                                              widget.snap['likes'],
                                              widget.snap['dislikes'],
                                              postUID,
                                            );
                                      setState(() {});
                                    });
                              },
                              child: Row(
                                children: [
                                  Container(
                                    child: Icon(
                                      Icons.thumb_up,
                                      color: widget.snap['likes']
                                                  ?.contains(user?.uid) ??
                                              false
                                          ? Colors.blueAccent
                                          : Color.fromARGB(255, 206, 204, 204),
                                      size: 16.0,
                                    ),
                                  ),
                                  Container(width: 6),
                                  Text('$_likes',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                      )),
                                ],
                              ),
                            ),
                          ),
                          Container(width: 30),
                          LikeAnimation(
                            isAnimating:
                                widget.snap['dislikes']?.contains(user?.uid) ??
                                    false,
                            child: InkWell(
                              onTap: () async {
                                performLoggedUserAction(
                                    context: context,
                                    action: () async {
                                      widget.isReply
                                          ? await FirestoreMethods()
                                              .dislikeReply(
                                                  widget.postId,
                                                  widget.parentCommentId!,
                                                  user?.uid ?? '',
                                                  widget.snap['likes'],
                                                  widget.snap['dislikes'],
                                                  widget.snap['replyId'],
                                                  postUID)
                                          : await FirestoreMethods()
                                              .dislikeComment(
                                                  widget.postId,
                                                  widget.snap['commentId'],
                                                  user?.uid ?? '',
                                                  widget.snap['likes'],
                                                  widget.snap['dislikes'],
                                                  postUID);
                                      setState(() {});
                                    });
                              },
                              child: Row(
                                children: [
                                  Container(
                                      child: Icon(
                                    Icons.thumb_down,
                                    size: 16,
                                    color: widget.snap['dislikes']
                                                ?.contains(user?.uid) ??
                                            false
                                        ? Colors.blueAccent
                                        : Color.fromARGB(255, 206, 204, 204),
                                  )),
                                  Container(width: 6),
                                  Text('$_dislikes',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: !_replyingOnComment,
                      child: InkWell(
                        onTap: () async {
                          performLoggedUserAction(
                              context: context,
                              action: () async {
                                await _startReplying(
                                  to: widget.snap['name'],
                                  commentId: widget.isReply
                                      ? widget.parentReplyId
                                      : widget.snap['commentId'],
                                  replyFocusNode: widget.isReply
                                      ? currentReplyFocusNode
                                      : currentReplyFocusNode,
                                  replyTextController: widget.isReply
                                      ? _replyController
                                      : _replyController,
                                );
                              });
                        },
                        child: Container(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.reply,
                                size: 16,
                                color: Colors.blueAccent,
                              ),
                              Container(width: 3),
                              const Text("REPLY",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: _showCommentReplies,
                child: _replyTextField(),
              ),
              Visibility(
                visible: !widget.isReply,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.postId)
                      .collection('comments')
                      .doc(widget.snap['commentId'])
                      .collection('replies')
                      .orderBy('datePublished', descending: false)
                      .snapshots(),
                  builder: (content, snapshot) {
                    int repliesCount =
                        (snapshot.data as dynamic)?.docs.length ?? 0;
                    return repliesCount > 0
                        ? Padding(
                            padding: const EdgeInsets.only(
                              left: 64.0,
                              bottom: 8,
                            ),
                            child: Container(
                              child: InkWell(
                                onTap: () async {
                                  _showCommentReplies = !_showCommentReplies;
                                  _stopReplying();
                                  setState(() {});
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      _showCommentReplies
                                          ? Icons.arrow_drop_up
                                          : Icons.arrow_drop_down,
                                      size: 18,
                                      color: Colors.blueAccent,
                                    ),
                                    Container(width: 2),
                                    Text("Replies ($repliesCount)",
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 13,
                                          letterSpacing: 0.5,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container();
                  },
                ),
              ),
              Visibility(
                visible: !_showCommentReplies,
                child: _replyTextField(),
              ),
              Visibility(
                visible: _showCommentReplies,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.postId)
                      .collection('comments')
                      .doc(widget.snap['commentId'])
                      .collection('replies')
                      .orderBy('datePublished', descending: false)
                      .snapshots(),
                  builder: (content, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return commentReplies != null
                          ? ReplyList(
                              commentReplies: commentReplies,
                              parentPost: widget.parentPost,
                              parentCommentId: widget.snap['commentId'],
                              postId: widget.postId,
                              postUId: postUID,
                              parentSetState: widget.parentSetState,
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            );
                    }

                    commentReplies = (snapshot.data as dynamic).docs ?? [];

                    return ReplyList(
                      commentReplies: commentReplies,
                      parentPost: widget.parentPost,
                      parentCommentId: widget.snap['commentId'],
                      postId: widget.postId,
                      postUId: postUID,
                      parentSetState: widget.parentSetState,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _replyTextField() {
    return Padding(
      padding: widget.isReply
          ? const EdgeInsets.only(bottom: 2)
          : const EdgeInsets.only(bottom: 8),
      child: Visibility(
        visible: _replyingOnComment,
        child: Padding(
          padding: widget.isReply
              ? const EdgeInsets.only(left: 12, right: 8)
              : const EdgeInsets.only(left: 8.0, right: 8),
          child: Container(
            width: MediaQuery.of(context).size.width * 1,
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 242, 242, 242),
                border: Border.all(
                  width: 0,
                  color: Color.fromARGB(255, 201, 201, 201),
                ),
                borderRadius: BorderRadius.circular(5)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 8.0,
                    left: 8,
                    bottom: 12,
                  ),
                  child: Container(
                    // color: Color.fromARGB(255, 233, 233, 233),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                              left: 4,
                            ),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      Color.fromARGB(255, 227, 227, 227),
                                  backgroundImage: NetworkImage(
                                    user?.photoUrl ?? '',
                                  ),
                                  radius: widget.isReply ? 16 : 20,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: widget.isReply ? 2 : 2.8,
                                  child: Container(
                                    child: Row(
                                      children: [
                                        _userProfile?.profileFlag == "true"
                                            ? Container(
                                                width: widget.isReply
                                                    ? 13.5
                                                    : 15.5,
                                                height:
                                                    widget.isReply ? 6.75 : 7.7,
                                                child: Image.asset(
                                                    'icons/flags/png/${user?.country}.png',
                                                    package: 'country_icons'))
                                            : Row()
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    child: Row(
                                      children: [
                                        _userProfile?.profileBadge == "true"
                                            ? CircleAvatar(
                                                radius: widget.isReply ? 5 : 6,
                                                backgroundColor: Color.fromARGB(
                                                    255, 245, 245, 245),
                                                child: Container(
                                                  child: Icon(Icons.verified,
                                                      color: Color.fromARGB(
                                                          255, 113, 191, 255),
                                                      size: widget.isReply
                                                          ? 10
                                                          : 12),
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
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 8,
                            ),
                            child: Container(
                              child: TextField(
                                style: TextStyle(fontSize: 15),
                                controller: _replyController,
                                maxLines: null,
                                focusNode: currentReplyFocusNode,
                                decoration: const InputDecoration(
                                  hintText: 'Write a reply...',
                                  // border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top: 14),
                                  hintStyle: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey),
                                  labelStyle: TextStyle(
                                      color: Colors.black, fontSize: 11),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () async {
                          await _stopReplying();
                        },
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Text("CANCEL",
                              style: TextStyle(
                                color: Color.fromARGB(255, 121, 121, 121),
                                fontSize: 13,
                                letterSpacing: 0.5,
                              )),
                        ),
                      ),
                      Container(width: 15),
                      InkWell(
                        onTap: () async {
                          performLoggedUserAction(
                              context: context,
                              action: () async {
                                await FirestoreMethods().postReply(
                                    widget.postId,
                                    // widget.snap['commentId'] ?? '',
                                    widget.isReply
                                        ? widget.parentCommentId
                                        : widget.snap['commentId'],
                                    /*_replyController.text.contains("@") ? _replyController.text.split("@" + widget.snap['name'])[1].toString() :*/ _replyController
                                        .text,
                                    user?.uid ?? '',
                                    user?.username ?? '',
                                    user?.photoUrl ?? '',
                                    widget.isReply
                                        ? widget.snap['uid']
                                        : postUID,
                                    widget.isReply);
                                setState(() {
                                  _replyController.text = "";
                                });
                              });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.send,
                                  color: Colors.blueAccent, size: 12),
                              Container(width: 3),
                              Text(
                                'SEND',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
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
    );
  }

  Widget buildText(String text) {
    TextStyle yourStyle = const TextStyle(fontSize: 15);
    const maxLinesAfterEllipses = 10;
    final lines = isReadmore ? null : maxLinesAfterEllipses;
    Text t = Text(
      text,
      style: yourStyle,
      maxLines: lines,
      overflow: isReadmore ? TextOverflow.visible : TextOverflow.ellipsis,
    );

    return Column(
      children: [
        Container(alignment: Alignment.centerLeft, child: t),
        LayoutBuilder(builder: (context, constraints) {
          final span = TextSpan(text: text, style: yourStyle);
          final tp = TextPainter(
            text: span,
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.left,
          );
          tp.layout(maxWidth: constraints.maxWidth);
          final numLines = tp.computeLineMetrics().length;

          if (numLines > maxLinesAfterEllipses) {
            return InkWell(
              onTap: () {
                setState(() {
                  isReadmore = !isReadmore;
                });
              },
              child: Text(
                isReadmore ? 'Show Less' : 'Show More',
                style: const TextStyle(color: Colors.blueAccent),
              ),
            );
          } else {
            return Container();
          }
        }),
      ],
    );
  }

  // Widget buildText(String text) {
  //   final lines = isReadmore ? null : 15;
  //   Text t = Text(
  //     text,
  //     style: TextStyle(fontSize: 15),
  //     maxLines: lines,
  //     overflow: isReadmore ? TextOverflow.visible : TextOverflow.ellipsis,
  //   );
  //   return t;
  // }

  Future<void> _stopReplying() async {
    currentReplyCommentId = null;
    currentReplyFocusNode = FocusNode();
    widget.parentSetState();
    await Future.delayed(
      const Duration(milliseconds: 200),
      () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
    );
  }

  Future<void> _startReplying({
    required String to,
    required String commentId,
    required TextEditingController replyTextController,
    required FocusNode replyFocusNode,
  }) async {
    currentReplyCommentId = commentId;
    currentReplyFocusNode = FocusNode();
    widget.parentSetState();
    await Future.delayed(
      const Duration(milliseconds: 200),
      () {
        replyTextController.text = '@$to ';
        FocusScope.of(context).requestFocus(replyFocusNode);
      },
    );
  }
}

class ReplyList extends StatelessWidget {
  final commentReplies;
  final Post? parentPost;
  final String? parentCommentId;

  final postId;
  final postUId;
  final Function parentSetState;

  const ReplyList(
      {Key? key,
      this.commentReplies,
      this.parentPost,
      this.parentCommentId,
      this.postId,
      this.postUId,
      required this.parentSetState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ...List.generate(commentReplies.length, (index) {
            var replySnap = commentReplies[index].data();
            print("test--5" + (postUId ?? ""));
            return CommentCard(
              isReply: true,
              parentCommentId: parentCommentId,
              parentReplyId: replySnap['replyId'],
              snap: replySnap,
              postId: postId,
              postUId: postUId,
              minus: parentPost?.minus.contains(replySnap['uid']),
              neutral: parentPost?.neutral.contains(replySnap['uid']),
              plus: parentPost?.plus.contains(replySnap['uid']),
              parentSetState: parentSetState,
            );
          })
        ],
      ),
    );
  }
}
