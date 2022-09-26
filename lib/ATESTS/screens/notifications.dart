import 'dart:async';
import 'package:aft/ATESTS/methods/firestore_methods.dart';
import 'package:aft/ATESTS/models/notification.dart';
import 'package:aft/ATESTS/models/user.dart';
import 'package:aft/ATESTS/provider/user_provider.dart';
import 'package:aft/ATESTS/screens/user_list.dart';
import 'package:aft/ATESTS/utils/constant_utils.dart';
import 'package:aft/ATESTS/utils/global_variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../methods/auth_methods.dart';
import '../models/poll.dart';
import '../models/post.dart';
import 'full_message.dart';
import 'full_message_poll.dart';
import 'notifications_preferences.dart';
import 'profile_screen.dart';
import 'settings.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  StreamSubscription? loadDataStream;
  StreamController<NotificationModel> updatingStream =
      StreamController.broadcast();
  List<NotificationModel> notificationList = [];
  List<NotificationModel> notificationFinalList = [];
  List<User> _userDetails = [];
  User? user;
  StreamSubscription? loadDataStreamPost;
  StreamSubscription? loadDataStreamPoll;
  List<Post> postsList = [];
  List<Poll> pollList = [];
  StreamController<Post> updatingStreamPost = StreamController.broadcast();
  StreamController<Poll> updatingStreamPoll = StreamController.broadcast();

  @override
  void initState() {
    loadPref();
    super.initState();
    initList();
    initPostList();
    initPollList();
  }

  initList() async {
    if (loadDataStream != null) {
      loadDataStream!.cancel();
      notificationList = [];
    }
    loadDataStream = FirebaseFirestore.instance
        .collection('notification')
        .orderBy("datePublished", descending: true)
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            notificationList.add(NotificationModel.fromMap({
              ...change.doc.data()!,
              'updatingStream': updatingStream
            })); // we are adding to a local list when the element is added in firebase collection
            break; //the Post element we will send on pair with updatingStream, because a Post constructor makes a listener on a stream.
          /* case DocumentChangeType.modified:
            updatingStream.add(NotificationModel.fromMap({...change.doc.data()!})); // we are sending a modified object in the stream.
            break;*/
          case DocumentChangeType.removed:
            notificationList.remove(NotificationModel.fromMap({
              ...change.doc.data()!
            })); // we are removing a Post object from the local list.
            break;
        }
      }
      if (notificationList.length > 0) {
        for (var i = 0; i < notificationList.length; i++) {
          getUserDetails(notificationList[i].uid);
        }
      }
      setState(() {});
      Future.delayed(Duration(seconds: 2), () {
        readNotification(user);
      });
    });
  }

  initPostList() async {
    if (loadDataStreamPost != null) {
      loadDataStreamPost!.cancel();
      postsList = [];
    }
    loadDataStreamPost = (FirebaseFirestore.instance
        .collection('posts')
        .orderBy("datePublished", descending: true)
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            postsList.add(Post.fromMap({
              ...change.doc.data()!,
              'updatingStream': updatingStreamPost
            })); // we are adding to a local list when the element is added in firebase collection
            break; //the Post element we will send on pair with updatingStream, because a Post constructor makes a listener on a stream.
          case DocumentChangeType.modified:
            updatingStreamPost.add(Post.fromMap({
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

  initPollList() async {
    if (loadDataStreamPoll != null) {
      loadDataStreamPoll!.cancel();
      pollList = [];
    }
    loadDataStreamPoll = (FirebaseFirestore.instance
        .collection('polls')
        .orderBy("datePublished", descending: true)
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            pollList.add(Poll.fromMap({
              ...change.doc.data()!,
              'updatingStream': updatingStreamPoll
            })); // we are adding to a local list when the element is added in firebase collection
            break; //the Post element we will send on pair with updatingStream, because a Post constructor makes a listener on a stream.
          case DocumentChangeType.modified:
            updatingStreamPoll.add(Poll.fromMap({
              ...change.doc.data()!
            })); // we are sending a modified object in the stream.
            break;
          case DocumentChangeType.removed:
            pollList.remove(Poll.fromMap({
              ...change.doc.data()!
            })); // we are removing a Post object from the local list.
            break;
        }
      }
      setState(() {});
    }));
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserProvider>(context).getUser;
    if (notificationList.length > 0) {
      notificationFinalList.clear();

      List<NotificationModel> tempList = [];
      List<NotificationModel> tempNotList = [];
      List<NotificationModel> tempReplyList = [];
      List<NotificationModel> tempRepliesList = [];
      List<NotificationModel> tempPollList = [];
      List<NotificationModel> tempPlusList = [];
      List<NotificationModel> tempMinusList = [];
      List<NotificationModel> tempNeturalList = [];
      for (var i = 0; i < notificationList.length; i++) {
        //getUserDetails(notificationList[i].uid);
        if (user?.uid == notificationList[i].uploadUserId) {
          if ((prefs?.getBool(ConstantUtils.messageVotes) ?? true) == true &&
              (notificationList[i].typeStatus == "plusVote" ||
                  notificationList[i].typeStatus == "minusVote" ||
                  notificationList[i].typeStatus == "neturalVote")) {
            if (notificationList[i].plus.length > 0) {
              var notification = NotificationModel(
                  replyUploadId: notificationList[i].replyUploadId,
                  commentUploadId: notificationList[i].commentUploadId,
                  typeStatus: "plusVote",
                  score: notificationList[i].score,
                  uploadId: notificationList[i].uploadId,
                  uploadUserId: notificationList[i].uploadUserId,
                  uid: notificationList[i].uid,
                  notification_id: notificationList[i].notification_id,
                  datePublished: notificationList[i].datePublished,
                  commentReply: notificationList[i].commentReply,
                  type: notificationList[i].type,
                  plus: notificationList[i].plus,
                  neutral: [],
                  minus: [],
                  readStatus: notificationList[i].readStatus,
                  likeCount: notificationList[i].likeCount,
                  disLikeCount: notificationList[i].disLikeCount,
                  comments: notificationList[i].comments,
                  commentId: notificationList[i].commentId);
              notificationFinalList.add(notification);
              notificationFinalList = notificationFinalList.toSet().toList();
            }
          }
          if ((prefs?.getBool(ConstantUtils.messageVotes) ?? true) == true &&
              (notificationList[i].typeStatus == "plusVote" ||
                  notificationList[i].typeStatus == "minusVote" ||
                  notificationList[i].typeStatus == "neturalVote")) {
            if (notificationList[i].minus.length > 0) {
              var notification = NotificationModel(
                  replyUploadId: notificationList[i].replyUploadId,
                  typeStatus: "minusVote",
                  commentUploadId: notificationList[i].commentUploadId,
                  score: notificationList[i].score,
                  uploadId: notificationList[i].uploadId,
                  uploadUserId: notificationList[i].uploadUserId,
                  uid: notificationList[i].uid,
                  notification_id: notificationList[i].notification_id,
                  datePublished: notificationList[i].datePublished,
                  commentReply: notificationList[i].commentReply,
                  type: notificationList[i].type,
                  plus: [],
                  neutral: [],
                  minus: notificationList[i].minus,
                  readStatus: notificationList[i].readStatus,
                  likeCount: notificationList[i].likeCount,
                  disLikeCount: notificationList[i].disLikeCount,
                  comments: notificationList[i].comments,
                  commentId: notificationList[i].commentId);
              notificationFinalList.add(notification);
              notificationFinalList = notificationFinalList.toSet().toList();
            }
          }
          if ((prefs?.getBool(ConstantUtils.messageVotes) ?? true) == true &&
              (notificationList[i].typeStatus == "plusVote" ||
                  notificationList[i].typeStatus == "minusVote" ||
                  notificationList[i].typeStatus == "neturalVote")) {
            if (notificationList[i].neutral.length > 0) {
              var notification = NotificationModel(
                  replyUploadId: notificationList[i].replyUploadId,
                  commentUploadId: notificationList[i].commentUploadId,
                  typeStatus: "neturalVote",
                  score: notificationList[i].score,
                  uploadId: notificationList[i].uploadId,
                  uploadUserId: notificationList[i].uploadUserId,
                  uid: notificationList[i].uid,
                  notification_id: notificationList[i].notification_id,
                  datePublished: notificationList[i].datePublished,
                  commentReply: notificationList[i].commentReply,
                  type: notificationList[i].type,
                  plus: [],
                  neutral: notificationList[i].neutral,
                  minus: [],
                  readStatus: notificationList[i].readStatus,
                  likeCount: notificationList[i].likeCount,
                  disLikeCount: notificationList[i].disLikeCount,
                  comments: notificationList[i].comments,
                  commentId: notificationList[i].commentId);
              notificationFinalList.add(notification);
              notificationFinalList = notificationFinalList.toSet().toList();
            }
          }

          //comment like
          if ((prefs?.getBool(
                          ConstantUtils.commentAndRepliesLikesAndDislikes) ??
                      true) ==
                  true &&
              (notificationList[i].typeStatus == "messageCommentLike" ||
                  notificationList[i].typeStatus == "messageCommentdisike")) {
            if (notificationList[i].likeCount.length > 0) {
              var notification = NotificationModel(
                  replyUploadId: notificationList[i].replyUploadId,
                  commentUploadId: notificationList[i].commentUploadId,
                  typeStatus: "messageCommentLike",
                  score: notificationList[i].score,
                  uploadId: notificationList[i].uploadId,
                  uploadUserId: notificationList[i].uploadUserId,
                  uid: notificationList[i].uid,
                  notification_id: notificationList[i].notification_id,
                  datePublished: notificationList[i].datePublished,
                  commentReply: notificationList[i].commentReply,
                  type: notificationList[i].type,
                  plus: notificationList[i].plus,
                  neutral: notificationList[i].neutral,
                  minus: notificationList[i].minus,
                  readStatus: notificationList[i].readStatus,
                  likeCount: notificationList[i].likeCount,
                  disLikeCount: [],
                  comments: notificationList[i].comments,
                  commentId: notificationList[i].commentId);
              notificationFinalList.add(notification);
              notificationFinalList = notificationFinalList.toSet().toList();
            }
          }
          if ((prefs?.getBool(
                          ConstantUtils.commentAndRepliesLikesAndDislikes) ??
                      true) ==
                  true &&
              (notificationList[i].typeStatus == "messageCommentLike" ||
                  notificationList[i].typeStatus == "messageCommentdisike")) {
            if (notificationList[i].disLikeCount.length > 0) {
              var notification = NotificationModel(
                  replyUploadId: notificationList[i].replyUploadId,
                  commentUploadId: notificationList[i].commentUploadId,
                  typeStatus: "messageCommentdisike",
                  score: notificationList[i].score,
                  uploadId: notificationList[i].uploadId,
                  uploadUserId: notificationList[i].uploadUserId,
                  uid: notificationList[i].uid,
                  notification_id: notificationList[i].notification_id,
                  datePublished: notificationList[i].datePublished,
                  commentReply: notificationList[i].commentReply,
                  type: notificationList[i].type,
                  plus: notificationList[i].plus,
                  neutral: notificationList[i].neutral,
                  minus: notificationList[i].minus,
                  readStatus: notificationList[i].readStatus,
                  likeCount: [],
                  disLikeCount: notificationList[i].disLikeCount,
                  comments: notificationList[i].comments,
                  commentId: notificationList[i].commentId);
              notificationFinalList.add(notification);
              notificationFinalList = notificationFinalList.toSet().toList();
            }
          }

          //reply like
          if ((prefs?.getBool(
                          ConstantUtils.commentAndRepliesLikesAndDislikes) ??
                      true) ==
                  true &&
              (notificationList[i].typeStatus == "messageReplydisike" ||
                  notificationList[i].typeStatus == "messageReplylike")) {
            if (notificationList[i].likeCount.length > 0) {
              var notification = NotificationModel(
                  replyUploadId: notificationList[i].replyUploadId,
                  commentUploadId: notificationList[i].commentUploadId,
                  typeStatus: "messageReplylike",
                  score: notificationList[i].score,
                  uploadId: notificationList[i].uploadId,
                  uploadUserId: notificationList[i].uploadUserId,
                  uid: notificationList[i].uid,
                  notification_id: notificationList[i].notification_id,
                  datePublished: notificationList[i].datePublished,
                  commentReply: notificationList[i].commentReply,
                  type: notificationList[i].type,
                  plus: notificationList[i].plus,
                  neutral: notificationList[i].neutral,
                  minus: notificationList[i].minus,
                  readStatus: notificationList[i].readStatus,
                  likeCount: notificationList[i].likeCount,
                  disLikeCount: [],
                  comments: notificationList[i].comments,
                  commentId: notificationList[i].commentId);
              notificationFinalList.add(notification);
              notificationFinalList = notificationFinalList.toSet().toList();
            }
          }
          if ((prefs?.getBool(
                          ConstantUtils.commentAndRepliesLikesAndDislikes) ??
                      true) ==
                  true &&
              (notificationList[i].typeStatus == "messageReplylike" ||
                  notificationList[i].typeStatus == "messageReplydisike")) {
            if (notificationList[i].disLikeCount.length > 0) {
              var notification = NotificationModel(
                  replyUploadId: notificationList[i].replyUploadId,
                  commentUploadId: notificationList[i].commentUploadId,
                  typeStatus: "messageReplydisike",
                  score: notificationList[i].score,
                  uploadId: notificationList[i].uploadId,
                  uploadUserId: notificationList[i].uploadUserId,
                  uid: notificationList[i].uid,
                  notification_id: notificationList[i].notification_id,
                  datePublished: notificationList[i].datePublished,
                  commentReply: notificationList[i].commentReply,
                  type: notificationList[i].type,
                  plus: notificationList[i].plus,
                  neutral: notificationList[i].neutral,
                  minus: notificationList[i].minus,
                  readStatus: notificationList[i].readStatus,
                  likeCount: [],
                  disLikeCount: notificationList[i].disLikeCount,
                  comments: notificationList[i].comments,
                  commentId: notificationList[i].commentId);
              notificationFinalList.add(notification);
              notificationFinalList = notificationFinalList.toSet().toList();
            }
          }

          //comment Poll like
          if ((prefs?.getBool(
                          ConstantUtils.commentAndRepliesLikesAndDislikes) ??
                      true) ==
                  true &&
              (notificationList[i].typeStatus == "pollCommentLike" ||
                  notificationList[i].typeStatus == "pollCommentdisike")) {
            if (notificationList[i].likeCount.length > 0) {
              var notification = NotificationModel(
                  replyUploadId: notificationList[i].replyUploadId,
                  commentUploadId: notificationList[i].commentUploadId,
                  typeStatus: "pollCommentLike",
                  score: notificationList[i].score,
                  uploadId: notificationList[i].uploadId,
                  uploadUserId: notificationList[i].uploadUserId,
                  uid: notificationList[i].uid,
                  notification_id: notificationList[i].notification_id,
                  datePublished: notificationList[i].datePublished,
                  commentReply: notificationList[i].commentReply,
                  type: notificationList[i].type,
                  plus: notificationList[i].plus,
                  neutral: notificationList[i].neutral,
                  minus: notificationList[i].minus,
                  readStatus: notificationList[i].readStatus,
                  likeCount: notificationList[i].likeCount,
                  disLikeCount: [],
                  comments: notificationList[i].comments,
                  commentId: notificationList[i].commentId);
              notificationFinalList.add(notification);
              notificationFinalList = notificationFinalList.toSet().toList();
            }
          }
          if ((prefs?.getBool(
                          ConstantUtils.commentAndRepliesLikesAndDislikes) ??
                      true) ==
                  true &&
              (notificationList[i].typeStatus == "pollCommentLike" ||
                  notificationList[i].typeStatus == "pollCommentdisike")) {
            if (notificationList[i].disLikeCount.length > 0) {
              var notification = NotificationModel(
                  replyUploadId: notificationList[i].replyUploadId,
                  commentUploadId: notificationList[i].commentUploadId,
                  typeStatus: "pollCommentdisike",
                  score: notificationList[i].score,
                  uploadId: notificationList[i].uploadId,
                  uploadUserId: notificationList[i].uploadUserId,
                  uid: notificationList[i].uid,
                  notification_id: notificationList[i].notification_id,
                  datePublished: notificationList[i].datePublished,
                  commentReply: notificationList[i].commentReply,
                  type: notificationList[i].type,
                  plus: notificationList[i].plus,
                  neutral: notificationList[i].neutral,
                  minus: notificationList[i].minus,
                  readStatus: notificationList[i].readStatus,
                  likeCount: [],
                  disLikeCount: notificationList[i].disLikeCount,
                  comments: notificationList[i].comments,
                  commentId: notificationList[i].commentId);
              notificationFinalList.add(notification);
              notificationFinalList = notificationFinalList.toSet().toList();
            }
          }
          //reply Poll like
          if ((prefs?.getBool(
                          ConstantUtils.commentAndRepliesLikesAndDislikes) ??
                      true) ==
                  true &&
              (notificationList[i].typeStatus == "pollReplydisike" ||
                  notificationList[i].typeStatus == "pollReplylike")) {
            if (notificationList[i].likeCount.length > 0) {
              var notification = NotificationModel(
                  replyUploadId: notificationList[i].replyUploadId,
                  commentUploadId: notificationList[i].commentUploadId,
                  typeStatus: "pollReplylike",
                  score: notificationList[i].score,
                  uploadId: notificationList[i].uploadId,
                  uploadUserId: notificationList[i].uploadUserId,
                  uid: notificationList[i].uid,
                  notification_id: notificationList[i].notification_id,
                  datePublished: notificationList[i].datePublished,
                  commentReply: notificationList[i].commentReply,
                  type: notificationList[i].type,
                  plus: notificationList[i].plus,
                  neutral: notificationList[i].neutral,
                  minus: notificationList[i].minus,
                  readStatus: notificationList[i].readStatus,
                  likeCount: notificationList[i].likeCount,
                  disLikeCount: [],
                  comments: notificationList[i].comments,
                  commentId: notificationList[i].commentId);
              notificationFinalList.add(notification);
              notificationFinalList = notificationFinalList.toSet().toList();
            }
          }
          if ((prefs?.getBool(
                          ConstantUtils.commentAndRepliesLikesAndDislikes) ??
                      true) ==
                  true &&
              (notificationList[i].typeStatus == "pollReplylike" ||
                  notificationList[i].typeStatus == "pollReplydisike")) {
            if (notificationList[i].disLikeCount.length > 0) {
              var notification = NotificationModel(
                  replyUploadId: notificationList[i].replyUploadId,
                  commentUploadId: notificationList[i].commentUploadId,
                  typeStatus: "pollReplydisike",
                  score: notificationList[i].score,
                  uploadId: notificationList[i].uploadId,
                  uploadUserId: notificationList[i].uploadUserId,
                  uid: notificationList[i].uid,
                  notification_id: notificationList[i].notification_id,
                  datePublished: notificationList[i].datePublished,
                  commentReply: notificationList[i].commentReply,
                  type: notificationList[i].type,
                  plus: notificationList[i].plus,
                  neutral: notificationList[i].neutral,
                  minus: notificationList[i].minus,
                  readStatus: notificationList[i].readStatus,
                  likeCount: [],
                  disLikeCount: notificationList[i].disLikeCount,
                  comments: notificationList[i].comments,
                  commentId: notificationList[i].commentId);
              notificationFinalList.add(notification);
              notificationFinalList = notificationFinalList.toSet().toList();
            }
          }

          //comment replies
          if ((prefs?.getBool(ConstantUtils.messagePollComments) ?? true) ==
                  true &&
              notificationList[i].typeStatus == "commentReplies") {
            tempReplyList.add(notificationList[i]);
          }
          //message comemnt
          if ((prefs?.getBool(ConstantUtils.messagePollComments) ?? true) ==
                  true &&
              notificationList[i].typeStatus == "messageComments") {
            tempNotList.add(notificationList[i]);
          }
          if ((prefs?.getBool(ConstantUtils.messagePollComments) ?? true) ==
                  true &&
              notificationList[i].typeStatus == "pollComments") {
            tempPollList.add(notificationList[i]);
          }
          /*if ((prefs?.getBool(ConstantUtils.messageVotes) ?? true) == true && notificationList[i].typeStatus == "plusVote") {
            tempPlusList.add(notificationList[i]);
          }*/
          /* if ((prefs?.getBool(ConstantUtils.messageVotes) ?? true) == true && notificationList[i].typeStatus == "minusVote") {
            tempMinusList.add(notificationList[i]);
          }
          if ((prefs?.getBool(ConstantUtils.messageVotes) ?? true) == true && notificationList[i].typeStatus == "neturalVote") {
            tempNeturalList.add(notificationList[i]);
          }*/
        }
      }

      for (var i = 0; i < tempReplyList.length; i++) {
        List<dynamic> comments = [tempReplyList[i].commentReply];
        List<dynamic> commentId = [tempReplyList[i].uid];
        var notification = NotificationModel(
            replyUploadId: notificationList[i].replyUploadId,
            commentUploadId: notificationList[i].commentUploadId,
            typeStatus: tempReplyList[i].typeStatus,
            score: tempReplyList[i].score,
            uploadId: tempReplyList[i].uploadId,
            uploadUserId: tempReplyList[i].uploadUserId,
            uid: tempReplyList[i].uid,
            notification_id: tempReplyList[i].notification_id,
            datePublished: tempReplyList[i].datePublished,
            commentReply: tempReplyList[i].commentReply,
            type: tempReplyList[i].type,
            plus: tempReplyList[i].plus,
            neutral: tempReplyList[i].neutral,
            minus: tempReplyList[i].minus,
            readStatus: tempReplyList[i].readStatus,
            likeCount: tempReplyList[i].likeCount,
            disLikeCount: tempReplyList[i].disLikeCount,
            comments: comments,
            commentId: commentId);
        tempRepliesList.add(notification);
        notificationFinalList.addAll(tempRepliesList);
        notificationFinalList = notificationFinalList.toSet().toList();
      }

      for (var i = 0; i < tempNotList.length; i++) {
        if (tempList.isEmpty) {
          List<dynamic> comments = [tempNotList[i].commentReply];
          List<dynamic> commentId = [tempNotList[i].uid];
          var notification = NotificationModel(
              replyUploadId: notificationList[i].replyUploadId,
              commentUploadId: notificationList[i].commentUploadId,
              typeStatus: tempNotList[i].typeStatus,
              score: tempNotList[i].score,
              uploadId: tempNotList[i].uploadId,
              uploadUserId: tempNotList[i].uploadUserId,
              uid: tempNotList[i].uid,
              notification_id: tempNotList[i].notification_id,
              datePublished: tempNotList[i].datePublished,
              commentReply: tempNotList[i].commentReply,
              type: tempNotList[i].type,
              plus: tempNotList[i].plus,
              neutral: tempNotList[i].neutral,
              minus: tempNotList[i].minus,
              readStatus: tempNotList[i].readStatus,
              likeCount: tempNotList[i].likeCount,
              disLikeCount: tempNotList[i].disLikeCount,
              comments: comments,
              commentId: commentId);
          tempList.add(notification);
          notificationFinalList.addAll(tempList);
        } else {
          if (tempNotList.length > i) {
            if (tempNotList[i - 1].uploadUserId ==
                    tempNotList[i].uploadUserId &&
                tempNotList[i - 1].uploadId == tempNotList[i].uploadId) {
              String comments = tempNotList[i].commentReply;
              String commentId = tempNotList[i].uid;

              tempList[tempList.length - 1].comments?.add(comments);
              tempList[tempList.length - 1].commentId?.add(commentId);
              notificationFinalList[notificationFinalList.length - 1]
                  .commentId
                  ?.add(comments);
              notificationFinalList[notificationFinalList.length - 1]
                  .commentId
                  ?.add(commentId);
              notificationFinalList[notificationFinalList.length - 1]
                      .commentId =
                  notificationFinalList[notificationFinalList.length - 1]
                      .commentId
                      ?.toSet()
                      .toList();
            } else {
              List<dynamic> comments = [tempNotList[i].commentReply];
              List<dynamic> commentId = [tempNotList[i].uid];
              var notification = NotificationModel(
                  replyUploadId: notificationList[i].replyUploadId,
                  commentUploadId: notificationList[i].commentUploadId,
                  typeStatus: tempNotList[i].typeStatus,
                  score: tempNotList[i].score,
                  uploadId: tempNotList[i].uploadId,
                  uploadUserId: tempNotList[i].uploadUserId,
                  uid: tempNotList[i].uid,
                  notification_id: tempNotList[i].notification_id,
                  datePublished: tempNotList[i].datePublished,
                  commentReply: tempNotList[i].commentReply,
                  type: tempNotList[i].type,
                  plus: tempNotList[i].plus,
                  neutral: tempNotList[i].neutral,
                  minus: tempNotList[i].minus,
                  readStatus: tempNotList[i].readStatus,
                  likeCount: tempNotList[i].likeCount,
                  disLikeCount: tempNotList[i].disLikeCount,
                  comments: comments,
                  commentId: commentId);

              tempList.add(notification);
              notificationFinalList.addAll(tempList);
            }
          } else {
            List<dynamic> comments = [tempNotList[i].commentReply];
            List<dynamic> commentId = [tempNotList[i].uid];
            var notification = NotificationModel(
                replyUploadId: notificationList[i].replyUploadId,
                commentUploadId: notificationList[i].commentUploadId,
                typeStatus: tempNotList[i].typeStatus,
                score: tempNotList[i].score,
                uploadId: tempNotList[i].uploadId,
                uploadUserId: tempNotList[i].uploadUserId,
                uid: tempNotList[i].uid,
                notification_id: tempNotList[i].notification_id,
                datePublished: tempNotList[i].datePublished,
                commentReply: tempNotList[i].commentReply,
                type: tempNotList[i].type,
                plus: tempNotList[i].plus,
                neutral: tempNotList[i].neutral,
                minus: tempNotList[i].minus,
                readStatus: tempNotList[i].readStatus,
                likeCount: tempNotList[i].likeCount,
                disLikeCount: tempNotList[i].disLikeCount,
                comments: comments,
                commentId: commentId);

            tempList.add(notification);
            notificationFinalList.addAll(tempList);
          }
        }
      }

      for (var i = 0; i < tempPollList.length; i++) {
        if (i == 0) {
          List<dynamic> comments = [tempPollList[i].commentReply];
          List<dynamic> commentId = [tempPollList[i].uid];
          var notification = NotificationModel(
              replyUploadId: notificationList[i].replyUploadId,
              commentUploadId: notificationList[i].commentUploadId,
              typeStatus: tempPollList[i].typeStatus,
              score: tempPollList[i].score,
              uploadId: tempPollList[i].uploadId,
              uploadUserId: tempPollList[i].uploadUserId,
              uid: tempPollList[i].uid,
              notification_id: tempPollList[i].notification_id,
              datePublished: tempPollList[i].datePublished,
              commentReply: tempPollList[i].commentReply,
              type: tempPollList[i].type,
              plus: tempPollList[i].plus,
              neutral: tempPollList[i].neutral,
              minus: tempPollList[i].minus,
              readStatus: tempPollList[i].readStatus,
              likeCount: tempPollList[i].likeCount,
              disLikeCount: tempPollList[i].disLikeCount,
              comments: comments,
              commentId: commentId);
          notificationFinalList.add(notification);
        } else {
          if (tempPollList.length > i && i > 0) {
            if (tempPollList[i - 1].uploadUserId ==
                    tempPollList[i].uploadUserId &&
                tempPollList[i - 1].uploadId == tempPollList[i].uploadId) {
              String comments = tempPollList[i].commentReply;
              String commentId = tempPollList[i].uid;

              notificationFinalList[notificationFinalList.length - 1]
                  .comments
                  ?.add(comments);
              notificationFinalList[notificationFinalList.length - 1]
                  .commentId
                  ?.add(commentId);
              notificationFinalList[notificationFinalList.length - 1]
                      .commentId =
                  notificationFinalList[notificationFinalList.length - 1]
                      .commentId
                      ?.toSet()
                      .toList();
            } else {
              List<dynamic> comments = [tempPollList[i].commentReply];
              List<dynamic> commentId = [tempPollList[i].uid];
              var notification = NotificationModel(
                  replyUploadId: notificationList[i].replyUploadId,
                  commentUploadId: notificationList[i].commentUploadId,
                  typeStatus: tempPollList[i].typeStatus,
                  score: tempPollList[i].score,
                  uploadId: tempPollList[i].uploadId,
                  uploadUserId: tempPollList[i].uploadUserId,
                  uid: tempPollList[i].uid,
                  notification_id: tempPollList[i].notification_id,
                  datePublished: tempPollList[i].datePublished,
                  commentReply: tempPollList[i].commentReply,
                  type: tempPollList[i].type,
                  plus: tempPollList[i].plus,
                  neutral: tempPollList[i].neutral,
                  minus: tempPollList[i].minus,
                  readStatus: tempPollList[i].readStatus,
                  likeCount: tempPollList[i].likeCount,
                  disLikeCount: tempPollList[i].disLikeCount,
                  comments: comments,
                  commentId: commentId);

              tempList.add(notification);
              notificationFinalList.addAll(tempList);
            }
          } else {
            List<dynamic> comments = [tempPollList[i].commentReply];
            List<dynamic> commentId = [tempPollList[i].uid];
            var notification = NotificationModel(
                replyUploadId: notificationList[i].replyUploadId,
                commentUploadId: notificationList[i].commentUploadId,
                typeStatus: tempPollList[i].typeStatus,
                score: tempPollList[i].score,
                uploadId: tempPollList[i].uploadId,
                uploadUserId: tempPollList[i].uploadUserId,
                uid: tempPollList[i].uid,
                notification_id: tempPollList[i].notification_id,
                datePublished: tempPollList[i].datePublished,
                commentReply: tempPollList[i].commentReply,
                type: tempPollList[i].type,
                plus: tempPollList[i].plus,
                neutral: tempPollList[i].neutral,
                minus: tempPollList[i].minus,
                readStatus: tempPollList[i].readStatus,
                likeCount: tempPollList[i].likeCount,
                disLikeCount: tempPollList[i].disLikeCount,
                comments: comments,
                commentId: commentId);
            notificationFinalList.add(notification);
          }
        }
      }

      /*   List<NotificationModel> tempPlusFinal = [];
      for (var i = 0; i < tempPlusList.length; i++) {
        if (i == 0) {
          tempPlusFinal.add(tempPlusList[i]);
        } else if (tempPlusList[i - 1].uploadId == tempPlusList[i].uploadId && tempPlusList[i - 1].uploadUserId == tempPlusList[i].uploadUserId) {
          if (tempPlusList[i - 1].plus.length > tempPlusList[i].plus.length) {
            if (i != 0 && i < tempPlusList[i].plus.length) {
              for (int j = 0; j < tempPlusList[i].plus.length; j++) {
                tempPlusFinal[i - 1].plus.add(tempPlusList[i].plus[j]);
              }
              tempPlusFinal[i - 1].plus = tempPlusFinal[i - 1].plus.toSet().toList();
            }
          } else if (tempPlusList[i].plus.length > 0 && tempPlusList[i - 1].plus[0] != tempPlusList[i].plus[0]) {
            tempPlusFinal[i - 1].plus.add(tempPlusList[i].plus[0]);
            tempPlusFinal[i - 1].plus = tempPlusFinal[i - 1].plus.toSet().toList();
          }
        } else if (tempPlusList[i - 1].uploadId != tempPlusList[i].uploadId && tempPlusList[i - 1].uploadUserId == tempPlusList[i].uploadUserId) {
          tempPlusFinal.add(tempPlusList[i]);
          tempPlusFinal = tempPlusFinal.toSet().toList();
        }
      }
      notificationFinalList.addAll(tempPlusFinal);
      List<NotificationModel> tempMinusFinal = [];
      for (var i = 0; i < tempMinusList.length; i++) {
        if (i == 0) {
          tempMinusFinal.add(tempMinusList[i]);
        } else if (tempMinusList[i - 1].uploadId == tempMinusList[i].uploadId && tempMinusList[i - 1].uploadUserId == tempMinusList[i].uploadUserId) {
          if (tempMinusList[i - 1].minus.length > tempMinusList[i].minus.length) {
            if (i != 0 && i < tempMinusList[i].minus.length) {
              for (int j = 0; j < tempMinusList[i].minus.length; j++) {
                tempMinusFinal[i - 1].minus.add(tempMinusList[i].minus[j]);
              }
              tempMinusFinal[i - 1].minus = tempMinusFinal[i - 1].minus.toSet().toList();
            }
          } else if (tempMinusList[i].minus.length > 0 && tempMinusList[i - 1].minus[0] != tempMinusList[i].minus[0]) {
            tempMinusFinal[i - 1].minus.add(tempMinusList[i].minus[0]);
            tempMinusFinal[i - 1].minus = tempMinusFinal[i - 1].minus.toSet().toList();
          }
        } else if (tempMinusList[i - 1].uploadId != tempMinusList[i].uploadId && tempMinusList[i - 1].uploadUserId == tempMinusList[i].uploadUserId) {
          tempMinusFinal.add(tempMinusList[i]);
          tempMinusFinal = tempMinusFinal.toSet().toList();
        }
      }
      notificationFinalList.addAll(tempMinusFinal);
      List<NotificationModel> tempNeturalFinal = [];
      for (var i = 0; i < tempNeturalList.length; i++) {
        if (i == 0) {
          tempNeturalFinal.add(tempNeturalList[i]);
        } else if (tempNeturalList[i - 1].uploadId == tempNeturalList[i].uploadId && tempNeturalList[i - 1].uploadUserId == tempNeturalList[i].uploadUserId) {
          if (tempNeturalList[i - 1].neutral.length > tempNeturalList[i].neutral.length) {
            if (i != 0 && i < tempNeturalList[i].neutral.length) {
              for (int j = 0; j < tempNeturalList[i].neutral.length; j++) {
                tempNeturalFinal[i - 1].neutral.add(tempNeturalList[i].neutral[j]);
              }
              tempNeturalFinal[i - 1].neutral = tempNeturalFinal[i - 1].neutral.toSet().toList();
            }
          } else if (tempNeturalList[i - 1].neutral.length > 0 && tempNeturalList[i].neutral.length > 0 && tempNeturalList[i - 1].neutral[0] != tempNeturalList[i].neutral[0]) {
            tempNeturalFinal[i - 1].neutral.add(tempNeturalList[i].neutral[0]);
            tempNeturalFinal[i - 1].neutral = tempNeturalFinal[i - 1].neutral.toSet().toList();
          }
        } else if (tempNeturalList[i - 1].uploadId != tempNeturalList[i].uploadId && tempNeturalList[i - 1].uploadUserId == tempNeturalList[i].uploadUserId) {
          tempNeturalFinal.add(tempNeturalList[i]);
          tempNeturalFinal = tempNeturalFinal.toSet().toList();
        }
      }
      notificationFinalList.addAll(tempNeturalFinal);*/

      for (var i = 0; i < notificationList.length; i++) {
        if (user?.uid == notificationList[i].uploadUserId &&
            (((prefs?.getBool(ConstantUtils.pollVotes) ?? true) == true &&
                    notificationList[i].typeStatus == "pollVote") ||
                ((prefs?.getBool(ConstantUtils.mentions) ?? true) == true &&
                    notificationList[i].typeStatus == "mention")
            /*|| ((prefs?.getBool(ConstantUtils.commentAndRepliesLikesAndDislikes) ?? true) == true &&
                    (notificationList[i].typeStatus == "messageCommentLike" || notificationList[i].typeStatus == "messageReplydisike" || notificationList[i].typeStatus == "messageReplylike" || notificationList[i].typeStatus == "messageCommentdisike"))*/ /*|| ((prefs?.getBool(ConstantUtils.commentReplies) ?? true) == true && notificationList[i].typeStatus == "commentReplies")*/)) {
          notificationFinalList.add(notificationList[i]);
        }
      }

      notificationFinalList.sort((a, b) {
        return b.datePublished.compareTo(a.datePublished);
      });
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 40,
                    child: Material(
                      shape: const CircleBorder(),
                      color: Colors.white,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        splashColor: Colors.grey.withOpacity(0.5),
                        onTap: () {
                          Future.delayed(const Duration(milliseconds: 50), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsPreferences()),
                            );
                          });
                        },
                        child: const Icon(Icons.notifications_active,
                            color: Color.fromARGB(255, 80, 80, 80)),
                      ),
                    ),
                  ),
                  Text(
                    'Notifications',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18),
                  ),
                  Container(
                    height: 40,
                    child: Material(
                      shape: const CircleBorder(),
                      color: Colors.white,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        splashColor: Colors.grey.withOpacity(0.5),
                        onTap: () {
                          Future.delayed(const Duration(milliseconds: 50), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsScreen()),
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
          ],
        ),
        body: notificationFinalList.isNotEmpty
            ? ListView.builder(
                itemCount: notificationFinalList.length,
                itemBuilder: (context, index) {
                  List<User> _userData = [];
                  for (var i = 0; i < _userDetails.length; i++) {
                    if (_userDetails[i].uid ==
                        notificationFinalList[index].uid) {
                      _userData.add(_userDetails[i]);
                      break;
                    }
                  }

                  if (notificationFinalList[index].typeStatus == "plusVote" &&
                      notificationFinalList[index].plus.length > 0) {
                    return commonClick(
                        notificationFinalList[index].readStatus,
                        "${ConstantUtils.aMessages} ${ConstantUtils.youHaveCreatedRecieved} "
                            " ",
                        "${notificationFinalList[index].plus.length}",
                        " plus votes", () {
                      List<Post> postTempList = [];
                      for (var i = 0; i < postsList.length; i++) {
                        if (postsList[i].postId ==
                            notificationFinalList[index].uploadId) {
                          postTempList.add(postsList[i]);
                        }
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullMessage(
                                  post: postTempList[0],
                                  postId: notificationFinalList[index].uploadId,
                                  indexPlacement: index,
                                )),
                      );
                    }, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UserList(notificationFinalList[index].plus)),
                      );
                    });
                  } else if (notificationFinalList[index].typeStatus ==
                          "minusVote" &&
                      notificationFinalList[index].minus.length > 0) {
                    return commonClick(
                        notificationFinalList[index].readStatus,
                        "${ConstantUtils.aMessages}  ${ConstantUtils.youHaveCreatedRecieved} "
                            " ",
                        "${notificationFinalList[index].minus.length}",
                        " minus votes", () {
                      List<Post> postTempList = [];
                      for (var i = 0; i < postsList.length; i++) {
                        if (postsList[i].postId ==
                            notificationFinalList[index].uploadId) {
                          postTempList.add(postsList[i]);
                        }
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullMessage(
                                  post: postTempList[0],
                                  postId: notificationFinalList[index].uploadId,
                                  indexPlacement: index,
                                )),
                      );
                    }, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UserList(notificationFinalList[index].minus)),
                      );
                    });
                  } else if (notificationFinalList[index].typeStatus ==
                          "neturalVote" &&
                      notificationFinalList[index].neutral.length > 0) {
                    return commonClick(
                        notificationFinalList[index].readStatus,
                        "${ConstantUtils.aMessages}  ${ConstantUtils.youHaveCreatedRecieved} "
                            " ",
                        "${notificationFinalList[index].neutral.length}",
                        " neutral votes", () {
                      List<Post> postTempList = [];
                      for (var i = 0; i < postsList.length; i++) {
                        if (postsList[i].postId ==
                            notificationFinalList[index].uploadId) {
                          postTempList.add(postsList[i]);
                        }
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullMessage(
                                  post: postTempList[0],
                                  postId: notificationFinalList[index].uploadId,
                                  indexPlacement: index,
                                )),
                      );
                    }, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UserList(notificationFinalList[index].neutral)),
                      );
                    });
                  } else if (notificationFinalList[index].typeStatus ==
                      "mention") {
                    var name =
                        _userData.length > 0 ? _userData[0].username : "";
                    return commonClick(notificationFinalList[index].readStatus,
                        "", " ${name} ${ConstantUtils.mentionedYou}", "", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Profile(
                                null, _userDetails[index],
                                key: GlobalKey())),
                      );
                    }, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Profile(
                                null, _userDetails[index],
                                key: GlobalKey())),
                      );
                    });
                  } else if (notificationFinalList[index].typeStatus ==
                      "commentReplies") {
                    List<Post> postTempList = [];
                    List<Poll> pollTempList = [];
                    if (notificationFinalList[index].type == "post") {
                      for (var i = 0; i < postsList.length; i++) {
                        if (postsList[i].postId ==
                            notificationFinalList[index].uploadId) {
                          postTempList.add(postsList[i]);
                        }
                      }
                    } else {
                      for (var i = 0; i < pollList.length; i++) {
                        if (pollList[i].pollId ==
                            notificationFinalList[index].uploadId) {
                          pollTempList.add(pollList[i]);
                        }
                      }
                    }
                    return commonClick(
                        notificationFinalList[index].readStatus,
                        "${ConstantUtils.aCommentYouHaveCreatedRecieved} ",
                        "1",
                        " reply", () {
                      if (notificationFinalList[index].type == "post") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FullMessage(
                                    post: postTempList[0],
                                    postId:
                                        notificationFinalList[index].uploadId,
                                    indexPlacement: index,
                                  )),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FullMessagePoll(
                                  poll: pollTempList[0],
                                  pollId: notificationFinalList[index].uploadId,
                                  indexPlacement: index)),
                        );
                      }
                    }, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserList(
                                notificationFinalList[index].commentId!)),
                      );
                    });
                  } else if (notificationFinalList[index].typeStatus ==
                      "pollComments") {
                    List<Poll> pollTempList = [];
                    for (var i = 0; i < pollList.length; i++) {
                      if (pollList[i].pollId ==
                          notificationFinalList[index].uploadId) {
                        pollTempList.add(pollList[i]);
                      }
                    }
                    return commonClick(
                        notificationFinalList[index].readStatus,
                        "${ConstantUtils.aPollYouHaveCreatedRecieved} " " ",
                        "${notificationFinalList[index].comments?.length.toString()}",
                        " comment", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullMessagePoll(
                                poll: pollTempList[0],
                                pollId: notificationFinalList[index].uploadId,
                                indexPlacement: index)),
                      );
                    }, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserList(
                                notificationFinalList[index].commentId!)),
                      );
                    });
                  } else if (notificationFinalList[index].typeStatus ==
                      "messageComments") {
                    List<Post> postTempList = [];
                    for (var i = 0; i < postsList.length; i++) {
                      if (postsList[i].postId ==
                          notificationFinalList[index].uploadId) {
                        postTempList.add(postsList[i]);
                      }
                    }

                    return commonClick(
                        notificationFinalList[index].readStatus,
                        "${ConstantUtils.aMessageYouHaveCreatedRecieved} " " ",
                        "${notificationFinalList[index].comments?.length.toString()}",
                        " comment", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullMessage(
                                post: postTempList[0],
                                postId: notificationFinalList[index].uploadId,
                                indexPlacement: index)),
                      );
                    }, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserList(
                                notificationFinalList[index].commentId!)),
                      );
                    });
                  } else if (notificationFinalList[index].typeStatus ==
                      "pollVote") {
                    List<Poll> pollTempList = [];
                    for (var i = 0; i < pollList.length; i++) {
                      if (pollList[i].pollId ==
                          notificationFinalList[index].uploadId) {
                        pollTempList.add(pollList[i]);
                      }
                    }
                    return commonClick(
                        notificationFinalList[index].readStatus,
                        "${ConstantUtils.aPollYouHaveCreatedRecieved} " " ",
                        "${notificationFinalList[index].score}",
                        " votes", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullMessagePoll(
                                poll: pollTempList[0],
                                pollId: notificationFinalList[index].uploadId,
                                indexPlacement: index)),
                      );
                    }, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserList(
                                notificationFinalList[index].allVotesUID!)),
                      );
                    });
                  } else if (notificationFinalList[index].typeStatus ==
                      "messageReplydisike") {
                    List<Post> postTempList = [];

                    for (var i = 0; i < postsList.length; i++) {
                      if (postsList[i].postId ==
                          notificationFinalList[index].uploadId) {
                        postTempList.add(postsList[i]);
                      }
                    }

                    return commonClick(
                        notificationFinalList[index].readStatus,
                        "${ConstantUtils.aReplyYouHaveCreatedRecieved} " " ",
                        "${notificationFinalList[index].disLikeCount.length}",
                        " dislikes", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullMessage(
                                  post: postTempList[0],
                                  postId: notificationFinalList[index].uploadId,
                                  indexPlacement: index,
                                )),
                      );
                    }, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserList(
                                notificationFinalList[index].disLikeCount)),
                      );
                    });
                  } else if (notificationFinalList[index].typeStatus ==
                      "messageReplylike") {
                    List<Post> postTempList = [];

                    for (var i = 0; i < postsList.length; i++) {
                      if (postsList[i].postId ==
                          notificationFinalList[index].uploadId) {
                        postTempList.add(postsList[i]);
                      }
                    }

                    return commonClick(
                        notificationFinalList[index].readStatus,
                        "${ConstantUtils.aReplyYouHaveCreatedRecieved} " " ",
                        "${notificationFinalList[index].likeCount.length}",
                        " likes", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullMessage(
                                  post: postTempList[0],
                                  postId: notificationFinalList[index].uploadId,
                                  indexPlacement: index,
                                )),
                      );
                    }, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserList(
                                notificationFinalList[index].likeCount)),
                      );
                    });
                  } else if (notificationFinalList[index].typeStatus ==
                      "messageCommentdisike") {
                    List<Post> postTempList = [];

                    for (var i = 0; i < postsList.length; i++) {
                      if (postsList[i].postId ==
                          notificationFinalList[index].uploadId) {
                        postTempList.add(postsList[i]);
                      }
                    }

                    return commonClick(
                        notificationFinalList[index].readStatus,
                        "${ConstantUtils.aCommentYouHaveCreatedRecieved} " " ",
                        "${notificationFinalList[index].disLikeCount.length}",
                        " dislikes", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullMessage(
                                  post: postTempList[0],
                                  postId: notificationFinalList[index].uploadId,
                                  indexPlacement: index,
                                )),
                      );
                    }, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserList(
                                notificationFinalList[index].disLikeCount)),
                      );
                    });
                  } else if (notificationFinalList[index].typeStatus ==
                      "messageCommentLike") {
                    List<Post> postTempList = [];

                    for (var i = 0; i < postsList.length; i++) {
                      if (postsList[i].postId ==
                          notificationFinalList[index].uploadId) {
                        postTempList.add(postsList[i]);
                      }
                    }

                    return commonClick(
                        notificationFinalList[index].readStatus,
                        "${ConstantUtils.aCommentYouHaveCreatedRecieved} " " ",
                        "${notificationFinalList[index].likeCount.length}",
                        " likes", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullMessage(
                                  post: postTempList[0],
                                  postId: notificationFinalList[index].uploadId,
                                  indexPlacement: index,
                                )),
                      );
                    }, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserList(
                                notificationFinalList[index].likeCount)),
                      );
                    });
                  } else if (notificationFinalList[index].typeStatus ==
                      "pollReplydisike") {
                    List<Poll> pollTempList = [];
                    for (var i = 0; i < pollList.length; i++) {
                      if (pollList[i].pollId ==
                          notificationFinalList[index].uploadId) {
                        pollTempList.add(pollList[i]);
                      }
                    }

                    return commonClick(
                        notificationFinalList[index].readStatus,
                        "${ConstantUtils.aReplyYouHaveCreatedRecieved} " " ",
                        "${notificationFinalList[index].disLikeCount.length}",
                        " dislikes", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullMessagePoll(
                                poll: pollTempList[0],
                                pollId: notificationFinalList[index].uploadId,
                                indexPlacement: index)),
                      );
                    }, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserList(
                                notificationFinalList[index].disLikeCount)),
                      );
                    });
                  } else if (notificationFinalList[index].typeStatus ==
                      "pollReplylike") {
                    List<Poll> pollTempList = [];
                    for (var i = 0; i < pollList.length; i++) {
                      if (pollList[i].pollId ==
                          notificationFinalList[index].uploadId) {
                        pollTempList.add(pollList[i]);
                      }
                    }

                    return commonClick(
                        notificationFinalList[index].readStatus,
                        "${ConstantUtils.aReplyYouHaveCreatedRecieved} " " ",
                        "${notificationFinalList[index].likeCount.length}",
                        " likes", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullMessagePoll(
                                poll: pollTempList[0],
                                pollId: notificationFinalList[index].uploadId,
                                indexPlacement: index)),
                      );
                    }, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserList(
                                notificationFinalList[index].likeCount)),
                      );
                    });
                  } else if (notificationFinalList[index].typeStatus ==
                      "pollCommentdisike") {
                    List<Poll> pollTempList = [];

                    for (var i = 0; i < pollList.length; i++) {
                      if (pollList[i].pollId ==
                          notificationFinalList[index].uploadId) {
                        pollTempList.add(pollList[i]);
                      }
                    }

                    return commonClick(
                        notificationFinalList[index].readStatus,
                        "${ConstantUtils.aCommentYouHaveCreatedRecieved} " " ",
                        "${notificationFinalList[index].disLikeCount.length}",
                        " dislikes", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullMessagePoll(
                                poll: pollTempList[0],
                                pollId: notificationFinalList[index].uploadId,
                                indexPlacement: index)),
                      );
                    }, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserList(
                                notificationFinalList[index].disLikeCount)),
                      );
                    });
                  } else if (notificationFinalList[index].typeStatus ==
                      "pollCommentLike") {
                    List<Poll> pollTempList = [];

                    for (var i = 0; i < pollList.length; i++) {
                      if (pollList[i].pollId ==
                          notificationFinalList[index].uploadId) {
                        pollTempList.add(pollList[i]);
                      }
                    }
                    return commonClick(
                        notificationFinalList[index].readStatus,
                        "${ConstantUtils.aCommentYouHaveCreatedRecieved} " " ",
                        "${notificationFinalList[index].likeCount.length}",
                        " likes", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullMessagePoll(
                                poll: pollTempList[0],
                                pollId: notificationFinalList[index].uploadId,
                                indexPlacement: index)),
                      );
                    }, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserList(
                                notificationFinalList[index].likeCount)),
                      );
                    });
                  } else {
                    return const Visibility(
                        visible: false,
                        child: Center(
                          child: Text(
                            'No Notification yet.',
                            style: TextStyle(
                                color: Color.fromARGB(255, 114, 114, 114),
                                fontSize: 18),
                          ),
                        ));
                  }
                },
              )
            : const Center(
                child: Text(
                  'No Notification yet.',
                  style: TextStyle(
                      color: Color.fromARGB(255, 114, 114, 114), fontSize: 18),
                ),
              ));
  }

  getUserDetails(uid) async {
    final AuthMethods _authMethods = AuthMethods();
    User userProfile = await _authMethods.getUserProfileDetails(uid);
    _userDetails.add(userProfile);
    _userDetails = _userDetails.toSet().toList();
    setState(() {});
  }

  @override
  void dispose() {
    if (loadDataStream != null) {
      loadDataStream!.cancel();
    }
    if (loadDataStreamPost != null) {
      loadDataStreamPost!.cancel();
    }
    if (loadDataStreamPoll != null) {
      loadDataStreamPoll!.cancel();
    }
    super.dispose();
  }

  readNotification(User? user) async {
    await FirestoreMethods().updateReadStatus(true, user?.uid ?? '');
  }

  Widget commonClick(bool notificationStatus, String title, String body,
      String subBody, Function mainClick, Function numberClick) {
    return GestureDetector(
        onTap: () {
          print("testing");
          mainClick();
        },
        child: Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: lightGrey, width: 2),
                    color:
                        notificationStatus == true ? Colors.white : lightGrey),
                padding: const EdgeInsets.all(10),
                height: 50,
                //color: notificationStatus == true ? Colors.white : Colors.red,
                child: Row(
                  children: [
                    Text(title),
                    GestureDetector(
                        onTap: () {
                          numberClick();
                        },
                        child: Text(body)),
                    Text(subBody),
                  ],
                ))));
  }
}
