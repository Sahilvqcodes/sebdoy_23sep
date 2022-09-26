import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../methods/auth_methods.dart';

class FullImageProfile extends StatefulWidget {
  final photo;
  const FullImageProfile({Key? key, required this.photo}) : super(key: key);

  @override
  State<FullImageProfile> createState() => _FullImageProfileState();
}

class _FullImageProfileState extends State<FullImageProfile> {
  @override
  Widget build(BuildContext context) {
    var safePadding = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            elevation: 0,
            backgroundColor: Colors.white.withOpacity(0.25),
            title: Text(
              'Image Viewer',
              style: TextStyle(color: Colors.black),
            ),
          ),
          backgroundColor: Colors.white,
          body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InteractiveViewer(
                  clipBehavior: Clip.none,
                  minScale: 1,
                  maxScale: 4,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: MediaQuery.of(context).size.height * 1 -
                        safePadding -
                        kToolbarHeight,
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      // color: Colors.blue,
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    child: widget.photo != null
                        ? Image.network(widget.photo)
                        : Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/avatarFT.jpg',
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
