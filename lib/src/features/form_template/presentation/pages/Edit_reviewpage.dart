import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jsontoformbuilder/src/features/form_template/data/models/data_record.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/template.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/providers/data_source_provider.dart';
import 'package:provider/provider.dart';

class EditReviewPage extends StatefulWidget {
  final Map<String, dynamic> formData;
  DataRecordResponseModel template;
  EditReviewPage({required this.formData, required this.template});

  @override
  State<EditReviewPage> createState() => _EditReviewPageState();
}

class _EditReviewPageState extends State<EditReviewPage> {
  @override
  Widget build(BuildContext context) {
    final dataSourceProvider = Provider.of<DataSourceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Existing Data'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: widget.formData.entries.map((entry) {
                    return ListTile(
                      title: Text(entry.key),
                      subtitle: Text(entry.value.toString()),
                    );
                  }).toList(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _editTemplate(dataSourceProvider);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTemplate(DataSourceProvider dataSourceProvider) async {
    final url =
        'https://keysapi.bsite.net/api/TemplateData/${widget.template.id}'; // Assuming the endpoint for updating data includes the ID
    String jsonBody = jsonEncode(
        DataRecordRequestModel(inputData: widget.template.inputData).toJson());
    final Map<String, String> headers = {"Content-Type": "application/json"};

    try {
      final response =
          await http.put(Uri.parse(url), headers: headers, body: jsonBody);

      if (response.statusCode == 204) {
        print('Data edited successfully.');
      } else {
        print('Failed to edit data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while editing data: $e');
    }
  }

  Future<void> _uploadMediaFile(DataSourceProvider dataSourceProvider) async {
    String apiUrl = 'https://keysapi.bsite.net/api/Media';

    try {
      final Map<String, String> headers = {"Content-Type": "application/json"};
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(dataSourceProvider.mediaFile),
      );

      if (response.statusCode == 201) {
        print('File uploaded successfully');
      } else {
        print('Failed to upload file. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }
}
