import 'package:flutter/material.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/template.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/services/api_service.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/pages/edit_template_screen.dart';

class SavedTemplateScreen extends StatefulWidget {
  const SavedTemplateScreen({Key? key}) : super(key: key);

  @override
  State<SavedTemplateScreen> createState() => _SavedTemplateScreenState();
}

class _SavedTemplateScreenState extends State<SavedTemplateScreen> {
  List<TemplateResponseModel> templates = [];
  bool _isLoading = true; // Tracks initial data loading
  bool _isUploading = false; // Tracks file upload status
  bool _uploadSuccess = false; // Tracks file upload success
  String? _uploadError; // Tracks file upload error
  String? _responseMessage; // Tracks API response message

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    setState(() {
      _isLoading = true; // Start loading
      _responseMessage = null; // Reset response message
    });
    try {
      List<dynamic>? data = await ApiService.getAllTemplates();
      if (data != null) {
        setState(() {
          templates =
              data.map((json) => TemplateResponseModel.fromJson(json)).toList();
        });
      } else {
        setState(() {
          // _responseMessage = 'No templates available'; // Empty data message
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Failed to load templates: $e'; // Error message
        print('Error fetching templates: $e');
      });
      // print('Error fetching templates: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    if (_responseMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResponseMessage(_responseMessage!);
      });
    }
  }

  void _showResponseMessage(String message) {
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
        title: const Text('Saved Templates'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(templates[index].name ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditTemplatePage(
                                  template: templates[index],
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteTemplate(templates[index].id);
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

  Future<void> deleteTemplate(int? id) async {
    if (id != null) {
      ApiService.deleteTemplate(id.toString());
      setState(() {
        templates.removeWhere((template) => template.id == id);
      });
    }
  }
}
