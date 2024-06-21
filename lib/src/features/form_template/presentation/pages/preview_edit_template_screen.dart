import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/bankers.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/countries.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/languages.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/states.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/template_data.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/services/api_service.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/providers/data_source_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/form_element.dart';
import '../../data/form_data.dart';
import '../../data/models/template.dart'; // Assume this file exists and contains the JSON data

class PreviewEditTemplateScreen extends StatefulWidget {
  final TemplateResponseModel template;

  const PreviewEditTemplateScreen({super.key, required this.template});

  @override
  State<PreviewEditTemplateScreen> createState() =>
      _PreviewEditTemplateScreenState();
}

class _PreviewEditTemplateScreenState extends State<PreviewEditTemplateScreen> {
  List<FormElement> formElements = [];
  Map<String, bool> _selectedLanguages = {};
  List<String> _dataSources = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveEditedTemplate(
    List<TemplateData> formElements,
    TemplateResponseModel template,
  ) async {
    final url = 'https://keysapi.bsite.net/api/Templates';
    final Map<String, String> headers = {"Content-Type": "application/json"};
    String templateData =
        jsonEncode(formElements.map((e) => e.toJson()).toList());
    TemplateRequestModel newTemplate =
        TemplateRequestModel(name: template.name, templateData: templateData);
    final String jsonBody = jsonEncode(newTemplate.toJson());
    int? id = template.id;
    final updateResponse = await http.put(
      Uri.parse('$url/$id'),
      headers: headers,
      body: jsonBody,
    );
// Check the response status code
    if (updateResponse.statusCode == 201) {
      print('Template saved successfully.');
    } else {
      print(
          'Failed to save template. Status code: ${updateResponse.statusCode}');
    }
  }

  Future<void> _saveTemplate(
      List<FormElement> formElements, String text) async {
    final url = 'https://keysapi.bsite.net/api/Templates';

    String templateData =
        jsonEncode(formElements.map((e) => e.toJson()).toList());

    TemplateRequestModel newTemplate =
        TemplateRequestModel(name: text, templateData: templateData);

    final String jsonBody = jsonEncode(newTemplate.toJson());

    final Map<String, String> headers = {"Content-Type": "application/json"};

    final updateResponse = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonBody,
    );

    // Check the response status code
    if (updateResponse.statusCode == 201) {
      print('Template saved successfully.');
    } else {
      print(
          'Failed to save template. Status code: ${updateResponse.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataSourceProvider = Provider.of<DataSourceProvider>(context);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    List<Widget> formWidgets = generateFormWidgets(dataSourceProvider);

    return Scaffold(
        appBar: AppBar(
          title: Text('Preview Form'),
        ),
        body: Center(
          child: SizedBox(
              height: height,
              width: width * 0.5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  child: Scrollbar(
                    child: ListView(
                      children: formWidgets,
                    ),
                  ),
                ),
              )),
        ));
  }

  List<Widget> generateFormWidgets(DataSourceProvider dataSourceProvider) {
    List<Widget> formWidgets = [];
    const double labelWidth = 150.0;
    for (var element in dataSourceProvider.templateData) {
      switch (element.componentName) {
        case 'TextField':
          formWidgets.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: labelWidth, maxWidth: labelWidth),
                    child: Text(
                      element.label ?? '',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: element.hint ?? '',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          break;
        case 'NumberField':
          formWidgets.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: labelWidth, maxWidth: labelWidth),
                    child: Text(
                      element.label ?? '',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: element.hint ?? '',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
            ),
          );
          break;
        case 'PhoneNumberField':
          formWidgets.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: labelWidth, maxWidth: labelWidth),
                    child: Text(
                      element.label ?? '',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: element.hint ?? '',
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
            ),
          );
          break;
        case 'TextArea':
          formWidgets.add(
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: labelWidth, maxWidth: labelWidth),
                      child: Text(
                        element.label ?? '',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: TextFormField(
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: element.hint ?? '',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal:
                                    10.0), // Padding inside the text field
                            border: OutlineInputBorder(),
                          )),
                    ),
                  ],
                )),
          );
          break;
        case 'Year':
          formWidgets.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: labelWidth, maxWidth: labelWidth),
                    child: Text(
                      element.label ?? '',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  SizedBox(
                      width:
                          10), // Optional: Add some spacing between the label and the dropdown
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        hintText: element.hint ?? '',
                      ),
                      items: List.generate(100, (index) {
                        int year = DateTime.now().year - index;
                        return DropdownMenuItem(
                          value: year,
                          child: Text('$year'),
                        );
                      }),
                      onChanged: (int? newValue) {
                        // Handle change
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
          break;
        case 'Dropdown':
          switch (element.datasource) {
            case 'CN':
              getCountries(element, dataSourceProvider);
              break;
            case 'LANG':
              getLanguages(element, dataSourceProvider);
              break;
            case 'STAT':
              getStates(element, dataSourceProvider);
              break;
            case 'BANK':
              getBanker(element, dataSourceProvider);
              break;
            default:
              break;
          }
          formWidgets.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: element.label ?? '',
                ),
                items:
                    _dataSources.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {},
              ),
            ),
          );
          break;
        case 'CheckboxGroup':
          getCountries(element, dataSourceProvider);
          getLanguages(element, dataSourceProvider);
          if (element.datasource!.isNotEmpty) {
            formWidgets.add(
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(element.label ?? ''),
                    ..._dataSources.map((String option) {
                      return CheckboxListTile(
                        title: Text(option),
                        value: _selectedLanguages[option] ?? false,
                        onChanged: (bool? value) {
                          setState(() {
                            _selectedLanguages[option] = value ?? false;
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          }
          break;
        case 'Filepicker':
          formWidgets.add(Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(element.label ?? ''),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons
                        .file_upload), // Replace 'your_icon_name' with the desired icon name
                    label: Text(element.hint ?? ''),
                  )
                ],
              )));
          break;
      }
    }
    formWidgets.add(ElevatedButton(
        onPressed: () => _showPopup(context, dataSourceProvider),
        child: Text("Save")));

    return formWidgets;
  }

  void getData<T>(
    TemplateData element,
    DataSourceProvider dataSourceProvider,
    List<dynamic> dataSource,
    Future<void> Function(String) fetchFunction,
    T Function(Map<String, dynamic>) fromJson,
    String Function(T) getName,
  ) {
    if (dataSource.isEmpty) {
      fetchFunction(element.datasource!);
    }
    List<T> items = dataSource.map((json) => fromJson(json)).toList();
    _dataSources = items.map((item) => getName(item)).toList();
  }

  void getCountries(
      TemplateData element, DataSourceProvider dataSourceProvider) {
    getData<CountriesModel>(
      element,
      dataSourceProvider,
      dataSourceProvider.countryData,
      dataSourceProvider.fetchCountryByCode,
      (json) => CountriesModel.fromJson(json),
      (item) => item.name.toString(),
    );
  }

  void getStates(TemplateData element, DataSourceProvider dataSourceProvider) {
    getData<StateModel>(
      element,
      dataSourceProvider,
      dataSourceProvider.stateData,
      dataSourceProvider.fetchCountryByCode,
      (json) => StateModel.fromJson(json),
      (item) => item.name.toString(),
    );
  }

  void getBanker(TemplateData element, DataSourceProvider dataSourceProvider) {
    getData<BankerModel>(
      element,
      dataSourceProvider,
      dataSourceProvider.bankerData,
      dataSourceProvider.fetchCountryByCode,
      (json) => BankerModel.fromJson(json),
      (item) => item.name.toString(),
    );
  }

  void getLanguages(
      TemplateData element, DataSourceProvider dataSourceProvider) {
    getData<LanguagesModel>(
      element,
      dataSourceProvider,
      dataSourceProvider.languageData,
      dataSourceProvider.fetchCountryByCode,
      (json) => LanguagesModel.fromJson(json),
      (item) => item.name.toString(),
    );
  }

  void _showPopup(BuildContext context, DataSourceProvider dataSourceProvider) {
    TextEditingController brandName = TextEditingController();
    brandName.text = widget.template.name!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Popup Title'),
          content: Text('This is a simple popup.'),
          actions: <Widget>[
            TextFormField(
              controller: brandName,
              decoration: InputDecoration(
                labelText: 'Template Name',
                hintText: 'Enter template name',
              ),
            ),
            TextButton(
                child: Text('Save'),
                onPressed: () {
                  setState(() {
                    widget.template.name = brandName.text;
                  });
                  _saveEditedTemplate(
                      dataSourceProvider.templateData, widget.template);
                  Navigator.pop(context);
                }),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
