// ignore_for_file: prefer_final_fields, unused_local_variable, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sort_child_properties_last

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReportMissingChilds extends StatefulWidget {
  const ReportMissingChilds({Key? key}) : super(key: key);

  @override
  State<ReportMissingChilds> createState() => _ReportMissingChilds();
}

class _ReportMissingChilds extends State<ReportMissingChilds> {
  bool _isChoosingFile = false;
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController bFormNumberController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController fatherGuardianNameController =
      TextEditingController();
  final TextEditingController fatherCnicController = TextEditingController();
  final TextEditingController contactInfoController = TextEditingController();

  List<File> _selectedImages = [];
  bool isChooseFileVisible() {
    return _selectedImages.isEmpty;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImages.add(File(pickedImage.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitReport() {
    final String childName = childNameController.text;
    final String bFormNumber = bFormNumberController.text;
    final String gender = genderController.text;
    final String age = ageController.text;
    final String fatherGuardianName = fatherGuardianNameController.text;
    final String fatherCnic = fatherCnicController.text;
    final String contactInfo = contactInfoController.text;
    final selectedImage = _selectedImages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        centerTitle: true,
        title: Text(
          'Report Missing Childs',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: childNameController,
                decoration: InputDecoration(labelText: 'Child Name'),
              ),
              TextField(
                controller: bFormNumberController,
                decoration: InputDecoration(labelText: 'Child B Form Number'),
              ),
              TextField(
                controller: genderController,
                decoration: InputDecoration(labelText: 'Gender'),
              ),
              TextField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Age'),
              ),
              TextField(
                controller: fatherGuardianNameController,
                decoration: InputDecoration(labelText: 'Father/Guardian Name'),
              ),
              TextField(
                controller: fatherCnicController,
                decoration: InputDecoration(labelText: 'Father CNIC'),
              ),
              TextField(
                controller: contactInfoController,
                decoration: InputDecoration(labelText: 'Contact'),
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 260),
                    child: Text(
                      'Select Image',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ),
                  if (isChooseFileVisible())
                    Padding(
                      padding: const EdgeInsets.only(right: 230),
                      child: TextButton(
                        onPressed: _isChoosingFile ? null : _pickImage,
                        child: Container(
                          height: 40,
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.green,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.file_upload,
                                color: Colors.white,
                              ),
                              Text(
                                'Chose File',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Visibility(
                visible: _selectedImages.isNotEmpty,
                child: Wrap(
                  children: [
                    for (int index = 0; index < _selectedImages.length; index++)
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Image.file(
                              _selectedImages[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                _removeImage(index);
                              },
                              child: Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (_selectedImages.length < 5)
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: Colors.grey[200],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                child: ElevatedButton(
                  onPressed: _submitReport,
                  child: Text('Submit Report'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
