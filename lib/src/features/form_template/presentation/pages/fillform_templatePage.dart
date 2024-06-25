import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/bankers.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/countries.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/form_element.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/languages.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/media.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/states.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/template.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/template_data.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/pages/reviewpage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import '../../../../constatnt_data/media_types.dart';
import '../providers/data_source_provider.dart';
import 'dart:typed_data';
import '../providers/media_provider .dart'; // for Uint8List

class FillFormTemplatePage extends StatefulWidget {
  final TemplateResponseModel template;

  const FillFormTemplatePage({super.key, required this.template});

  @override
  State<FillFormTemplatePage> createState() => _FillFormTemplatePageState();
}

class _FillFormTemplatePageState extends State<FillFormTemplatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<int, String?> _fileNames = {};
  Map<int, Uint8List?> _fileBytes = {};
  Map<int, String?> _mediaTypes = {};
  Map<int, String?> _fileTypes = {};
  Map<int, bool> _uploadSuccess = {};
  Map<int, bool> _showPreviews = {}; // Track if preview should be shown
  MediaRequestModel? media;
  TextEditingController fileTitle = TextEditingController();
  List<TemplateDataEntry> templateDatasEntry = [];
  Map<String, bool> _selectedLanguages = {};
  List<String> _dataSources = [];
  Map<String, TextEditingController> textControllers = {};
  Map<String, String> dropdownValues = {};
  Map<String, bool> checkboxValues = {};
  bool _showPreview = false; // Track if preview should be shown
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
    String jsonData = widget.template.templateData.toString();
    List<dynamic> jsonList = jsonDecode(jsonData);

    for (var jsonData in jsonList) {
      TemplateDataEntry templateDataEntry =
          TemplateDataEntry.fromJson(jsonData);

      setState(() {
        templateDatasEntry.add(templateDataEntry);
      });
    }
    Provider.of<DataSourceProvider>(context, listen: false)
        .updateTemplateDataEntry(templateDatasEntry);
    Provider.of<DataSourceProvider>(context, listen: false).clearMediaFile();
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
      ),
    );
  }

  List<Widget> generateFormWidgets(DataSourceProvider dataSourceProvider) {
    List<Widget> formWidgets = [];
    for (var element in dataSourceProvider.templateDataEntry) {
      switch (element.componentName) {
        case 'TextField':
        case 'NumberField':
        case 'PhoneNumberField':
        case 'TextArea':
          textControllers.putIfAbsent(
              element.label!, () => TextEditingController());
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
          formWidgets.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        label: Text(element.label ?? ''),
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
                        setState(() {
                          dropdownValues[element.label!] =
                              newValue.toString() ?? '';
                          element.value = newValue.toString() ?? '';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
          break;
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
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValues[element.label!] = newValue.toString() ?? '';
                    element.value = newValue.toString() ?? '';
                  });
                },
              ),
            ),
          );
          break;
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
          int index = dataSourceProvider.templateDataEntry.indexOf(element);

          formWidgets.add(Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (_fileNames[index] != null)
                  Text('Selected file: ${_fileNames[index]}'),
                SizedBox(height: 20),
                Text(element.label ?? ''),
                ElevatedButton.icon(
                  onPressed: () async {
                    String? fileName = await _pickFile(element, index);
                    setState(() async {
                      element.value = fileName;
                    });
                  },
                  icon: Icon(Icons.file_upload),
                  label: Text(element.hint ?? ''),
                ),
                if (_fileNames[index] != null)
                  Text('File selected successfully',
                      style: TextStyle(color: Colors.green)),
                SizedBox(
                  height: 10,
                ),
                if (_fileNames[index] != null)
                  ElevatedButton(
                    onPressed: () {
                      setState(() async {
                        _showPreview = true;
                        if (_fileTypes[index] == 'mp4') {
                          await _initializeVideoPreview(index);
                        }
                        _showPreviewDialog(context, index);
                      });
                    },
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
      child: Text("Save"),
    ));
    formWidgets.add(SizedBox(height: 20,));
    formWidgets.add(ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text("Close"),
    ));

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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewPage(
          template: widget.template,
        ),
      ),
    );
  }

  Future<String?> _pickFile(TemplateDataEntry element, int index) async {
    final result =
        await FilePicker.platform.pickFiles(type: FileType.any, withData: true);

    if (result != null) {
      setState(() {
        _fileNames[index] = result.files.single.name;
        _fileBytes[index] = result.files.single.bytes;
        _fileTypes[index] = result.files.single.extension;
        _uploadSuccess[index] = false;
        _showPreviews[index] = false;
        _videoController = null;
      });

      if (_fileTypes[index] != null) {
        _mediaTypes[index] =
            mediaType[result.files.single.extension!.toLowerCase()]!;
      }

      String? fileName =
          await _uploadMediaFile(_fileBytes[index]!, _fileNames[index]!, index);

      // Update the form data entry with the file name
      if (fileName != null) {
        setState(() {
          _uploadSuccess[index] = true;
        });
        return fileName;
      }
    }
    return null;
  }

  Future<String?> _uploadMediaFile(
      Uint8List fileBytes, String fileName, int index) async {
    String base64File = base64Encode(fileBytes);

    media = MediaRequestModel(
      mediaFile: base64File,
      templateDataId: 2,
      title: fileName,
      fileType: _fileTypes[index],
      description: 'a',
      mediaType: _mediaTypes[index],
    );

    // Store media file locally using Provider
    Provider.of<DataSourceProvider>(context, listen: false).addMedia(media!);

    return fileName;
  }

  void _previewFile() {
    setState(() {
      _showPreview = true; // Show preview when clicked
    });
  }

  void _closePreview(int index) {
    setState(() {
      _fileTypes[index] = null;
      _fileBytes[index] = null;
      _fileNames[index] = null;
      _videoController?.dispose();
      _videoController = null;
      _showPreviews[index] = false;
    });
    Provider.of<DataSourceProvider>(context, listen: false).removeMedia(media!);

    Navigator.of(context).pop();
  }

  Future<void> _initializeVideoPreview(int index) async {
    if (_videoController == null) {
      final file =
          await _saveFileToTemp(_fileBytes[index]!, _fileNames[index]!);
      _videoController = VideoPlayerController.file(file);
      await _videoController!.initialize();
      setState(() {
        _videoController!.play();
      });
    }
  }

  Widget _buildPreviewWidget(int index) {
    if (_fileTypes[index]!.toLowerCase() == 'jpg' ||
        _fileTypes[index]!.toLowerCase() == 'jpeg' ||
        _fileTypes[index]!.toLowerCase() == 'png') {
      // Display image preview
      return Stack(children: [
        Image.memory(
          _fileBytes[index]!,
          fit: BoxFit.contain,
        ),
        Positioned(
          right: 0,
          child: IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () {
                _closePreview(index);
              }),
        ),
      ]);
    } else if (_fileTypes[index]!.toLowerCase() == 'mp4') {
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
              onPressed: () {
                _closePreview(index);
              }),
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

  Future<void> _showPreviewDialog(BuildContext context, int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: _buildPreviewWidget(index),
          ),
        );
      },
    );
  }
}
