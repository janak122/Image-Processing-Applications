import 'dart:convert';

import 'package:ImageClassification/widgets/Loading.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ImageClassification/constants.dart' as Constants;

class SudokuSolver extends StatefulWidget {
  @override
  _SudokuSolverState createState() => _SudokuSolverState();
}

class _SudokuSolverState extends State<SudokuSolver> {
  File image;
  bool _showGrid = false;
  var gridData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sudoku Solver"),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Container(
            child: image == null
                ? Center(
                    child: Text(
                      "Select Image",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                  )
                : Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                      ),
                      child: Image.file(image),
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width,
                  ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          _showGrid == true
              ? ShowGrid(context)
              : image != null
                  ? LoadingOfResponse()
                  : Container(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                color: Colors.green,
                onPressed: () {
                  pickImage(ImageSource.camera);
                },
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Camera",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
              RaisedButton(
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                color: Colors.green,
                onPressed: () {
                  pickImage(ImageSource.gallery);
                },
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Gallery",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  ShowGrid(context) {
    return Column(
        children: List.generate(
      9,
      (i) => IntrinsicWidth(
        child: Row(
          children: List.generate(
            9,
            (j) => Container(
              width: MediaQuery.of(context).size.width / 10,
              height: MediaQuery.of(context).size.width / 10,
              decoration: BoxDecoration(
                color: Colors.blueGrey[700],
                border: Border(
                  top: BorderSide(
                    color: Colors.blueGrey[500],
                    width: (i % 3 == 0) ? 2.0 : 0,
                  ),
                  bottom: BorderSide(
                    color: Colors.blueGrey[500],
                    width: ((i + 1) % 3 == 0) ? 2.0 : 0,
                  ),
                  left: BorderSide(
                    color: Colors.blueGrey[500],
                    width: ((j) % 3 == 0) ? 2.0 : 0,
                  ),
                  right: BorderSide(
                    color: Colors.blueGrey[500],
                    width: ((j + 1) % 3 == 0) ? 2.0 : 0,
                  ),
                ),
              ),
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  gridData[i][j].toString(),
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[50],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }

  //For Localhost use: "http://10.0.2.2:8000/"
  //For Deploying on current Network: "http://PC IP from ipconfig:5000/"
  Future pickImage(src) async {
    var img = await ImagePicker.pickImage(source: src);
    img = await ImageCropper.cropImage(
        sourcePath: img.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.grey,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    setState(() {
      _showGrid = false;
      image = img;
    });
    var res = await uploadImage(img.path, Constants.SERVER_URL + "Sudoku");
    var response = await http.Response.fromStream(res);
    var data = jsonDecode(response.body);
    setState(() {
      gridData = data['data'];
      _showGrid = true;
    });
  }

  Future uploadImage(filename, url) async {
    Map<String, String> headers = {"Content-type": "multipart/form-data"};
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('picture', filename));
    request.headers.addAll(headers);
    var res = await request.send();
    return res;
  }
}
