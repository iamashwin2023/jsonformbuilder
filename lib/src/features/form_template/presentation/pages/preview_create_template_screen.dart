import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:jsontoformbuilder/src/features/form_template/data/models/template.dart';
import 'package:provider/provider.dart';

import '../../data/models/form_element.dart';
import '../../data/models/template_data.dart';
import '../../data/models/countries.dart';
import '../../data/models/states.dart';
import '../../data/models/bankers.dart';
import '../../data/models/languages.dart';
import '../../data/services/api_service.dart'; // Assuming this service exists
import '../../presentation/providers/data_source_provider.dart'; // Assuming this provider exists

class PreviewCreateTemplateScreen extends StatefulWidget {
  @override
  _PreviewCreateTemplateScreenState createState() =>
      _PreviewCreateTemplateScreenState();
}

class _PreviewCreateTemplateScreenState
    extends State<PreviewCreateTemplateScreen> {
  List<FormElement> formElements = [];
  Map<String, bool> _selectedLanguages = {};
  List<String> _dataSources = [];

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    // Initialize your data here if needed
  }

  Future<void> _saveTemplate(
      List<TemplateData> formElements, String text) async {
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
          ),
        ),
      ),
    );
  }

  List<Widget> generateFormWidgets(DataSourceProvider dataSourceProvider) {
    List<Widget> formWidgets = [];
    const double labelWidth = 150.0;

    for (var element in dataSourceProvider.templateData) {
      switch (element.componentName) {
        case 'TextField':
        case 'NumberField':
        case 'PhoneNumberField':
        case 'TextArea':
          formWidgets.add(
            buildTextField(element, labelWidth),
          );
          break;
        case 'Year':
          formWidgets.add(
            buildYearDropdown(element, labelWidth),
          );
          break;
        case 'Dropdown':
          buildDropdown(element, dataSourceProvider);
          formWidgets.add(
            buildDropdownWidget(element, labelWidth),
          );
          break;
        case 'CheckboxGroup':
          buildCheckboxGroup(element, dataSourceProvider);
          formWidgets.add(
            buildCheckboxGroupWidget(element),
          );
          break;
        case 'Filepicker':
          formWidgets.add(buildFilePicker(element));
          break;
        default:
          formWidgets.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Unsupported widget type'),
            ),
          );
      }
    }
    formWidgets.add(ElevatedButton(
        onPressed: () => _showPopup(context, dataSourceProvider),
        child: Text("Save")));
    return formWidgets;
  }

  Padding buildFilePicker(TemplateData element) {
    return Padding(
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
        ));
  }

  Padding buildTextField(TemplateData element, double labelWidth) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                  label: Text(element.label ?? ''),
                  hintText: element.hint ?? '',
                  // Padding inside the text field
                  border: element.componentName == 'TextArea'
                      ? OutlineInputBorder()
                      : UnderlineInputBorder()),
              keyboardType: element.componentName == 'NumberField'
                  ? TextInputType.number
                  : element.componentName == 'PhoneNumberField'
                      ? TextInputType.phone
                      : TextInputType.text,
              inputFormatters: element.componentName == 'NumberField' ||
                      element.componentName == 'PhoneNumberField'
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              maxLines: element.componentName == 'TextArea' ? 3 : 1,
            ),
          ),
        ],
      ),
    );
  }

  Padding buildNumberField(TemplateData element, double labelWidth) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: labelWidth, maxWidth: labelWidth),
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
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
    );
  }

  Padding buildPhoneNumberField(TemplateData element, double labelWidth) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: labelWidth, maxWidth: labelWidth),
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
    );
  }

  Padding buildTextArea(TemplateData element, double labelWidth) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: labelWidth, maxWidth: labelWidth),
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
                contentPadding:
                    EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildYearDropdown(TemplateData element, double labelWidth) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: labelWidth, maxWidth: labelWidth),
            child: Text(
              element.label ?? '',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          SizedBox(width: 10),
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
    );
  }

  void buildDropdown(
      TemplateData element, DataSourceProvider dataSourceProvider) {
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
  }

  Padding buildDropdownWidget(TemplateData element, double labelWidth) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: element.label ?? '',
        ),
        items: _dataSources.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {},
      ),
    );
  }

  void buildCheckboxGroup(
      TemplateData element, DataSourceProvider dataSourceProvider) {
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
  }

  Padding buildCheckboxGroupWidget(TemplateData element) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            element.label ?? '',
            style: TextStyle(fontSize: 16.0),
          ),
          ..._dataSources.map((option) {
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
    );
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Give Your Template Name.'),
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
                  _saveTemplate(
                      dataSourceProvider.templateData, brandName.text);
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

  // void getLanguages(
  //     TemplateData element, DataSourceProvider dataSourceProvider) {
  //   if (dataSourceProvider.languageData.isEmpty) {
  //     Provider.of<DataSourceProvider>(context, listen: false)
  //         .fetchCountryByCode(element.datasource);
  //   }
  //   List<LanguagesModel> languages = dataSourceProvider.languageData
  //       .map((json) => LanguagesModel.fromJson(json))
  //       .toList();
  //   _dataSources =
  //       languages.map((language) => language.name.toString()).toList();
  // }
}
