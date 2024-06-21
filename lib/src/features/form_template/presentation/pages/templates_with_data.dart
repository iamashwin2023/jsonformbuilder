import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/data_record.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/template.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/services/api_service.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/pages/edit_template_screen.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/pages/edit_templates_with_data.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/pages/preview_edit_templatedata.dart';

import '../../data/models/template_data.dart';

class TemplatesWithData extends StatefulWidget {
  const TemplatesWithData({super.key});

  @override
  State<TemplatesWithData> createState() => _TemplatesWithDataState();
}

class _TemplatesWithDataState extends State<TemplatesWithData> {
  List<DataRecordResponseModel> templates = [];
  List<TemplateResponseModel> templatesResponse = [];
  bool _isLoading = true;
  bool _isEmpty = false;
  bool _hasError = false;
  String? _responseMessage;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    setState(() {
      _isLoading = true; // Show loading indicator before API call
      _isEmpty = false; // Reset empty state before API call
      _hasError = false; // Reset error state before API call
      _responseMessage = null; // Reset response message
    });

    try {
      List<dynamic>? data = await ApiService.getAllDataWithTemplate();
      if (data != null) {
        setState(() {
          templates = data
              .map((json) => DataRecordResponseModel.fromJson(json))
              .toList();
          for (var data in templates) {
            final Map<String, dynamic> dataMap = jsonDecode(data.inputData!);
            TemplateResponseModel templateResponse =
                TemplateResponseModel.fromJson(dataMap);
            templatesResponse.add(templateResponse);
          }
          _isLoading = false; // Stop loading indicator
          _isEmpty = templates.isEmpty; // Set empty state if no templates
          // _responseMessage = 'Templates loaded successfully'; // Success message
        });
      } else {
        // Handle case when data is null or empty
        setState(() {
          _isLoading = false;
          _isEmpty = true; // Set empty state when no data is available
          // _responseMessage = 'No templates available'; // Empty data message
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true; // Set error state on catch
        _responseMessage = 'Failed to load templates: $e'; // Error message
      });
      print('Error fetching templates: $e');
    }
    if (_responseMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResponseMessage(_responseMessage!);
      });
    }
  }

  void _showResponseMessage(String message) {
    // You can use either a SnackBar or Dialog to show the message
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text(message)),
    // );
    // Alternatively, you can use a Dialog:
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('API Response'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved User Data Templates'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator() // Show loading indicator
            : _isEmpty
                ? Text('No templates available.') // Show message when no data
                : _hasError
                    ? Text(
                        'Error loading templates. Please try again later.') // Show error message
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: templates.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(templatesResponse[index].name ??
                                      'Unknown Template'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PreviewEditTemplateDataPage(
                                                templateWithData:
                                                    templates[index],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          setState(() {
                                            deleteTemplatesWithData(
                                                templates[index].id);
                                          });
                                        },
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
    );
  }

  Future<void> deleteTemplatesWithData(int? id) async {
    if (id != null) {
      ApiService.deleteTemplatesWithData(id.toString());
      setState(() {
        //templates.removeWhere((template) => template.id == id);        
         int index = templates.indexWhere((template) => template.id == id);

            if (index != -1) {
              // Remove the template and corresponding template response at the same index
              templates.removeAt(index);
              templatesResponse.removeAt(index);
            }

      });
    }
  }
}
