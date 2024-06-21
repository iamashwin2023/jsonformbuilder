import 'package:flutter/material.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/template.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/services/api_service.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/pages/edit_template_screen.dart';

import 'fillform_templatePage.dart';

class AvailableTemplatesScreen extends StatefulWidget {
  const AvailableTemplatesScreen({Key? key}) : super(key: key);

  @override
  State<AvailableTemplatesScreen> createState() =>
      _AvailableTemplatesScreenState();
}

class _AvailableTemplatesScreenState extends State<AvailableTemplatesScreen> {
  List<TemplateResponseModel> templates = [];
  bool _isLoading = true; // State variable to track if data is being loaded
  bool _isEmpty = false; // State variable to track if the data is empty
  String? _responseMessage; // State variable to track API response message
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    setState(() {
      _isLoading = true; // Start loading indicator
      _responseMessage = null; // Reset response message
    });

    try {
      List<dynamic>? data = await ApiService.getAllTemplates();
      if (data != null && data.isNotEmpty) {
        setState(() {
          templates =
              data.map((json) => TemplateResponseModel.fromJson(json)).toList();
          _isLoading = false;
          _isEmpty = false;
          //  _responseMessage = 'Templates loaded successfully'; // Success message
        });
      } else {
        // Handle case when data is null or empty
        setState(() {
          _isLoading = false;
          _isEmpty = true;
          //_responseMessage = 'No templates available'; // Empty data message
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Stop loading even if there is an error
        _isEmpty = true; // Set empty to true on error for simplicity
        // Optionally, you could handle errors differently and show a specific message
        _responseMessage = 'Failed to load templates: $e'; // Error message
      });
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
        title: const Text('Saved Templates'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator() // Show loading indicator
            : _isEmpty
                ? Text('No templates available.')
                : // Show message when data is empty or null
                Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: templates.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(templates[index].name ?? ''),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FillFormTemplatePage(
                                      template: templates[index],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
