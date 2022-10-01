import 'package:aft/ATESTS/models/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/poll.dart';
import '../models/post.dart';
import '../utils/utils.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPoll(
    String uid,
    String username,
    String profImage,
    String country,
    String global,
    String pollTitle,
    String option1,
    String option2,
    String option3,
    String option4,
    String option5,
    String option6,
    String option7,
    String option8,
    String option9,
    String option10,
  ) async {
    String res = "some error occurred";
    try {
      String pollId = const Uuid().v1();

      Poll poll = Poll(
        pollId: pollId,
        uid: uid,
        allVotesUIDs: [],
        username: username,
        profImage: profImage,
        country: country,
        datePublished: DateTime.now(),
        global: global,
        endDate: DateTime.now().add(const Duration(
          days: 0,
          hours: 0,
          minutes: 1,
        )),
        pollTitle: pollTitle,
        option1: option1,
        option2: option2,
        option3: option3,
        option4: option4,
        option5: option5,
        option6: option6,
        option7: option7,
        option8: option8,
        option9: option9,
        option10: option10,
        vote1: [],
        vote2: [],
        vote3: [],
        vote4: [],
        vote5: [],
        vote6: [],
        vote7: [],
        vote8: [],
        vote9: [],
        vote10: [],
        totalVotes: 0,
      );

      _firestore.collection('polls').doc(pollId).set(
            poll.toJson(),
          );
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> poll({
    required Poll poll,
    required String uid,
    required int optionIndex,
  }) async {
    String res = "some error occurred";
    print("poll.pollIdP ${poll.pollId}");

    try {
      String pollId = poll.pollId;
      String pollUId = poll.uid;

      print('_poll : ${poll.toJson()}');
      print('pollId : $pollId');

      _firestore.collection('polls').doc(pollId).update({
        'allVotesUIDs': FieldValue.arrayUnion([uid]),
        'totalVotes': FieldValue.increment(1),
        'vote$optionIndex': FieldValue.arrayUnion([uid]),
      });
      updatePollVoteNotification(uid, pollId, pollUId);
      print('POLL SUCCESSFULL');

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //upload post
  Future<String> uploadPost(
      String uid,
      String username,
      String profImage,
      String country,
      String global,
      String title,
      String body,
      String videoUrl,
      String photoUrl,
      int selected,
      List<String>? tags) async {
    String res = "some error occurred";
    try {
      String trimmedText = trimText(text: title);
      String postId = const Uuid().v1();

      Post post = Post(
          postId: postId,
          uid: uid,
          username: username,
          profImage: profImage,
          country: country,
          datePublished: DateTime.now(),
          global: global,
          title: trimmedText,
          body: body,
          videoUrl: videoUrl,
          postUrl: photoUrl,
          selected: selected,
          plus: [],
          neutral: [],
          minus: [],
          allVotesUIDs: [],
          score: 0,
          category: 1,
          tags: tags);

      _firestore.collection('posts').doc(postId).set(
            post.toJson(),
          );

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> scoreMessage(
      String postId, String uid, int score, String uploadUid) async {
    try {
      await _firestore.collection('posts').doc(postId).update(
        {'score': score},
      );
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> addBlockList(String? uid, String userUid) async {
    try {
      FirebaseFirestore.instance.collection("users").doc(uid).update({
        'blockList': FieldValue.arrayUnion([userUid])
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> totalVotesPoll(String pollId, String uid, int totalVotes) async {
    try {
      await _firestore.collection('posts').doc(pollId).update(
        {'totalVotes': totalVotes},
      );
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> plusMessage(
    String postId,
    String uid,
    List plus,
    String postUid,
    List minus,
    List neutral,
    String title,
  ) async {
    try {
      if (plus.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'plus': FieldValue.arrayRemove([uid]),
          'allVotesUIDs': FieldValue.arrayRemove([uid]),
        });

        try {
          final query = await _firestore
              .collection('notification')
              .where("uploadId", isEqualTo: postId)
              .where("uploadUserId", isEqualTo: postUid)
              .get();
          //  if (query.docs.length > 0) {
          //     var plusStatus = false;
          for (var element in query.docs) {
            if (/*element.get("uploadUserId") == postUid && element.get("uploadId") == postId && element.get("uid") == uid && */ (element
                        .get("typeStatus") ==
                    "plusVote" ||
                element.get("typeStatus") == "neturalVote" ||
                element.get("typeStatus") == "minusVote")) {
              await _firestore
                  .collection('notification')
                  .doc(element.get('notificationId'))
                  .update({
                'plus': FieldValue.arrayRemove([uid]),
                'datePublished': DateTime.now(),
                'typeStatus': "plusVote",
                'readStatus': false
              });
              // plusStatus = true;
              break;
            }
          }

          /*if (plusStatus == false) {
              plus.remove(uid);
              uploadNotification("plusVote", 0, [], uid, postUid, postId, [], plus, [], "post", "", [], [], title);
            }*/
          /* } else {
           // plus.remove(uid);
           // uploadNotification("plusVote", 0, [], uid, postUid, postId, [], plus, [], "post", "", [], [], title);
          }*/
        } catch (e) {
          print(
            e.toString(),
          );
        }
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'plus': FieldValue.arrayUnion([uid]),
          'neutral': FieldValue.arrayRemove([uid]),
          'minus': FieldValue.arrayRemove([uid]),
          'allVotesUIDs': FieldValue.arrayUnion([uid]),
        });

        try {
          final query = await _firestore
              .collection('notification')
              .where("uploadId", isEqualTo: postId)
              .where("uploadUserId", isEqualTo: postUid)
              .get();

          if (query.docs.length > 0) {
            var plusStatus = false;
            for (var element in query.docs) {
              if (/*element.get("uploadUserId") == postUid && element.get("uploadId") == postId && element.get("uid") == uid &&*/ (element
                          .get("typeStatus") ==
                      "plusVote" ||
                  element.get("typeStatus") == "neturalVote" ||
                  element.get("typeStatus") == "minusVote")) {
                await _firestore
                    .collection('notification')
                    .doc(element.get('notificationId'))
                    .update({
                  'plus': FieldValue.arrayUnion([uid]),
                  'neutral': FieldValue.arrayRemove([uid]),
                  'minus': FieldValue.arrayRemove([uid]),
                  'datePublished': DateTime.now(),
                  'typeStatus': "plusVote",
                  'readStatus': false
                });
                plusStatus = true;
                break;
              }
            }
            if (plusStatus == false) {
              plus.add(uid);
              minus.remove(uid);
              neutral.remove(uid);
              uploadNotification("", "", "plusVote", 0, [], uid, postUid,
                  postId, [], plus, [], "post", "", [], [], title);
            }
          } else {
            plus.add(uid);
            minus.remove(uid);
            neutral.remove(uid);
            uploadNotification("", "", "plusVote", 0, [], uid, postUid, postId,
                [], plus, [], "post", "", [], [], title);
          }
        } catch (e) {
          print(
            e.toString(),
          );
        }
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> neutralMessage(String postId, String uid, List neutral,
      List minus, List plus, String postUId, String title) async {
    try {
      if (neutral.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'neutral': FieldValue.arrayRemove([uid]),
          'allVotesUIDs': FieldValue.arrayRemove([uid]),
        });

        try {
          final query = await _firestore
              .collection('notification')
              .where("uploadId", isEqualTo: postId)
              .where("uploadUserId", isEqualTo: postUId)
              .get();
          //  if (query.docs.length > 0) {
          // var neturalStatus = false;
          for (var element in query.docs) {
            if (/*element.get("uploadUserId") == postUId && element.get("uploadId") == postId && element.get("uid") == uid &&*/ (element
                        .get("typeStatus") ==
                    "plusVote" ||
                element.get("typeStatus") == "neturalVote" ||
                element.get("typeStatus") == "minusVote")) {
              await _firestore
                  .collection('notification')
                  .doc(element.get('notificationId'))
                  .update({
                'neutral': FieldValue.arrayRemove([uid]),
                'datePublished': DateTime.now(),
                'typeStatus': "neturalVote",
                'readStatus': false
              });
              //  neturalStatus = true;
              break;
            }
          }

          /*if (neturalStatus == false) {
              neutral.remove(uid);
              uploadNotification("neutralVote", 0, [], uid, postUId, postId, [], [], neutral, "post", "", [], [], title);
            }*/
          /*} else {
            neutral.remove(uid);
            uploadNotification("neutralVote", 0, [], uid, postUId, postId, [], [], neutral, "post", "", [], [], title);
          }*/
        } catch (e) {
          print(
            e.toString(),
          );
        }
      } else {
        _firestore.collection('posts').doc(postId).update({
          'neutral': FieldValue.arrayUnion([uid]),
          'plus': FieldValue.arrayRemove([uid]),
          'minus': FieldValue.arrayRemove([uid]),
          'allVotesUIDs': FieldValue.arrayUnion([uid]),
        });

        try {
          final query = await _firestore
              .collection('notification')
              .where("uploadId", isEqualTo: postId)
              .where("uploadUserId", isEqualTo: postUId)
              .get();
          if (query.docs.length > 0) {
            var neturalStatus = false;
            for (var element in query.docs) {
              if (/*element.get("uploadUserId") == postUId && element.get("uploadId") == postId && element.get("uid") == uid &&*/ (element
                          .get("typeStatus") ==
                      "plusVote" ||
                  element.get("typeStatus") == "neturalVote" ||
                  element.get("typeStatus") == "minusVote")) {
                await _firestore
                    .collection('notification')
                    .doc(element.get('notificationId'))
                    .update({
                  'neutral': FieldValue.arrayUnion([uid]),
                  'plus': FieldValue.arrayRemove([uid]),
                  'minus': FieldValue.arrayRemove([uid]),
                  'datePublished': DateTime.now(),
                  'typeStatus': "neturalVote",
                  'readStatus': false
                });
                neturalStatus = true;
                break;
              }
            }

            if (neturalStatus == false) {
              neutral.add(uid);
              plus.remove(uid);
              minus.remove(uid);
              uploadNotification("", "", "neturalVote", 0, [], uid, postUId,
                  postId, [], [], neutral, "post", "", [], [], title);
            }
          } else {
            neutral.add(uid);
            plus.remove(uid);
            minus.remove(uid);
            uploadNotification("", "", "neturalVote", 0, [], uid, postUId,
                postId, [], [], neutral, "post", "", [], [], title);
          }
        } catch (e) {
          print(
            e.toString(),
          );
        }
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> minusMessage(String postId, String uid, List minus, List neutral,
      List plus, String postUId, String title) async {
    try {
      if (minus.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'minus': FieldValue.arrayRemove([uid]),
          'allVotesUIDs': FieldValue.arrayRemove([uid]),
        });

        try {
          final query = await _firestore
              .collection('notification')
              .where("uploadId", isEqualTo: postId)
              .where("uploadUserId", isEqualTo: postUId)
              .get();
          //if (query.docs.length > 0) {
          //   var minusStatus = false;
          for (var element in query.docs) {
            if (/*element.get("uploadUserId") == postUId && element.get("uploadId") == postId && element.get("uid") == uid && */ (element
                        .get("typeStatus") ==
                    "plusVote" ||
                element.get("typeStatus") == "neturalVote" ||
                element.get("typeStatus") == "minusVote")) {
              _firestore
                  .collection('notification')
                  .doc(element.get('notificationId'))
                  .update({
                'minus': FieldValue.arrayRemove([uid]),
                'datePublished': DateTime.now(),
                'typeStatus': "minusVote",
                'readStatus': false
              });
              // minusStatus = true;
              break;
            }
          }

          /* if (minusStatus == false) {
              minus.remove(uid);
              uploadNotification("minusVote", 0, [], uid, postUId, postId, minus, [], [], "post", "", [], [], title);
            }*/
          /* } else {
            minus.remove(uid);
            uploadNotification("minusVote", 0, [], uid, postUId, postId, minus, [], [], "post", "", [], [], title);
          }*/
        } catch (e) {
          print(
            e.toString(),
          );
        }
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'minus': FieldValue.arrayUnion([uid]),
          'plus': FieldValue.arrayRemove([uid]),
          'neutral': FieldValue.arrayRemove([uid]),
          'allVotesUIDs': FieldValue.arrayUnion([uid]),
        });

        try {
          final query = await _firestore
              .collection('notification')
              .where("uploadId", isEqualTo: postId)
              .where("uploadUserId", isEqualTo: postUId)
              .get();
          if (query.docs.length > 0) {
            var minusStatus = false;
            for (var element in query.docs) {
              if (/*element.get("uploadUserId") == postUId && element.get("uploadId") == postId && element.get("uid") == uid &&*/ (element
                          .get("typeStatus") ==
                      "plusVote" ||
                  element.get("typeStatus") == "neturalVote" ||
                  element.get("typeStatus") == "minusVote")) {
                await _firestore
                    .collection('notification')
                    .doc(element.get('notificationId'))
                    .update({
                  'minus': FieldValue.arrayUnion([uid]),
                  'plus': FieldValue.arrayRemove([uid]),
                  'neutral': FieldValue.arrayRemove([uid]),
                  'datePublished': DateTime.now(),
                  'typeStatus': "minusVote",
                  'readStatus': false
                });
                minusStatus = true;
                break;
              }
            }
            if (minusStatus == false) {
              plus.remove(uid);
              minus.add(uid);
              neutral.remove(uid);
              uploadNotification("", "", "minusVote", 0, [], uid, postUId,
                  postId, minus, [], [], "post", "", [], [], title);
            }
          } else {
            plus.remove(uid);
            minus.add(uid);
            neutral.remove(uid);
            uploadNotification("", "", "minusVote", 0, [], uid, postUId, postId,
                minus, [], [], "post", "", [], [], title);
          }
        } catch (e) {
          print(
            e.toString(),
          );
        }
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> postComment(String postId, String text, String uid, String name,
      String profilePic, String postUid) async {
    try {
      if (text.isNotEmpty) {
        String trimmedText = trimText(text: text);
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': trimmedText,
          'commentId': commentId,
          'datePublished': DateTime.now(),
          'likes': [],
          'likeCount': 0,
          'dislikes': [],
          'dislikeCount': 0,
        });
        uploadNotification("", commentId, "messageComments", 0, [], uid,
            postUid, postId, [], [], [], "post", trimmedText, [], []);
      } else {
        print('Text is empty');
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> postReply(
      String postId,
      String commentId,
      String text,
      String uid,
      String name,
      String profilePic,
      String postUId,
      bool isReply) async {
    try {
      if (text.isNotEmpty) {
        String trimmedText = trimText(text: text);
        String replyId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': trimmedText,
          'replyId': replyId,
          'datePublished': DateTime.now(),
          'likes': [],
          'likeCount': 0,
          'dislikes': [],
          'dislikeCount': 0,
        });
        uploadNotification(
            replyId,
            commentId,
            isReply ? "mention" : "commentReplies",
            0,
            [],
            uid,
            postUId,
            postId,
            [],
            [],
            [],
            "post",
            trimmedText,
            [],
            []);
      } else {
        print('Text is empty');
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> pollComment(String pollId, String text, String uid, String name,
      String profilePic, String pollUid) async {
    try {
      if (text.isNotEmpty) {
        String trimmedText = trimText(text: text);
        String commentId = const Uuid().v1();
        _firestore
            .collection('polls')
            .doc(pollId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': trimmedText,
          'commentId': commentId,
          'datePublished': DateTime.now(),
          'likes': [],
          'likeCount': 0,
          'dislikes': [],
          'dislikeCount': 0,
        });
        uploadNotification("", commentId, "pollComments", 0, [], uid, pollUid,
            pollId, [], [], [], "poll", trimmedText, [], []);
      } else {
        print('Text is empty');
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> pollReply(
      String pollId,
      String commentId,
      String text,
      String uid,
      String name,
      String profilePic,
      String pollUId,
      bool isReply) async {
    try {
      if (text.isNotEmpty) {
        String trimmedText = trimText(text: text);
        String replyId = const Uuid().v1();
        _firestore
            .collection('polls')
            .doc(pollId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': trimmedText,
          'replyId': replyId,
          'datePublished': DateTime.now(),
          'likes': [],
          'likeCount': 0,
          'dislikes': [],
          'dislikeCount': 0,
        });
        uploadNotification(
            replyId,
            commentId,
            isReply ? "mention" : "commentReplies",
            0,
            [],
            uid,
            pollUId,
            pollId,
            [],
            [],
            [],
            "poll",
            trimmedText,
            [],
            []);
      } else {
        print('Text is empty');
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  //deleting post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      // getAllPostNotification(postId);
    } catch (err) {
      print(err.toString());
    }
  }

  //deleting poll
  Future<void> deletePoll(String pollId) async {
    try {
      await _firestore.collection('polls').doc(pollId).delete();
      // getAllPostNotification(pollId);
    } catch (err) {
      print(err.toString());
    }
  }

  //deleting comment
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> deleteReply(
    String postId,
    String commentId,
    String replyId,
  ) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyId)
          .delete();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> deletePollComment(String pollId, String commentId) async {
    try {
      await _firestore
          .collection('polls')
          .doc(pollId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> deletePollReply(
    String pollId,
    String commentId,
    String replyId,
  ) async {
    try {
      await _firestore
          .collection('polls')
          .doc(pollId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyId)
          .delete();
    } catch (err) {
      print(err.toString());
    }
  }

//LIKE+DISLIKES COMMENTS/REPLIES - MESSAGES
  Future<void> likeComment(
    String postId,
    String commentId,
    String uid,
    List likes,
    List dislikes,
    String postUId,
  ) async {
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
          'likeCount': FieldValue.increment(-1),
        });
        likes.remove(uid);
        updateMessageLikes(uid, postId, postUId, "messageCommentLike", likes,
            dislikes, false, commentId);
      } else {
        var updateMap = {
          'likes': FieldValue.arrayUnion([uid]),
          'likeCount': FieldValue.increment(1),
          'dislikes': FieldValue.arrayRemove([uid]),
        };
        likes.add(uid);

        if (dislikes.contains(uid)) {
          updateMap['dislikeCount'] = FieldValue.increment(-1);
          dislikes.remove(uid);
        }
        updateMessageLikes(uid, postId, postUId, "messageCommentdisike", likes,
            dislikes, true, commentId);
        //

        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update(updateMap);
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> dislikeComment(String postId, String commentId, String uid,
      List likes, List dislikes, String postUId) async {
    try {
      if (dislikes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'dislikes': FieldValue.arrayRemove([uid]),
          'dislikeCount': FieldValue.increment(-1),
        });
        dislikes.remove(uid);
        updateMessageLikes(uid, postId, postUId, "messageCommentdisike", likes,
            dislikes, false, commentId);
      } else {
        var updateMap = {
          'dislikes': FieldValue.arrayUnion([uid]),
          'dislikeCount': FieldValue.increment(1),
          'likes': FieldValue.arrayRemove([uid]),
        };
        dislikes.add(uid);
        if (likes.contains(uid)) {
          updateMap['likeCount'] = FieldValue.increment(-1);
          likes.remove(uid);
        }
        updateMessageLikes(uid, postId, postUId, "messageCommentLike", likes,
            dislikes, true, commentId);

        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update(updateMap);
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> likeReply(
    String postId,
    String commentId,
    String uid,
    List likes,
    List dislikes,
    String replyId,
    String postUId,
  ) async {
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
          'likeCount': FieldValue.increment(-1),
        });
        likes.remove(uid);
        updateReplyLikes(uid, postId, postUId, "messageReplylike", likes,
            dislikes, false, replyId);
      } else {
        var updateMap = {
          'likes': FieldValue.arrayUnion([uid]),
          'likeCount': FieldValue.increment(1),
          'dislikes': FieldValue.arrayRemove([uid]),
        };
        likes.add(uid);

        if (dislikes.contains(uid)) {
          updateMap['dislikeCount'] = FieldValue.increment(-1);
          dislikes.remove(uid);
        }
        updateReplyLikes(uid, postId, postUId, "messageReplydisike", likes,
            dislikes, true, replyId);

        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .update(updateMap);
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> dislikeReply(
    String postId,
    String commentId,
    String uid,
    List likes,
    List dislikes,
    String replyId,
    String postUId,
  ) async {
    try {
      if (dislikes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .update({
          'dislikes': FieldValue.arrayRemove([uid]),
          'dislikeCount': FieldValue.increment(-1),
        });
        dislikes.remove(uid);
        updateReplyLikes(uid, postId, postUId, "messageReplydisike", likes,
            dislikes, false, replyId);
      } else {
        var updateMap = {
          'dislikes': FieldValue.arrayUnion([uid]),
          'dislikeCount': FieldValue.increment(1),
          'likes': FieldValue.arrayRemove([uid]),
        };
        dislikes.add(uid);
        if (likes.contains(uid)) {
          updateMap['likeCount'] = FieldValue.increment(-1);
          likes.remove(uid);
        }
        updateReplyLikes(uid, postId, postUId, "messageReplylike", likes,
            dislikes, true, replyId);

        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .update(updateMap);
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  //DISLIKES+LIKES -- POLLS
  Future<void> likePollComment(
    String pollId,
    String pollUId,
    String commentId,
    String uid,
    List likes,
    List dislikes,
  ) async {
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection('polls')
            .doc(pollId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
          'likeCount': FieldValue.increment(-1),
        });
        dislikes.remove(uid);
        updatePollCommentLikes(uid, pollId, pollUId, "pollCommentdisike", likes,
            dislikes, false, commentId);
      } else {
        var updateMap = {
          'likes': FieldValue.arrayUnion([uid]),
          'likeCount': FieldValue.increment(1),
          'dislikes': FieldValue.arrayRemove([uid]),
        };
        likes.add(uid);
        if (dislikes.contains(uid)) {
          updateMap['dislikeCount'] = FieldValue.increment(-1);
          dislikes.remove(uid);
        }
        updatePollCommentLikes(uid, pollId, pollUId, "pollCommentlike", likes,
            dislikes, true, commentId);

        await _firestore
            .collection('polls')
            .doc(pollId)
            .collection('comments')
            .doc(commentId)
            .update(updateMap);
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> dislikePollComment(String pollId, String pollUId,
      String commentId, String uid, List likes, List dislikes) async {
    try {
      if (dislikes.contains(uid)) {
        await _firestore
            .collection('polls')
            .doc(pollId)
            .collection('comments')
            .doc(commentId)
            .update({
          'dislikes': FieldValue.arrayRemove([uid]),
          'dislikeCount': FieldValue.increment(-1),
        });
        dislikes.remove(uid);
        updatePollCommentLikes(uid, pollId, pollUId, "pollCommentdisike", likes,
            dislikes, false, commentId);
      } else {
        var updateMap = {
          'dislikes': FieldValue.arrayUnion([uid]),
          'dislikeCount': FieldValue.increment(1),
          'likes': FieldValue.arrayRemove([uid]),
        };
        dislikes.add(uid);
        if (likes.contains(uid)) {
          updateMap['likeCount'] = FieldValue.increment(-1);
          likes.remove(uid);
        }
        updatePollCommentLikes(uid, pollId, pollUId, "pollCommentlike", likes,
            dislikes, true, commentId);

        await _firestore
            .collection('polls')
            .doc(pollId)
            .collection('comments')
            .doc(commentId)
            .update(updateMap);
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> likePollReply(
    String pollId,
    String pollUId,
    String commentId,
    String uid,
    List likes,
    List dislikes,
    String replyId,
  ) async {
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection('polls')
            .doc(pollId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
          'likeCount': FieldValue.increment(-1),
        });
        likes.add(uid);
        updatePollReplyLikes(uid, pollId, pollUId, "pollReplylike", likes,
            dislikes, false, replyId);
      } else {
        var updateMap = {
          'likes': FieldValue.arrayUnion([uid]),
          'likeCount': FieldValue.increment(1),
          'dislikes': FieldValue.arrayRemove([uid]),
        };
        likes.add(uid);
        if (dislikes.contains(uid)) {
          updateMap['dislikeCount'] = FieldValue.increment(-1);
          dislikes.remove(uid);
        }

        updatePollReplyLikes(uid, pollId, pollUId, "pollReplydisike", likes,
            dislikes, true, replyId);
        await _firestore
            .collection('polls')
            .doc(pollId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .update(updateMap);
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> dislikePollReply(
    String pollId,
    String pollUId,
    String commentId,
    String uid,
    List likes,
    List dislikes,
    String replyId,
  ) async {
    try {
      if (dislikes.contains(uid)) {
        await _firestore
            .collection('polls')
            .doc(pollId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .update({
          'dislikes': FieldValue.arrayRemove([uid]),
          'dislikeCount': FieldValue.increment(-1),
        });
        dislikes.add(uid);
        updatePollReplyLikes(uid, pollId, pollUId, "pollReplydisike", likes,
            dislikes, false, replyId);
      } else {
        var updateMap = {
          'dislikes': FieldValue.arrayUnion([uid]),
          'dislikeCount': FieldValue.increment(1),
          'likes': FieldValue.arrayRemove([uid]),
        };
        dislikes.add(uid);
        if (likes.contains(uid)) {
          updateMap['likeCount'] = FieldValue.increment(-1);
          likes.remove(uid);
        }

        updatePollReplyLikes(uid, pollId, pollUId, "pollCommentlike", likes,
            dislikes, true, replyId);

        await _firestore
            .collection('polls')
            .doc(pollId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .update(updateMap);
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> updateMessageLikes(
      String uid,
      String iD,
      String uploadId,
      String status,
      List likes,
      List dislikes,
      bool removeStatus,
      String commentId) async {
    try {
      final query = await _firestore
          .collection('notification')
          .where("uploadId", isEqualTo: iD)
          .where("uploadUserId", isEqualTo: uploadId)
          .where("commentUploadId",
              isEqualTo: commentId) /*.where("uid", isEqualTo: uid)*/ .get();
      if (query.docs.length > 0) {
        var isDataFound = false;
        query.docs.forEach((element) {
          if (element.get('typeStatus') == "messageCommentLike" ||
              element.get('typeStatus') == "messageCommentdisike") {
            if (status == "messageCommentLike") {
              isDataFound = true;
              status = status == "messageCommentLike"
                  ? "messageCommentdisike"
                  : "messageCommentLike";
              if (removeStatus) {
                element.reference.update({
                  'likeCount': FieldValue.arrayRemove([uid]),
                  'disLikeCount': FieldValue.arrayUnion([uid]),
                  'typeStatus': status,
                  'readStatus': false,
                  'datePublished': DateTime.now(),
                });
              } else {
                element.reference.update({
                  'likeCount': FieldValue.arrayRemove([uid]),
                  'datePublished': DateTime.now(),
                });
              }
            } else {
              isDataFound = true;
              status = status == "messageCommentLike"
                  ? "messageCommentdisike"
                  : "messageCommentLike";
              if (removeStatus) {
                element.reference.update({
                  'disLikeCount': FieldValue.arrayRemove([uid]),
                  'likeCount': FieldValue.arrayUnion([uid]),
                  'typeStatus': status,
                  'readStatus': false,
                  'datePublished': DateTime.now(),
                });
              } else {
                element.reference.update({
                  'disLikeCount': FieldValue.arrayRemove([uid]),
                  'datePublished': DateTime.now(),
                });
              }
            }
          }
        });
        if (removeStatus && isDataFound == false) {
          status = status == "messageCommentLike"
              ? "messageCommentdisike"
              : "messageCommentLike";
          uploadNotification("", commentId, status, 0, likes, uid, uploadId, iD,
              [], [], [], "post", "", dislikes, []);
        }
      } else {
        status = status == "messageCommentLike"
            ? "messageCommentdisike"
            : "messageCommentLike";
        uploadNotification("", commentId, status, 0, likes, uid, uploadId, iD,
            [], [], [], "post", "", dislikes, []);
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> updateReplyLikes(
      String uid,
      String iD,
      String uploadId,
      String status,
      List likes,
      List dislikes,
      bool removeStatus,
      String replyId) async {
    try {
      final query = await _firestore
          .collection('notification')
          .where("uploadId", isEqualTo: iD)
          .where("uploadUserId", isEqualTo: uploadId)
          .where("replyUploadId", isEqualTo: replyId)
          .get();
      if (query.docs.length > 0) {
        var isDataFound = false;
        query.docs.forEach((element) {
          if (element.get('typeStatus') == "messageReplylike" ||
              element.get('typeStatus') == "messageReplydisike") {
            if (status == "messageReplylike") {
              isDataFound = true;
              status = status == "messageReplylike"
                  ? "messageReplydisike"
                  : "messageReplylike";
              if (removeStatus) {
                element.reference.update({
                  'likeCount': FieldValue.arrayRemove([uid]),
                  'disLikeCount': FieldValue.arrayUnion([uid]),
                  'typeStatus': status,
                  'readStatus': false,
                  'datePublished': DateTime.now(),
                });
              } else {
                element.reference.update({
                  'likeCount': FieldValue.arrayRemove([uid]),
                  'datePublished': DateTime.now(),
                });
              }
            } else {
              isDataFound = true;
              status = status == "messageReplylike"
                  ? "messageReplydisike"
                  : "messageReplylike";
              if (removeStatus) {
                element.reference.update({
                  'disLikeCount': FieldValue.arrayRemove([uid]),
                  'likeCount': FieldValue.arrayUnion([uid]),
                  'typeStatus': status,
                  'readStatus': false,
                  'datePublished': DateTime.now(),
                });
              } else {
                element.reference.update({
                  'disLikeCount': FieldValue.arrayRemove([uid]),
                  'datePublished': DateTime.now(),
                });
              }
            }
          }
        });
        if (removeStatus && isDataFound == false) {
          status = status == "messageReplylike"
              ? "messageReplydisike"
              : "messageReplylike";
          uploadNotification(replyId, "", status, 0, likes, uid, uploadId, iD,
              [], [], [], "post", "", dislikes, []);
        }
      } else {
        status = status == "messageReplylike"
            ? "messageReplydisike"
            : "messageReplylike";
        uploadNotification(replyId, "", status, 0, likes, uid, uploadId, iD, [],
            [], [], "post", "", dislikes, []);
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> updatePollCommentLikes(
      String uid,
      String iD,
      String uploadId,
      String status,
      List likes,
      List dislikes,
      bool removeStatus,
      String commentId) async {
    try {
      final query = await _firestore
          .collection('notification')
          .where("uploadId", isEqualTo: iD)
          .where("uploadUserId", isEqualTo: uploadId)
          .where("commentUploadId", isEqualTo: commentId)
          .get();
      if (query.docs.length > 0) {
        var isDataFound = false;
        query.docs.forEach((element) {
          if (element.get('typeStatus') == "pollCommentdisike" ||
              element.get('typeStatus') == "pollCommentlike") {
            if (status == "pollCommentlike") {
              isDataFound = true;
              status = status == "pollCommentlike"
                  ? "pollCommentdisike"
                  : "pollCommentlike";
              if (removeStatus) {
                element.reference.update({
                  'likeCount': FieldValue.arrayRemove([uid]),
                  'disLikeCount': FieldValue.arrayUnion([uid]),
                  'typeStatus': status,
                  'readStatus': false,
                  'datePublished': DateTime.now(),
                });
              } else {
                element.reference.update({
                  'likeCount': FieldValue.arrayRemove([uid]),
                  'datePublished': DateTime.now(),
                });
              }
            } else {
              isDataFound = true;
              status = status == "pollCommentlike"
                  ? "pollCommentdisike"
                  : "pollCommentlike";
              if (removeStatus) {
                element.reference.update({
                  'disLikeCount': FieldValue.arrayRemove([uid]),
                  'likeCount': FieldValue.arrayUnion([uid]),
                  'typeStatus': status,
                  'readStatus': false,
                  'datePublished': DateTime.now(),
                });
              } else {
                element.reference.update({
                  'disLikeCount': FieldValue.arrayRemove([uid]),
                  'datePublished': DateTime.now(),
                });
              }
            }
          }
        });
        if (removeStatus && isDataFound == false) {
          status = status == "pollCommentlike"
              ? "pollCommentdisike"
              : "pollCommentlike";
          uploadNotification("", commentId, status, 0, likes, uid, uploadId, iD,
              [], [], [], "poll", "", dislikes, []);
        }
      } else {
        status = status == "pollCommentlike"
            ? "pollCommentdisike"
            : "pollCommentlike";
        uploadNotification("", commentId, status, 0, likes, uid, uploadId, iD,
            [], [], [], "poll", "", dislikes, []);
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> updatePollReplyLikes(
      String uid,
      String iD,
      String uploadId,
      String status,
      List likes,
      List dislikes,
      bool removeStatus,
      String replyId) async {
    try {
      final query = await _firestore
          .collection('notification')
          .where("uploadId", isEqualTo: iD)
          .where("uploadUserId", isEqualTo: uploadId)
          .where("replyUploadId", isEqualTo: replyId)
          .get();
      if (query.docs.length > 0) {
        var isDataFound = false;
        query.docs.forEach((element) {
          if (element.get('typeStatus') == "pollReplydisike" ||
              element.get('typeStatus') == "pollReplylike") {
            if (status == "pollReplylike") {
              isDataFound = true;
              status = status == "pollReplylike"
                  ? "pollReplydisike"
                  : "pollReplylike";
              if (removeStatus) {
                element.reference.update({
                  'likeCount': FieldValue.arrayRemove([uid]),
                  'disLikeCount': FieldValue.arrayUnion([uid]),
                  'typeStatus': status,
                  'readStatus': false,
                  'datePublished': DateTime.now(),
                });
              } else {
                element.reference.update({
                  'likeCount': FieldValue.arrayRemove([uid]),
                  'datePublished': DateTime.now(),
                });
              }
            } else {
              isDataFound = true;
              status = status == "pollReplylike"
                  ? "pollReplydisike"
                  : "pollReplylike";
              if (removeStatus) {
                element.reference.update({
                  'disLikeCount': FieldValue.arrayRemove([uid]),
                  'likeCount': FieldValue.arrayUnion([uid]),
                  'typeStatus': status,
                  'readStatus': false,
                  'datePublished': DateTime.now(),
                });
              } else {
                element.reference.update({
                  'disLikeCount': FieldValue.arrayRemove([uid]),
                  'datePublished': DateTime.now(),
                });
              }
            }
          }
        });
        if (removeStatus && isDataFound == false) {
          status =
              status == "pollReplylike" ? "pollReplydisike" : "pollReplylike";
          uploadNotification(replyId, "", status, 0, likes, uid, uploadId, iD,
              [], [], [], "poll", "", dislikes, []);
        }
      } else {
        status =
            status == "pollReplylike" ? "pollReplydisike" : "pollReplylike";
        uploadNotification(replyId, "", status, 0, likes, uid, uploadId, iD, [],
            [], [], "poll", "", dislikes, []);
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> uploadNotification(
      String replyUploadId,
      String commentUploadId,
      String typeOfNotification,
      int score,
      List likeCount,
      String uid,
      String uploadUserId,
      String uploadId,
      List minus,
      List plus,
      List netural,
      String type,
      String commentReply,
      List disLikeCount,
      List allVotesUID,
      [String? title]) async {
    try {
      String notificationId = const Uuid().v4();

      NotificationModel notification = NotificationModel(
          replyUploadId: replyUploadId,
          commentUploadId: commentUploadId,
          title: title,
          typeStatus: typeOfNotification,
          score: score,
          readStatus: false,
          commentReply: commentReply,
          notification_id: notificationId,
          datePublished: DateTime.now(),
          uploadUserId: uploadUserId,
          uploadId: uploadId,
          type: type,
          plus: plus,
          minus: minus,
          neutral: netural,
          uid: uid,
          likeCount: likeCount,
          disLikeCount: disLikeCount,
          allVotesUID: allVotesUID);

      _firestore
          .collection('notification')
          .doc(notificationId)
          .set(notification.toJson());
    } catch (err) {
      print(err);
    }
  }

  Future<void> updateReadStatus(bool status, String uid) async {
    try {
      final query = await _firestore
          .collection('notification')
          .where("uploadUserId", isEqualTo: uid)
          .get();
      query.docs.forEach((element) {
        element.reference.update({'readStatus': true});
      });
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> updatePollVotes(
      String uid, String pollId, String pollUId) async {
    try {
      final query = await _firestore
          .collection('polls')
          .where("pollId", isEqualTo: pollId)
          .get();
      query.docs.forEach((element) {
        print(element.get("totalVotes"));
        uploadNotification(
            "",
            "",
            "pollVote",
            element.get("totalVotes"),
            [],
            uid,
            pollUId,
            pollId,
            [],
            [],
            [],
            "poll",
            "",
            [],
            element.get("allVotesUIDs"));
      });
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> updatePollVoteNotification(
      String uid, String pollId, String pollUId) async {
    try {
      final query = await _firestore
          .collection('notification')
          .where("uploadId", isEqualTo: pollId)
          .where("uploadUserId", isEqualTo: pollUId)
          .where("typeStatus", isEqualTo: "pollVote")
          .get();
      if (query.docs.isNotEmpty) {
        for (var element in query.docs) {
          element.reference.update(({
            'score': FieldValue.increment(1),
            'allVotesUIDs': FieldValue.arrayUnion([uid]),
            'readStatus': false,
            'datePublished': DateTime.now(),
          }));
        }
      } else {
        List allVoteUID = [];
        allVoteUID.add(uid);
        uploadNotification("", "", "pollVote", 1, [], uid, pollUId, pollId, [],
            [], [], "poll", "", [], allVoteUID);
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getUser(String uid) async {
    List<Map<String, dynamic>> dummyListMap = [];
    try {
      final query = await _firestore
          .collection('users')
          .where("uid", isEqualTo: uid)
          .get();
      query.docs.forEach((element) {
        dummyListMap.add(Map<String, dynamic>.from(element.data()));
      });
      return dummyListMap;
    } catch (e) {
      print(
        e.toString(),
      );
    }
    return dummyListMap;
  }

  Future<String> getUsername(String uid) async {
    try {
      final query = await _firestore
          .collection('users')
          .where("uid", isEqualTo: uid)
          .get();
      query.docs.forEach((element) {
        return element.get('username') ?? "";
      });
    } catch (e) {
      print(
        e.toString(),
      );
    }
    return '';
  }

  Future<void> getAllPostNotification(String postId) async {
    try {
      final query = await _firestore
          .collection('notification')
          .where("uploadId", isEqualTo: postId)
          .get();
      query.docs.forEach((element) {
        element.reference.delete();
      });
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }
}
