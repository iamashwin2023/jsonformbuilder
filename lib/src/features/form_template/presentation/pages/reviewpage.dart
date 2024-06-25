import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jsontoformbuilder/src/features/form_template/data/models/data_record.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/template.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/template_data.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/providers/data_source_provider.dart';
import 'package:provider/provider.dart';

import '../../data/models/media.dart';

class ReviewPage extends StatefulWidget {
  final TemplateResponseModel template;

  ReviewPage({required this.template});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  List<TemplateDataEntry> templateDatasEntry = [];

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    // Extract template data from Provider and encode it to JSON
    String jsonData = jsonEncode(
      Provider.of<DataSourceProvider>(context, listen: false).templateDataEntry,
    );

    // Update the template's templateData field
    setState(() {
      widget.template.templateData = jsonData;
    });

    // Decode the JSON string into a list of TemplateDataEntry objects
    List<dynamic> jsonList = jsonDecode(jsonData);
    List<TemplateDataEntry> newData =
        jsonList.map((json) => TemplateDataEntry.fromJson(json)).toList();

    // Update the state with the new data
    setState(() {
      templateDatasEntry = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataSourceProvider = Provider.of<DataSourceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Review Form Data'),
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
                await _uploadMediaFile(dataSourceProvider);
                _saveTemplate(dataSourceProvider);
              },
              child: Text('Submit'),
            ),
            SizedBox(width: 20, height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTemplate(DataSourceProvider dataSourceProvider) async {
    final url = 'https://keysapi.bsite.net/api/TemplateData';
    String jsonData = jsonEncode(widget.template);
    String jsonBody =
        jsonEncode(DataRecordRequestModel(inputData: jsonData).toJson());
    final Map<String, String> headers = {"Content-Type": "application/json"};

    try {
      final updateResponse =
          await http.post(Uri.parse(url), headers: headers, body: jsonBody);

      if (updateResponse.statusCode == 201) {
        print('Data saved successfully.');
      } else {
        print('Failed to save data. Status code: ${updateResponse.statusCode}');
        print('Response body: ${updateResponse.body}');
      }
    } catch (e) {
      print('Error occurred while saving data: $e');
    }
  }

  Future<void> _uploadMediaFile(DataSourceProvider dataSourceProvider) async {
    String apiUrl = 'https://keysapi.bsite.net/api/Media';
    dynamic jsonMedio;
    for (var media in dataSourceProvider.mediaFiles) {
      MediaRequestModel medioData = MediaRequestModel(
          description: media.description,
          templateDataId: media.templateDataId,
          fileType: media.fileType,
          mediaFile: media.mediaFile,
          mediaType: media.mediaType,
          title: media.title);

      try {
        final Map<String, String> headers = {
          "Content-Type": "application/json"
        };
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
          body: jsonEncode(medioData),
        );

        if (response.statusCode == 201) {
          print('File uploaded successfully');
          jsonMedio = jsonDecode(response.body);
        } else {
          print('Failed to upload file. Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error uploading file: $e');
      }
      MediaResponseModel mediaData = MediaResponseModel.fromJson(jsonMedio);
      List<dynamic> jsonList =
          jsonDecode(widget.template.templateData.toString());
      templateDatasEntry =
          jsonList.map((json) => TemplateDataEntry.fromJson(json)).toList();
      for (var data in templateDatasEntry) {
        if (data.value == media.title) {
          setState(() {
            data.value = mediaData.guid;
          });
        }
      }
      String jsonData = jsonEncode(templateDatasEntry);
      setState(() {
        widget.template.templateData = jsonData;
      });
    }
  }
}
