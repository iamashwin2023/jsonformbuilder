import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:jsontoformbuilder/src/features/form_template/data/models/media.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/pages/Edit_reviewpage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

// Replace these imports with your actual model imports
import 'package:jsontoformbuilder/src/features/form_template/data/models/countries.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/form_element.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/languages.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/template.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/template_data.dart';
import '../../data/models/bankers.dart';
import '../../data/models/data_record.dart';
import '../../data/models/states.dart';
import '../../data/services/api_service.dart';
import '../providers/data_source_provider.dart';

class PreviewEditTemplateDataPage extends StatefulWidget {
  final DataRecordResponseModel templateWithData;

  const PreviewEditTemplateDataPage({
    Key? key,
    required this.templateWithData,
  }) : super(key: key);

  @override
  State<PreviewEditTemplateDataPage> createState() =>
      _PreviewEditTemplateDataPageState();
}

class _PreviewEditTemplateDataPageState
    extends State<PreviewEditTemplateDataPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _fileName;
  Uint8List? _fileBytes;
  String? _fileType;
  TextEditingController fileTitle = TextEditingController();
  bool _uploadSuccess = false;
  List<TemplateDataEntry> templateDatasEntry = [];
  List<TemplateData> templateDatas = [];
  bool _showPreview = false; // Track if preview should be shown

  Map<String, bool> _selectedLanguages = {};
  List<String> _dataSources = [];
  Map<String, TextEditingController> textControllers = {};
  Map<String, String> dropdownValues = {};
  Map<String, bool> checkboxValues = {};
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  TemplateResponseModel? templateInput;
  List<TemplateDataEntry> mergedData = [];
  bool _isUploading = false; // Tracks file upload status
  String? _uploadError; // Tracks any upload error message
  bool _isLoading = true; // Tracks the initialization loading state
  String? _responseMessage;
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

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
      // Fetch TemplateData
      String jsonData = widget.templateWithData.inputData.toString();
      Map<String, dynamic> inputData = jsonDecode(jsonData);
      templateInput = TemplateResponseModel.fromJson(inputData);
      List<dynamic> jsonList =
          jsonDecode(templateInput!.templateData.toString());
      for (var jsonData in jsonList) {
        TemplateDataEntry templateDataEntry =
            TemplateDataEntry.fromJson(jsonData);
        setState(() {
          templateDatasEntry.add(templateDataEntry);
        });
      }

      // Fetch Template Data
      dynamic templateResponse =
          await ApiService.getTemplate(templateInput!.id.toString());
      TemplateResponseModel template =
          TemplateResponseModel.fromJson(templateResponse);
      List<dynamic> templateDataList =
          jsonDecode(template.templateData.toString());
      for (var templateDataJson in templateDataList) {
        TemplateData templateData = TemplateData.fromJson(templateDataJson);
        setState(() {
          templateDatas.add(templateData);
        });
      }

      Provider.of<DataSourceProvider>(context, listen: false)
          .updateTemplateData(templateDatas);
      Provider.of<DataSourceProvider>(context, listen: false)
          .updateTemplateDataEntry(templateDatasEntry);
      Provider.of<DataSourceProvider>(context, listen: false).clearMediaFile();
    } catch (e) {
      setState(() {
        _responseMessage = 'Failed to load templates: $e'; // Error message
      });
      // Handle any errors
      print('Error initializing data: $e');
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false after data is loaded
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

  List<TemplateDataEntry> mergeTemplateData(List<TemplateData> templateData,
      List<TemplateDataEntry> templateDataEntries) {
    mergedData = [];

    for (var template in templateData) {
      TemplateDataEntry? existingEntry = templateDataEntries.firstWhere(
        (entry) => entry.id == template.id,
        orElse: () => TemplateDataEntry(
          componentName: template.componentName,
          id: template.id,
          label: template.label,
          hint: template.hint,
          value: '', // Default empty value for new template data
        ),
      );
      mergedData.add(existingEntry);
    }

    return mergedData;
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Scrollbar(
              child: ListView(
                children: formWidgets,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> generateFormWidgets(DataSourceProvider dataSourceProvider) {
    List<Widget> formWidgets = [];
    List<TemplateDataEntry> mergedData =
        mergeTemplateData(templateDatas, templateDatasEntry);

    for (var element in mergedData) {
      switch (element.componentName) {
        case 'TextField':
        case 'NumberField':
        case 'PhoneNumberField':
        case 'TextArea':
          textControllers.putIfAbsent(
              element.label!,
              () => TextEditingController(
                  text: element.value ?? '')); // Ensure value is not null
          formWidgets.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      onChanged: (value) {
                        element.value = value;
                      },
                      controller: textControllers[element.label],
                      decoration: InputDecoration(
                        label: Text(element.label ?? ''),
                        hintText: element.hint ?? '',
                        // Padding inside the text field
                        border: element.componentName == 'TextArea'
                            ? OutlineInputBorder()
                            : UnderlineInputBorder(),
                      ),
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
            ),
          );
          break;
        case 'Year':
          int? selectedYear = element.value != null && element.value!.isNotEmpty
              ? int.tryParse(element.value!)
              : null;
          formWidgets.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedYear,
                      decoration: InputDecoration(
                        labelText: element.label ?? '',
                        hintText: element.hint ?? '',
                      ),
                      items: List.generate(100, (index) {
                        int year = DateTime.now().year - index;
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text('$year'),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          dropdownValues[element.label!] = newValue.toString();
                          element.value = newValue.toString();
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a year';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
          break;

        // Handle general dropdown
        case 'Dropdown':
          if (element.datasource == 'CN') {
            getCountries(element, dataSourceProvider);
          }
          if (element.datasource == 'LANG') {
            getLanguages(element, dataSourceProvider);
          }
          if (element.datasource == 'BANK') {
            getBanker(element, dataSourceProvider);
          }
          if (element.datasource == 'STATE') {
            getStates(element, dataSourceProvider);
          }

          String? selectedDropdownValue = element.value?.isNotEmpty == true
              ? element.value
              : (_dataSources.isNotEmpty ? _dataSources[0] : null);

          formWidgets.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: selectedDropdownValue,
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
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValues[element.label!] = newValue ?? '';
                    element.value = newValue ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an option';
                  }
                  return null;
                },
              ),
            ),
          );
          break;
        // Handle checkbox group
        case 'CheckboxGroup':
          if (element.datasource == 'CN') {
            getCountries(element, dataSourceProvider);
          }
          if (element.datasource == 'LANG') {
            getLanguages(element, dataSourceProvider);
          }
          if (element.datasource == 'BANK') {
            getBanker(element, dataSourceProvider);
          }
          if (element.datasource == 'STATE') {
            getStates(element, dataSourceProvider);
          }

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
                        value: checkboxValues[option] ?? false,
                        onChanged: (bool? value) {
                          setState(() {
                            checkboxValues[option] = value ?? false;
                            element.value = checkboxValues.entries
                                .where((entry) => entry.value)
                                .map((entry) => entry.key)
                                .join(','); // Concatenate selected values
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
                if (element.value != null)
                  Text('Selected file: ${element.value}')
                else if (_fileName != null)
                  Text('Selected file: $_fileName'),
                if (_fileName != null) Text('Selected file: $_fileName'),
                SizedBox(height: 20),
                Text(element.label ?? ''),
                ElevatedButton.icon(
                  onPressed: () async {
                    String? fileGuid = await _pickFile(element);
                    setState(() async {
                      element.value = fileGuid;
                    });
                  },
                  icon: Icon(Icons.file_upload),
                  label: Text(element.hint ?? ''),
                ),
                if (_fileName != null)
                  Text('File selected successfully',
                      style: TextStyle(color: Colors.green)),
                SizedBox(
                  height: 10,
                ),
                if (_fileName != null)
                  ElevatedButton(
                    onPressed: () => _showPreviewDialog(context),
                    child: Text('Preview'),
                  ),
              ],
            ),
          ));
          break;
      }
    }
    formWidgets.add(ElevatedButton(
        onPressed: () => _showPopup(context, dataSourceProvider),
        child: Text("Save")));
    formWidgets.add(ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text("Close")));

    return formWidgets;
  }

  void getData<T>(
    TemplateDataEntry element,
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
      TemplateDataEntry element, DataSourceProvider dataSourceProvider) {
    getData<CountriesModel>(
      element,
      dataSourceProvider,
      dataSourceProvider.countryData,
      dataSourceProvider.fetchCountryByCode,
      (json) => CountriesModel.fromJson(json),
      (item) => item.name.toString(),
    );
  }

  void getStates(
      TemplateDataEntry element, DataSourceProvider dataSourceProvider) {
    getData<StateModel>(
      element,
      dataSourceProvider,
      dataSourceProvider.stateData,
      dataSourceProvider.fetchCountryByCode,
      (json) => StateModel.fromJson(json),
      (item) => item.name.toString(),
    );
  }

  void getBanker(
      TemplateDataEntry element, DataSourceProvider dataSourceProvider) {
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
      TemplateDataEntry element, DataSourceProvider dataSourceProvider) {
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
          content: Text('Review Your Details'),
          actions: <Widget>[
            TextButton(
              child: Text('Review'),
              onPressed: () {
                Navigator.pop(context);
                _navigateToReviewPage();
              },
            ),
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

  void _navigateToReviewPage() {
    Map<String, dynamic> formData = {};
    formData.addAll(textControllers.map(
        (key, value) => MapEntry(key, value.text))); // Ensure value is not null
    formData.addAll(dropdownValues);
    formData.addAll(checkboxValues);

    setState(() {
      for (var entry in templateDatasEntry) {
        if (textControllers.containsKey(entry.label)) {
          entry.value = textControllers[entry.label]!.text;
        } else if (dropdownValues.containsKey(entry.label)) {
          entry.value = dropdownValues[entry.label];
        } else if (checkboxValues.containsKey(entry.label)) {
          entry.value = checkboxValues[entry.label].toString();
        }
      }
    });
    templateInput!.templateData =
        jsonEncode(templateDatasEntry.map((e) => e.toJson()).toList());
    widget.templateWithData.inputData = jsonEncode(templateInput);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReviewPage(
          formData: formData,
          template: widget.templateWithData,
        ),
      ),
    );
  }

  Future<String?> _pickFile(TemplateDataEntry element) async {
    final result =
        await FilePicker.platform.pickFiles(type: FileType.any, withData: true);

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _fileBytes = result.files.single.bytes;
        _fileType = result.files.single.extension;
        _uploadSuccess = false;
        _showPreview = false;
        _videoController = null;
      });

      String? fileGuid = await _uploadMediaFile(_fileBytes!, _fileName!);

      // Update the form data entry with the file name
      if (fileGuid != null) {
        setState(() {
          _uploadSuccess = true;
        });
        return fileGuid;
      }
    }
    return null;
  }

  Widget _buildPreviewWidget() {
    if (_fileType!.toLowerCase() == 'jpg' ||
        _fileType!.toLowerCase() == 'jpeg' ||
        _fileType!.toLowerCase() == 'png') {
      // Display image preview
      return Stack(children: [
        Image.memory(
          _fileBytes!,
          fit: BoxFit.contain,
        ),
        Positioned(
          right: 0,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: _closePreview,
          ),
        ),
      ]);
    } else if (_fileType!.toLowerCase() == 'mp4') {
      if (_videoController == null) {
        _saveFileToTemp(_fileBytes!, _fileName!).then((file) {
          _videoController = VideoPlayerController.file(file);
          _videoController!.initialize().then((_) {
            setState(() {}); // Update the widget after the video initializes
            if (_videoController != null &&
                _videoController!.value.isInitialized) _videoController!.play();
          });
        });
      }

      return Stack(alignment: Alignment.center, children: [
        _videoController != null && _videoController!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              )
            : CircularProgressIndicator(),
        Positioned(
          right: 0,
          top: 0,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: _closePreview,
          ),
        ),
      ]);
    } else {
      return Text('Preview not available for this file type.');
    }
  }

  Future<File> _saveFileToTemp(Uint8List bytes, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  void _closePreview() {
    setState(() {
      _fileType = null;
      _fileBytes = null;
      _fileName = null;
      _videoController?.dispose();
      _videoController = null;
      _showPreview = false;
    });
    Navigator.of(context).pop();
  }

  Future<String?> _uploadMediaFile(Uint8List fileBytes, String fileName) async {
    String base64File = base64Encode(fileBytes);
    var uuid = Uuid();

    MediaModel media = MediaModel(
      guid: uuid.v4(),
      mediaFile: base64File,
      templateDataId: 2,
      title: 'a',
      fileType: fileName.split('.').last,
      description: 'a',
      mediaType: 'a',
    );

    // Store media file locally using Provider
    Provider.of<DataSourceProvider>(context, listen: false).updateMedia(media);

    return media.guid;
  }

  void _previewFile() {
    setState(() {
      _showPreview = true; // Show preview when clicked
    });
  }

  Future<void> _showPreviewDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: _buildPreviewWidget(),
          ),
        );
      },
    );
  }
}
