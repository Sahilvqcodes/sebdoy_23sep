import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? title;
  final String uploadId;
  final String uploadUserId;
  final String commentUploadId;
  final String replyUploadId;
  final String uid;
  final String notification_id;

  final String commentReply;

  final int score;

  List<dynamic> likeCount;
  List<dynamic> disLikeCount;

  final String type;
  final String typeStatus;

  List<dynamic> plus;
  List<dynamic> neutral;
  List<dynamic> minus;

  final datePublished;
  final bool readStatus;
  List<dynamic>? commentId;
  List<dynamic>? comments;
  List<dynamic>? allVotesUID;

  StreamController<NotificationModel>? updatingStream;

  NotificationModel({
    this.title,
    required this.typeStatus,
    required this.score,
    required this.uploadId,
    required this.replyUploadId,
    required this.commentUploadId,
    required this.uploadUserId,
    required this.uid,
    required this.notification_id,
    required this.datePublished,
    required this.commentReply,
    required this.type,
    required this.plus,
    required this.neutral,
    required this.minus,
    required this.readStatus,
    required this.likeCount,
    required this.disLikeCount,
    this.updatingStream,
    this.commentId,
    this.comments,
    this.allVotesUID,
  }) {
    if (updatingStream != null) {
      updatingStream!.stream
          .where((event) => event.uploadId == uploadId)
          .listen((event) {
        plus = event.plus;
        minus = event.minus;
        neutral = event.neutral;
      });
    }
  }

  Map<String, dynamic> toJson() => {
        "title": title,
        "typeStatus": typeStatus,
        "score": score,
        "likeCount": likeCount,
        "disLikeCount": disLikeCount,
        "uploadId": uploadId,
        "uploadUserId": uploadUserId,
        "replyUploadId": replyUploadId,
        "commentUploadId": commentUploadId,
        "uid": uid,
        "datePublished": datePublished,
        "commentId": commentId,
        "allVotesUID": allVotesUID,
        "comments": comments,
        "plus": plus,
        "neutral": neutral,
        "minus": minus,
        "readStatus": readStatus,
        "notificationId": notification_id,
        "commentReply": commentReply,
        "type": type,
        "updatingStream": updatingStream,
      };

  static NotificationModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return fromMap(snapshot);
  }

  static NotificationModel fromMap(Map<String, dynamic> snapshot) {
    return NotificationModel(
      notification_id: snapshot['notificationId'] ?? "",
      commentReply: snapshot['commentReply'] ?? "",
      uploadId: snapshot['uploadId'] ?? "",
      uploadUserId: snapshot['uploadUserId'] ?? "",
      commentUploadId: snapshot['commentUploadId'] ?? "",
      replyUploadId: snapshot['replyUploadId'] ?? "",
      uid: snapshot['uid'] ?? "",
      title: snapshot['title'] ?? "",
      typeStatus: snapshot['typeStatus'] ?? "",
      score: snapshot['score'] ?? 0,
      readStatus: snapshot['readStatus'] ?? false,
      commentId: (snapshot['commentId'] ?? []),
      allVotesUID: (snapshot['allVotesUID'] ?? []),
      comments: (snapshot['comments'] ?? []),
      plus: (snapshot['plus'] ?? []),
      neutral: (snapshot['neutral'] ?? []),
      minus: (snapshot['minus'] ?? []),
      datePublished: snapshot['datePublished'],
      updatingStream: snapshot['updatingStream'],
      type: snapshot['type'] ?? "",
      likeCount: (snapshot['likeCount'] ?? []),
      disLikeCount: (snapshot['disLikeCount'] ?? []),
    );
  }
}
