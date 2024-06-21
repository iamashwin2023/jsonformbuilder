import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/available_datasources.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/form_element.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/template.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/template_data.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/pages/preview_create_template_screen.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/pages/preview_edit_template_screen.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/providers/data_source_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class EditTemplatePage extends StatefulWidget {
  final TemplateResponseModel template;
  const EditTemplatePage({super.key, required this.template});

  @override
  State<EditTemplatePage> createState() => _EditTemplatePageState();
}

class _EditTemplatePageState extends State<EditTemplatePage> {
  final _formKey = GlobalKey<FormState>();
  String jsonData = "";
  List<TemplateData> templateDatas = [];
  String? _selectedType;
  String? _label;
  String? _hint;
  String? _dataSource;
  bool? _isMandatory = false;
  late int _sequenceNumber;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    jsonData = widget.template.templateData.toString();
    List<dynamic> jsonList = jsonDecode(jsonData);

    for (var jsonData in jsonList) {
      TemplateData templateData = TemplateData.fromJson(jsonData);

      setState(() {
        templateDatas.add(templateData);
      });
    }
    setState(() {
      _sequenceNumber = templateDatas.length + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataSourceProvider = Provider.of<DataSourceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template.name.toString()),
      ),
      body: Center(
        child:
            Container(child: _buildForm(widget.template, dataSourceProvider)),
      ),
    );
  }

  Widget _buildForm(
      TemplateResponseModel template, DataSourceProvider dataSourceProvider) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Row(children: [
      Container(
        width: width * 0.4,
        height: height,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Expanded(
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
                          validator: (value) => value == null
                              ? 'Please select a field type'
                              : null,
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
                          onPressed: () {
                            _addFormElement(templateDatas);
                          },
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
                                children: [
                                  for (int index = 0;
                                      index < templateDatas.length;
                                      index++)
                                    ListTile(
                                      key: ValueKey(index),
                                      title: Text(
                                          '${index + 1}.${templateDatas[index].label} (${templateDatas[index].componentName})'),
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () =>
                                            _deleteFormElement(index),
                                      ),
                                    ),
                                ],
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
                          child: Text('generate json'),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Provider.of<DataSourceProvider>(context,
                                    listen: false)
                                .updateTemplateData(templateDatas);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PreviewEditTemplateScreen(
                                    template: widget.template),
                              ),
                            );
                          },
                          child: Text('Preview'),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )),
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

  void _addFormElement(List<TemplateData> templateDatas) {
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
        // _panNumber = null;
        //  _natureOfBusiness=null;
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
