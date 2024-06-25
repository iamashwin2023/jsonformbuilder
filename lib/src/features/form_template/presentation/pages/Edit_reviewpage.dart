import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jsontoformbuilder/src/features/form_template/data/models/data_record.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/template.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/providers/data_source_provider.dart';
import 'package:provider/provider.dart';

import '../../data/models/media.dart';
import '../../data/models/template_data.dart';

class EditReviewPage extends StatefulWidget {
  final Map<String, dynamic> formData;
  DataRecordResponseModel template;
  EditReviewPage({required this.formData, required this.template});

  @override
  State<EditReviewPage> createState() => _EditReviewPageState();
}

class _EditReviewPageState extends State<EditReviewPage> {
  List<TemplateDataEntry> templateDatasEntry = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    Map<String, dynamic> dataMap = jsonDecode(widget.template.inputData!);
    TemplateResponseModel templateResponse =
        TemplateResponseModel.fromJson(dataMap);
    List<dynamic> jsonList = jsonDecode(templateResponse.templateData!);

    List<TemplateDataEntry> newData =
        jsonList.map((json) => TemplateDataEntry.fromJson(json)).toList();
    setState(() {
      templateDatasEntry = newData;
    });
  }

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
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reviewing Form Data:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Scrollbar(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: templateDatasEntry.length,
                          itemBuilder: (context, index) {
                            var dataEntry = templateDatasEntry[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${dataEntry.label}:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${dataEntry.value}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                var filePickerEntry = templateDatasEntry.firstWhere(
                    (entry) => entry.componentName == 'Filepicker',
                    orElse: () =>
                        TemplateDataEntry()); // Return an empty TemplateDataEntry instead of null

                if (filePickerEntry.componentName != null) {
                  await _editMediaFile(dataSourceProvider, templateDatasEntry);
                }
                _editTemplate(dataSourceProvider);
                Navigator.pop(context,'\templatesWithData');
              },
              child: Text('Save Changes'),
            ),
            SizedBox(width: 20, height: 20),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, '\templatesWithData');
                },
                child: Text("Go Back"))
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

  Future<void> _editMediaFile(DataSourceProvider dataSourceProvider,
      List<TemplateDataEntry> templateDatasEntry) async {
    for (var data in dataSourceProvider.beforEditTemplateData) {
      for (var media in dataSourceProvider.mediaFiles) {
        for (var entry in templateDatasEntry) {
          if (entry.value == media.title) {
            String apiUrl =
                'https://keysapi.bsite.net/api/Media/guid/${data.value}';
            try {
              final response = await http.put(
                Uri.parse(apiUrl),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode(media),
              );
              if (response.statusCode == 204) {
                print('File uploaded successfully');
                // Update the entry value after successful API call
                setState(() {
                  entry.value = data.value;
                });
              } else {
                print('Failed to upload file. Error: ${response.statusCode}');
                print('Failed to upload file. Error: ${response.body}');
              }
            } catch (e) {
              print('Error uploading file: $e');
            }
          }
        }
      }
    }
    Map<String, dynamic> dataMap = jsonDecode(widget.template.inputData!);
    TemplateResponseModel templateResponse =
        TemplateResponseModel.fromJson(dataMap);
    templateResponse.templateData = jsonEncode(templateDatasEntry);
    widget.template.inputData = jsonEncode(templateResponse);
  }
}
