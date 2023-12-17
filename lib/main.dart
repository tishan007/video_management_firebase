import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:video_management_firebase/api.dart';
import 'package:video_management_firebase/pages/video_list.dart';
import 'package:video_management_firebase/utils/utils.dart';
import 'package:video_management_firebase/widget/button_widget.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'Video Management';

  @override
  Widget build(BuildContext context) => const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: title,
    home: MainPage(),
  );
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  UploadTask? task;
  File? file;
  final ImagePicker _picker = ImagePicker();

  GlobalKey<FormState> key = GlobalKey();
  final CollectionReference _reference = FirebaseFirestore.instance.collection('video_list');
  String videoUrl = '';

  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerDescription = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final fileName = file != null ? basename(file!.path) : 'No File Selected';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(MyApp.title, style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: const Color(0xFF5bc8e5),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(alignment: Alignment.center,child: Image.asset("assets/talentpro_logo.jpg",width: 160,height: 100),),

              TextFormField(
                controller: _controllerName,
                decoration:
                const InputDecoration(hintText: 'Enter video title'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the video title';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _controllerDescription,
                decoration:
                const InputDecoration(hintText: 'Enter video description'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the video description';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 40),
              const Text(
                "Select File",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF5bc8e5),
                    ),
                    icon: const Icon(Icons.storage),
                      onPressed: selectFile,
                    label: const Text("Storage"),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF5bc8e5),
                    ),
                    icon: const Icon(Icons.camera_alt),
                    onPressed: selectCamera,
                    label: const Text("Camera"),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                fileName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 48),
              ButtonWidget(
                text: 'Upload File',
                icon: Icons.cloud_upload_outlined,
                onClicked:uploadFile,
              ),
              const SizedBox(height: 20),
              task != null ? buildUploadStatus(task!) : Container(),
              const SizedBox(height: 20),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xFF5bc8e5),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        //return VideoList();
                        return const VideoList();
                      },
                    ));
                  },
                  child: const Text("My Video List")
              ),


            ],
          ),
        ),
      ),
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.video);

    if (result == null) return;
    final path = result.files.single.path!;

    setState(() => file = File(path));
  }

  Future selectCamera() async {

    try {
      final XFile? result = await _picker.pickVideo(source: ImageSource.camera);

      if (result == null) return;
      final path = result.path;

      setState(() => file = File(path));
    } on PlatformException catch (e) {
      print("error $e");
    }

  }

  Future uploadFile() async {
    if (file == null) return;

    if (_controllerName.text.isEmpty || _controllerDescription.text.isEmpty) {
      Utils.warningToast("Please fill up the fields");
      return;
    }

    var fileName = basename(file!.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    print('Download-Link: $urlDownload');

    videoUrl = urlDownload;

    Map<String, String> dataToSendFirestore = {
      'title': _controllerName.text,
      'description': _controllerDescription.text,
      'video': videoUrl,
    };


    _reference.add(dataToSendFirestore);

    _controllerName.text = "";
    _controllerDescription.text = "";
    fileName = "";
    Utils.successToast("Video Uploaded Successfully");

  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
    stream: task.snapshotEvents,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final snap = snapshot.data!;
        final progress = snap.bytesTransferred / snap.totalBytes;
        final percentage = (progress * 100).toStringAsFixed(2);

        return Text(
          '$percentage %',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
      } else {
        return Container();
      }
    },
  );
}