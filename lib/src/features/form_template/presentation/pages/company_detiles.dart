import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data'; // for Uint8List

class CompanyDetiles extends StatefulWidget {
  const CompanyDetiles({super.key});

  @override
  State<CompanyDetiles> createState() => _CompanyDetilesState();
}

class _CompanyDetilesState extends State<CompanyDetiles> {
  String? _fileName;
  Uint8List? _fileBytes;
  String? _mediaType;
  String? _fileType;
  bool _uploadSuccess = false;
  TextEditingController fileTitle = TextEditingController();
  TextEditingController aboutFile = TextEditingController();
  TextEditingController companyId = TextEditingController();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _fileBytes = result.files.single.bytes;
        _fileType = result.files.single.extension;
        _uploadSuccess = false; // Reset upload success indicator
      });

      // Call the function to upload the file
      await _uploadMediaFile(_fileBytes!, _fileName!);
    }
  }

  // Function to upload media file
  Future<void> _uploadMediaFile(Uint8List fileBytes, String fileName) async {
    // Encode the file bytes to base64
    String base64File = base64Encode(fileBytes);

    // Define the API endpoint
    String apiUrl = 'https://keysapi.bsite.net/api/Media';

    try {
      final Map<String, String> headers = {"Content-Type": "application/json"};
      var uuid = Uuid();
      // Send the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode({
          'guid': uuid.v4(),
          'mediaFile': base64File,
          'fileName': fileName,
          'title': fileTitle.text,
          'description': aboutFile.text,
          'mediaType': _mediaType,
          'companyId': companyId.text
        }),
      );

      // Check the response status
      if (response.statusCode == 200) {
        // Handle successful response
        setState(() {
          _uploadSuccess = true;
        });
        print('File uploaded successfully');
      } else {
        // Handle error response
        print('Failed to upload file. Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exception
      print('Error uploading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text('Upload Image / Video Company Detiles'),
        ),
        body: Center(
            child: SingleChildScrollView(
          child: SizedBox(
            width: width * 0.4,
            height: height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_fileName != null) Text('Selected file: $_fileName'),
                if (_fileBytes != null)
                  _fileType == 'mp4' || _fileType == 'mov'
                      ? Text('Video selected: $_fileName')
                      : Image.memory(_fileBytes!),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: Text('Pick Image or Video'),
                ),
                if (_fileName != null)
                  _uploadSuccess
                      ? Text('File upload successful!',
                          style: TextStyle(color: Colors.green))
                      : Text('Uploading...',
                          style: TextStyle(color: Colors.orange)),
                TextFormField(
                  controller: fileTitle,
                  decoration: InputDecoration(
                    label: Text('File Title'),
                    hintText: 'Enter file title',
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  maxLines: 3,
                  controller: aboutFile,
                  decoration: InputDecoration(
                    label: Text('About File'),
                    hintText: 'Enter about file',
                    border: OutlineInputBorder(),
                  ),
                ),
                DropdownButtonFormField(
                  value: _mediaType,
                  hint: Text('Select media type'),
                  items: ['Image', 'Video'].map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _mediaType = newValue;
                    });
                  },
                ),
                TextFormField(
                  controller: companyId,
                  decoration: InputDecoration(
                    label: Text('company ID'),
                    hintText: 'enter company id',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      await _uploadMediaFile(_fileBytes!, _fileName!);
                    },
                    child: Text('Save'))
              ],
            ),
          ),
        )));
  }
}
