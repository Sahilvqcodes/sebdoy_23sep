import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../methods/auth_methods.dart';
import '../methods/storage_methods.dart';
import '../models/user.dart';
import '../utils/utils.dart';
import '../provider/user_provider.dart';

class EditProfile extends StatefulWidget {
  // final Post post;
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // late Post _post;
  bool posts = true;
  bool comment = false;
  bool username = false;
  bool valueFlag = false;
  var selectFlag = false;
  bool valueBadge = false;
  var selectBadge = false;
  String? _image;
  User? user;

  // UI
  bool isLoading = false;
  bool isEditingUsername = false;
  bool isEditingEmail = false;
  bool isEditingBio = false;

  // Controllers
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getValueFlag();
    getValueBadge();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      // _image = im;
      isLoading = true;
    });
    String photoUrl =
        await StorageMethods().uploadImageToStorage('profilePics', im, false);
    if (photoUrl != null) {
      await AuthMethods().changeProfilePic(profilePhotoUrl: photoUrl);
      UserProvider userProvider = Provider.of(context, listen: false);
      await userProvider.refreshUser();
    }
    showSnackBar('Profile picture uploaded.', context);
    setState(() {
      isLoading = false;
    });
  }

  getValueFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectFlag = prefs.getBool('selected_displayFlag') ?? true;
    });
  }

  setValueFlag(bool valueFlag) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('selected_displayFlag', valueFlag);
  }

  getValueBadge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectBadge = prefs.getBool('selected_badge') ?? true;
    });
  }

  setValueBadge(bool valueBadge) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('selected_badge', valueBadge);
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserProvider>(context).getUser;
    bool isSignedIn = user != null;
    _image = user!.photoUrl;
    print(_image);

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        title:
            const Text('Edit Profile', style: TextStyle(color: Colors.black)),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 245, 245, 245),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: ListView(
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: isSignedIn
                    ? Column(
                        children: [
                          // Flexible(child: Container(), flex: 1),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 25.0,
                            ),
                            child: Stack(
                              children: [
                                // _image != null

                                Padding(
                                    padding: const EdgeInsets.only(bottom: 5.0),
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black,
                                        ),
                                        child: Opacity(
                                          opacity: _image != null ? 0.7 : 1,
                                          child: _image != null &&
                                                  _image!.isNotEmpty
                                              ? CircleAvatar(
                                                  backgroundColor: Colors.black,
                                                  radius: 64,
                                                  // backgroundImage: MemoryImage(_image!),
                                                  backgroundImage: NetworkImage(
                                                    _image!,
                                                  ),
                                                )
                                              : CircleAvatar(
                                                  radius: 64,
                                                  backgroundImage: AssetImage(
                                                      'assets/avatarFT.jpg'),
                                                  backgroundColor:
                                                      Colors.grey.shade200,
                                                ),
                                        ),
                                      ),
                                    )

                                    // backgroundImage: NetworkImage(
                                    //   'https://images.nightcafe.studio//assets/profile.png?tr=w-1600,c-at_max',
                                    // ),
                                    ),
                                Positioned(
                                  // bottom: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 35.0, right: 11),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Container(),
                                        ),
                                        IconButton(
                                          onPressed: selectImage,
                                          icon: Icon(
                                            Icons.add_a_photo,
                                            color: Colors.white.withOpacity(
                                                _image != null ? 0.55 : 0.8),
                                            size: 40,
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                user != null &&
                                        selectFlag != false &&
                                        user?.country != ""
                                    ? Positioned(
                                        bottom: 5,
                                        right: 134,
                                        child: Container(
                                          width: 40,
                                          height: 20,
                                          child: Image.asset(
                                              'icons/flags/png/${user?.country}.png',
                                              package: 'country_icons'),
                                        ),
                                      )
                                    : Container(),
                                user != null && user?.profileBadge != "false"
                                    ? Positioned(
                                        bottom: 7,
                                        right: 122,
                                        child: CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Color.fromARGB(
                                              255, 245, 245, 245),
                                          child: Container(
                                            child: Icon(Icons.verified,
                                                color: Color.fromARGB(
                                                    255, 113, 191, 255),
                                                size: 31),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 12.0, left: 12, bottom: 0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    width: 0,
                                    color: Color.fromARGB(255, 203, 203, 203)),
                                // color: Color.fromARGB(255, 238, 238, 238),
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Column(
                                  children: [
                                    user?.country != ""
                                        ? Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20.0,
                                                    top: 6,
                                                    right: 5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Display National Flag',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: selectFlag !=
                                                                    false
                                                                ? Colors.black
                                                                : Colors.grey,
                                                          ),
                                                        ),
                                                        // Container(width: 8),
                                                      ],
                                                    ),
                                                    Switch(
                                                      value: selectFlag,
                                                      activeColor: Colors.black,
                                                      onChanged: (valueFlag) {
                                                        selectFlag == false
                                                            ? setState(() {
                                                                setValueFlag(
                                                                    true);
                                                                selectFlag =
                                                                    true;
                                                                valueFlag =
                                                                    true;
                                                                setValueBadge(
                                                                    false);
                                                                selectBadge =
                                                                    false;
                                                                valueBadge =
                                                                    false;

                                                                AuthMethods()
                                                                    .changeProfileFlag(
                                                                        profileFlag:
                                                                            'true');
                                                                AuthMethods()
                                                                    .changeProfileBadge(
                                                                        profileBadge:
                                                                            'false');
                                                                UserProvider
                                                                    userProvider =
                                                                    Provider.of(
                                                                        context,
                                                                        listen:
                                                                            false);
                                                                userProvider
                                                                    .refreshUser();
                                                              })
                                                            : selectFlag == true
                                                                ? setState(() {
                                                                    setValueFlag(
                                                                        false);
                                                                    selectFlag =
                                                                        false;
                                                                    valueFlag =
                                                                        false;

                                                                    AuthMethods().changeProfileFlag(
                                                                        profileFlag:
                                                                            'false');

                                                                    UserProvider
                                                                        userProvider =
                                                                        Provider.of(
                                                                            context,
                                                                            listen:
                                                                                false);
                                                                    userProvider
                                                                        .refreshUser();
                                                                  })
                                                                : null;
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20.0,
                                                            top: 6,
                                                            right: 5),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'Display Verified Badge',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: selectBadge !=
                                                                            false
                                                                        ? Colors
                                                                            .black
                                                                        : Colors
                                                                            .grey,
                                                                  ),
                                                                ),
                                                                // Container(width: 8),
                                                              ],
                                                            ),
                                                            Switch(
                                                              value:
                                                                  selectBadge,
                                                              activeColor:
                                                                  Colors.black,
                                                              onChanged:
                                                                  (valueFlag) {
                                                                selectBadge ==
                                                                        false
                                                                    ? setState(
                                                                        () {
                                                                        setValueBadge(
                                                                            true);
                                                                        selectBadge =
                                                                            true;
                                                                        valueBadge =
                                                                            true;
                                                                        setValueFlag(
                                                                            false);
                                                                        selectFlag =
                                                                            false;
                                                                        valueFlag =
                                                                            false;

                                                                        AuthMethods().changeProfileBadge(
                                                                            profileBadge:
                                                                                'true');
                                                                        AuthMethods().changeProfileFlag(
                                                                            profileFlag:
                                                                                'false');
                                                                        UserProvider
                                                                            userProvider =
                                                                            Provider.of(context,
                                                                                listen: false);
                                                                        userProvider
                                                                            .refreshUser();
                                                                      })
                                                                    : selectBadge ==
                                                                            true
                                                                        ? setState(
                                                                            () {
                                                                            setValueBadge(false);
                                                                            selectBadge =
                                                                                false;

                                                                            valueBadge =
                                                                                false;

                                                                            AuthMethods().changeProfileBadge(profileBadge: 'false');

                                                                            UserProvider
                                                                                userProvider =
                                                                                Provider.of(context, listen: false);
                                                                            userProvider.refreshUser();
                                                                          })
                                                                        : null;
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        : Row(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: UserFieldListTile(
                                        counterText: '',
                                        textInputAction: TextInputAction.done,
                                        maxLength: 16,
                                        label: "Username",
                                        hintText: "Enter new username ...",
                                        value: user?.username,
                                        textController: _userNameController,
                                        isEditing: isEditingUsername,
                                        topPadding: 8,
                                        onEdit: () {
                                          _userNameController.text =
                                              user?.username ?? '';
                                          isEditingUsername = true;
                                          setState(() {});
                                        },
                                        onCancelEdit: () {
                                          isEditingUsername = false;
                                          setState(() {});
                                        },
                                        onSave: () async {
                                          setState(() {
                                            username = true;
                                          });
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          // Validates username
                                          String? userNameValid =
                                              await usernameValidator(
                                                  username:
                                                      _userNameController.text);
                                          if (userNameValid != null) {
                                            showSnackBar(
                                                userNameValid, context);
                                          } else {
                                            bool authenticated =
                                                await performReAuthenticationAction(
                                                    context: context,
                                                    username: username);
                                            if (authenticated) {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              await AuthMethods()
                                                  .changeUsername(
                                                      username:
                                                          _userNameController
                                                              .text);
                                              UserProvider userProvider =
                                                  Provider.of(context,
                                                      listen: false);
                                              await userProvider.refreshUser();
                                              isEditingUsername = false;
                                              setState(() {
                                                isLoading = false;
                                              });
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: UserFieldListTile(
                                        maxLength: 100,
                                        counterText: '',
                                        textInputAction: TextInputAction.done,
                                        label: "Email",
                                        hintText: "Enter new email ...",
                                        value: user?.email,
                                        isEditing: isEditingEmail,
                                        textController: _emailController,
                                        topPadding: 8,
                                        onEdit: () {
                                          _emailController.text =
                                              user?.email ?? '';
                                          isEditingEmail = true;
                                          setState(() {});
                                        },
                                        onCancelEdit: () {
                                          isEditingEmail = false;
                                          setState(() {});
                                        },
                                        onSave: () async {
                                          setState(() {
                                            username = false;
                                          });
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          bool authenticated =
                                              await performReAuthenticationAction(
                                                  context: context,
                                                  username: username);
                                          if (authenticated) {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            var res = await AuthMethods()
                                                .changeEmail(
                                                    email:
                                                        _emailController.text);

                                            if (res == 'success') {
                                              UserProvider userProvider =
                                                  Provider.of(context,
                                                      listen: false);
                                              await userProvider.refreshUser();
                                            } else {
                                              showSnackBar(res, context);
                                            }
                                            isEditingEmail = false;
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: UserFieldListTile(
                                          label: "Bio",
                                          minLines: 7,
                                          maxLength: 500,
                                          hintText:
                                              "Write something about yourself ...",
                                          value: user?.bio == ''
                                              ? "-"
                                              : trimText(text: '${user?.bio}'),
                                          isEditing: isEditingBio,
                                          textController: _bioController,
                                          topPadding: 16,
                                          onEdit: () {
                                            _bioController.text =
                                                user?.bio ?? '';
                                            isEditingBio = true;
                                            setState(() {});
                                          },
                                          onCancelEdit: () {
                                            isEditingBio = false;
                                            setState(() {});
                                          },
                                          onSave: () async {
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());

                                            setState(() {
                                              isLoading = true;
                                            });
                                            await AuthMethods().changeBio(
                                                bio:
                                                    _bioController.text.trim());

                                            UserProvider userProvider =
                                                Provider.of(context,
                                                    listen: false);
                                            await userProvider.refreshUser();

                                            isEditingBio = false;
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Text(
                          'Please login first',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
              Positioned.fill(
                child: Visibility(
                  visible: isLoading,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserFieldListTile extends StatelessWidget {
  final String label;
  final String? value;
  final TextEditingController textController;
  final VoidCallback onEdit;
  final VoidCallback onCancelEdit;
  final VoidCallback onSave;
  final bool isEditing;
  final String hintText;
  final int? minLines;
  final int? maxLength;
  final String? counterText;
  final double topPadding;
  final textInputAction;

  const UserFieldListTile({
    super.key,
    required this.label,
    required this.value,
    required this.onEdit,
    required this.textController,
    required this.onCancelEdit,
    required this.onSave,
    required this.isEditing,
    required this.hintText,
    this.minLines,
    required this.maxLength,
    this.counterText,
    required this.topPadding,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        left: 12,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          isEditing
              ? Padding(
                  padding: const EdgeInsets.only(
                    top: 4,
                    bottom: 0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                            controller: textController,
                            textInputAction: textInputAction,
                            maxLines: null,
                            maxLength: maxLength,
                            minLines: minLines,
                            decoration: InputDecoration(
                              counterText: counterText,
                              hintText: hintText,
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                left: 10,
                                top: topPadding,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 215, 215, 215),
                                    width: 0),
                              ),
                              fillColor: Color.fromARGB(255, 245, 245, 245),
                              filled: true,
                            )),
                      ),
                      // Container(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 27,
                            width: 58,
                            child: InkWell(
                              child: Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                                size: 22,
                              ),
                              onTap: onSave,
                            ),
                          ),
                          InkWell(
                            child: Container(
                              // color: Colors.yellow,
                              height: 27,
                              width: 30,
                              child: Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                                size: 22,
                              ),
                            ),
                            onTap: onCancelEdit,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        value ?? '-',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )),
                    InkWell(
                      onTap: onEdit,
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Icon(
                          Icons.edit,
                          color: Color.fromARGB(255, 70, 70, 70),
                          size: 22,
                        ),
                      ),
                    )
                  ],
                ),
        ],
      ),
    );
  }
}
