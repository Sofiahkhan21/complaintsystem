import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerExample extends StatefulWidget {
  @override
  _FilePickerExampleState createState() => _FilePickerExampleState();
}

class _FilePickerExampleState extends State<FilePickerExample> {
  List<PlatformFile>? _selectedFiles;

 Future<List<PlatformFile>?> pickFiles() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: ['jpg', 'pdf', 'doc', 'png', 'txt'], // Add your desired file extensions
  );

  if (result != null) {
    return result.files;
  } else {
    // User canceled the picker
    return null;
  }
}
  Future<void> _pickFiles() async {
    List<PlatformFile>? files = await pickFiles();
    setState(() {
      _selectedFiles = files;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Multiple Files'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickFiles,
              child: Text('Pick Files'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _selectedFiles != null
                  ? ListView.builder(
                      itemCount: _selectedFiles!.length,
                      itemBuilder: (context, index) {
                        final file = _selectedFiles![index];
                        return ListTile(
                          leading: _getFileIcon(file.extension), // Display appropriate icon
                          title: Image.file(File(file.path!)),
                          subtitle: Text(
                              'Size: ${(file.size / 1024).toStringAsFixed(2)} KB'),
                          trailing: Text(file.extension ?? 'Unknown'),
                        );
                      },
                    )
                  : Center(child: Text('No files selected')),
            ),
          ],
        ),
      ),
    );
  }

  // Return appropriate icon based on file extension
  Widget _getFileIcon(String? extension) {
    switch (extension) {
      case 'jpg':
      case 'png':
        return Icon(Icons.image, color: Colors.blue);
      case 'pdf':
        return Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'doc':
      case 'docx':
        return Icon(Icons.description, color: Colors.green);
      case 'txt':
        return Icon(Icons.text_snippet, color: Colors.grey);
      default:
        return Icon(Icons.insert_drive_file, color: Colors.black);
    }
  }
}
