import 'dart:typed_data';

import 'package:aft/ATESTS/methods/auth_methods.dart';
import 'package:aft/ATESTS/methods/storage_methods.dart';
import 'package:aft/ATESTS/utils/utils.dart';
import 'package:flutter/material.dart';

final List<Uint8List> emailAttachmentPhotos = [];

class SendPhotoThree extends StatefulWidget {
  const SendPhotoThree({Key? key}) : super(key: key);

  @override
  State<SendPhotoThree> createState() => _SendPhotoThreeState();
}

class _SendPhotoThreeState extends State<SendPhotoThree> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: InkWell(
              onTap: () async {
                print(
                    'SendPhotoThree.emailAttachmentPhotos.length: ${emailAttachmentPhotos.length}');
                if (emailAttachmentPhotos.length == 2) {
                  setState(() {
                    isLoading = true;
                  });

                  List<String> photoUrls = [];
                  for (Uint8List file in emailAttachmentPhotos) {
                    // Upload image to Firestorage
                    String photoUrl = await StorageMethods()
                        .uploadImageToStorage(
                            'email_attachment_photos', file, true);
                    photoUrls.add(photoUrl);
                  }

                  // Update download url in Firestore database
                  var res = await AuthMethods().addEmailAttachmentPhotos(
                    photoUrlOne: photoUrls[0],
                    photoUrlTwo: photoUrls[1],
                  );

                  setState(() {
                    isLoading = false;
                  });

                  showSnackBar(res, context);

                  if (res == 'success') {
                    emailAttachmentPhotos.clear();
                    goToHome(context);
                  }
                }
              },
              child: Container(
                width: 200,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Send two photos',
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5)),
                    Container(width: 6),
                    Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(25),
                    ),
                    color: Colors.blue),
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
    );
  }
}
