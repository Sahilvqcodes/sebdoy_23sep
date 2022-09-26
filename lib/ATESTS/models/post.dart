import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class Post {
  final String postId;
  final String uid;
  final String username;
  final String profImage;
  String country;
  final String global;
  final String title;
  final String body;
  final String videoUrl;
  final String postUrl;
  int score;
  int category;
  List<dynamic> plus;
  List<dynamic> neutral;
  List<dynamic> minus;
  final List<dynamic> allVotesUIDs;
  final int? selected;
  final datePublished;
  StreamController<Post>? updatingStream;
  dynamic comments;
  List<String>? tags;
  Post(
      {required this.postId,
      required this.uid,
      required this.username,
      required this.profImage,
      required this.country,
      required this.datePublished,
      required this.global,
      required this.title,
      required this.body,
      required this.videoUrl,
      required this.postUrl,
      required this.selected,
      required this.plus,
      required this.neutral,
      required this.minus,
      required this.score,
      required this.category,
      required this.allVotesUIDs,
      this.updatingStream,
      this.tags}) {
    if (updatingStream != null) {
      updatingStream!.stream
          .where((event) => event.postId == postId)
          .listen((event) {
        plus = event.plus;
        minus = event.minus;
        neutral = event.neutral;
        score = event.score;
      });
    }
  }

  Map<String, dynamic> toJson() => {
        "postId": postId,
        "uid": uid,
        "username": username,
        "profImage": profImage,
        "country": country,
        "datePublished": datePublished,
        "global": global,
        "title": title,
        "body": body,
        "videoUrl": videoUrl,
        "postUrl": postUrl,
        "selected": selected,
        "plus": plus,
        "neutral": neutral,
        "minus": minus,
        "score": score,
        "category": category,
        "allVotesUIDs": allVotesUIDs,
        "tags": tags
      };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return fromMap(snapshot);
  }

  static Post fromMap(Map<String, dynamic> snapshot) {
    return Post(
      postId: snapshot['postId'] ?? "",
      uid: snapshot['uid'] ?? "",
      username: snapshot['username'] ?? "",
      profImage: snapshot['profImage'] ?? "",
      country: snapshot['country'],
      global: snapshot['global'] ?? "",
      title: snapshot['title'] ?? "",
      body: snapshot['body'] ?? "",
      videoUrl: snapshot['videoUrl'] ?? "",
      postUrl: snapshot['postUrl'] ?? "",
      plus: (snapshot['plus'] ?? []).cast<String>(),
      neutral: (snapshot['neutral'] ?? []).cast<String>(),
      minus: (snapshot['minus'] ?? []).cast<String>(),
      allVotesUIDs: (snapshot['allVotesUIDs'] ?? []).cast<String>(),
      selected: snapshot['selected'],
      datePublished: snapshot['datePublished'],
      category: snapshot['category'],
      score: snapshot['score'],
      updatingStream: snapshot['updatingStream'],
      tags: (snapshot['tags'] ?? []).cast<String>(),
    );
  }
}
