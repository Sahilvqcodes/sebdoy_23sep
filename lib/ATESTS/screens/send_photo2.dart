import 'dart:typed_data';

import 'package:aft/ATESTS/screens/send_photo_3.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../camera/camera_screen.dart';
import '../utils/utils.dart';

class SendPhotoTwo extends StatefulWidget {
  const SendPhotoTwo({Key? key}) : super(key: key);

  @override
  State<SendPhotoTwo> createState() => _SendPhotoTwoState();
}

class _SendPhotoTwoState extends State<SendPhotoTwo> {
  var cameraTitle = "2";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () async {
            Uint8List? file = await openCamera(
              context: context,
              cameraFileType: CameraFileType.image,
              add: "true",
            );

            print('SendPhoto file: ${file}');
            if (file != null) {
              emailAttachmentPhotos.add(file);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SendPhotoThree()),
              );
            }
          },
          child: Container(
            width: 200,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Open camera - 2',
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                Container(width: 6),
                Icon(
                  Icons.keyboard_arrow_right,
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

                // color: Color.fromARGB(255, 0, 144, 158),
                color: Colors.blue),
          ),
        ),
      ),
    );
  }
}
