import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:jsontoformbuilder/src/features/form_template/data/models/available_datasources.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/template_data.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/providers/data_source_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/form_element.dart';
import 'preview_create_template_screen.dart';

class CreateTemplateScreen extends StatefulWidget {
  @override
  _CreateTemplateScreenState createState() => _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends State<CreateTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  String jsonData = "";
  List<TemplateData> templateDatas = [];
  String? _selectedType;
  String? _label;
  String? _hint;
  String? _dataSource;
  bool? _isMandatory = false;
  int _sequenceNumber = 1;

  @override
  void initState() {
    super.initState();
    // Call fetchAvailableDataSources when the screen is initialized
    Provider.of<DataSourceProvider>(context, listen: false)
        .fetchAvailableDataSources();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Template'),
      ),
      body: Consumer<DataSourceProvider>(
        builder: (context, dataSourceProvider, child) {
          return _buildForm(dataSourceProvider);
        },
      ),
    );
  }

  Widget _buildForm(DataSourceProvider dataSourceProvider) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Row(children: [
      Container(
        width: width * 0.4,
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  hint: Text('Select field type'),
                  items: [
                    'TextField',
                    'NumberField',
                    'Dropdown',
                    'PhoneNumberField',
                    'CheckboxGroup',
                    'TextArea',
                    'Year',
                    'Filepicker'
                  ].map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a field type' : null,
                ),
                if (_selectedType != null)
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Label'),
                    onSaved: (value) {
                      _label = value;
                    },
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a label' : null,
                  ),
                if (_selectedType != null)
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Hint'),
                    onSaved: (value) {
                      _hint = value;
                    },
                  ),
                if (_selectedType != null)
                  Row(
                    children: [
                      Checkbox(
                        value: _isMandatory,
                        onChanged: (bool? value) {
                          setState(() {
                            _isMandatory = value!;
                          });
                        },
                      ),
                      Text(
                        'This field is mandatory',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                if (_selectedType == 'Dropdown' ||
                    _selectedType == 'CheckboxGroup')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        hint: Text('Select Dropdown Type'),
                        items: dataSourceProvider.availableDataSources
                            .map((AvailableDataSourcesModel source) {
                          return DropdownMenuItem<String>(
                            value: source.code ?? '',
                            child: Text(source.name ?? ''),
                          );
                        }).toList(),
                        onChanged: (String? newValue) async {
                          _dataSource = newValue;
                        },
                        validator: (value) => value == null
                            ? 'Please select a dropdown type'
                            : null,
                      ),
                    ],
                  ),
                ElevatedButton(
                  onPressed: _addFormElement,
                  child: Text('Add Field'),
                ),
                if (templateDatas.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Form Elements',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ReorderableListView(
                        shrinkWrap: true,
                        onReorder: _onReorder,
                        children: templateDatas.asMap().entries.map((entry) {
                          int index = entry.key;
                          TemplateData e = entry.value;
                          return ListTile(
                            key: ValueKey(index), // Using the index as the key
                            title: Text(
                                '${index + 1}. ${e.label} (${e.componentName})'), // Displaying the sequence number
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteFormElement(index),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      jsonData = _generateJson();
                    });
                  },
                  child: Text('Generate JSON'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<DataSourceProvider>(context, listen: false)
                        .updateTemplateData(templateDatas);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreviewCreateTemplateScreen(),
                      ),
                    );
                  },
                  child: Text('Preview'),
                ),
              ],
            ),
          ),
        ),
      ),
      Container(
        width: width * 0.4,
        height: height,
        color: Colors.white,
        padding: EdgeInsets.all(10),
        child: TextField(
          controller: TextEditingController(text: jsonData),
          maxLines: 40, //or null
          decoration:
              InputDecoration.collapsed(hintText: "Enter your text here"),
        ),
      )
    ]);
  }

  void _addFormElement() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var uuid = Uuid();
      setState(() {
        templateDatas.add(TemplateData(
            id: uuid.v4(),
            sequenceNumber:
                _sequenceNumber.toString(), // Using sequence number as key
            componentName: _selectedType!,
            label: _label,
            hint: _hint,
            mandatory: _isMandatory,
            datasource: _dataSource));
        _sequenceNumber++; // Increment the sequence number
        _selectedType = null;
        _label = null;
        _hint = null;
        _dataSource = null;
        _isMandatory = false;
      });
    }
  }

  String _generateJson() {
    String json = jsonEncode(templateDatas.map((e) => e.toJson()).toList());
    return json;
  }

  void _deleteFormElement(int index) {
    setState(() {
      templateDatas.removeAt(index);
      // Adjust the sequence number after deletion
      for (int i = 0; i < templateDatas.length; i++) {
        templateDatas[i].sequenceNumber = (i + 1).toString();
      }
      _sequenceNumber = templateDatas.length + 1;
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final TemplateData item = templateDatas.removeAt(oldIndex);
      templateDatas.insert(newIndex, item);
      // Adjust the sequence number after reorder
      for (int i = 0; i < templateDatas.length; i++) {
        templateDatas[i].sequenceNumber = (i + 1).toString();
      }
      _sequenceNumber = templateDatas.length + 1;
    });
  }
}
