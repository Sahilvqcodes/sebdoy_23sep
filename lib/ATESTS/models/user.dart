import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class User {
  final String email;
  final String uid;
  final String? photoUrl;
  final String username;
  String country;

  final String isPending;
  final String bio;
  final dateCreated;
  final profileFlag;
  final profileBadge;
  final String usernameLower;

  User({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.username,
    required this.country,
    required this.bio,
    required this.dateCreated,
    required this.profileFlag,
    required this.isPending,
    required this.usernameLower,
    required this.profileBadge,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "country": country,
        "isPending": isPending,
        "bio": bio,
        "dateCreated": dateCreated,
        "profileFlag": profileFlag,
        "profileBadge": profileBadge,
        "usernameLower": usernameLower,
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return User(
      username: snapshot['username'],
      uid: snapshot['uid'],
      photoUrl: snapshot['photoUrl'],
      email: snapshot['email'],
      country: snapshot['country'],
      isPending: snapshot['isPending'],
      bio: snapshot['bio'],
      dateCreated: snapshot['dateCreated'],
      profileFlag: snapshot['profileFlag'],
      profileBadge: snapshot['profileBadge'],
      usernameLower: snapshot['usernameLower'],
    );
  }
}
