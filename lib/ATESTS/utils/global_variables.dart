import 'package:aft/ATESTS/methods/auth_methods.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../authentication/login_screen.dart';

import '../screens/add_post.dart';
import '../screens/home_screen.dart';

import '../screens/notifications.dart';
import '../screens/profile_screen.dart';
import '../screens/search.dart';

const webScreenSize = 600;

var homeScreenItems = [
  const FeedScreen(),
  const AddPost(),
  const Search(),
  const Notifications(),
];

//initial shared pref
loadPref() async {
  await MyApp.init();
}

const Color lightGrey = Color(0xffEAEAEA);
