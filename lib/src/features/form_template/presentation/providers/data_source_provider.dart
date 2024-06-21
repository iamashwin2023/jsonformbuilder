import 'package:flutter/material.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/available_datasources.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/countries.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/form_element.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/languages.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/models/template_data.dart';
import 'package:jsontoformbuilder/src/features/form_template/data/services/api_service.dart';

import '../../data/models/media.dart';

class DataSourceProvider extends ChangeNotifier {
  List<AvailableDataSourcesModel> _availableDataSources = [];
  List<dynamic> _countryData = [];
  List<dynamic> _languageData = [];
  List<dynamic> _stateData = [];
  List<dynamic> _bankerData = [];
  bool _isLoading = false;
  String? _error;
  List<TemplateData> _templateData = [];
  List<TemplateDataEntry> _templateDataEntry = [];
  List<MediaModel> _mediaFiles = [];
  MediaModel _mediaFile = MediaModel();

  List<MediaModel> get mediaFiles => _mediaFiles;
  MediaModel get mediaFile => _mediaFile;
  List<AvailableDataSourcesModel> get availableDataSources =>
      _availableDataSources;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TemplateData> get templateData => _templateData;
  List<dynamic> get countryData => _countryData;
  List<dynamic> get languageData => _languageData;
  List<dynamic> get stateData => _stateData;
  List<dynamic> get bankerData => _bankerData;
  List<TemplateDataEntry> get templateDataEntry => _templateDataEntry;

  void clearData() {
    _availableDataSources = [];
    _countryData = [];
    _languageData = [];
    _stateData = [];
    _bankerData = [];
    _isLoading = false;
    _error;
    _templateData = [];
    _templateDataEntry = [];
    _mediaFiles = [];
    _mediaFile;
    notifyListeners();
  }

  void clearMediaFile() {
    _mediaFile = MediaModel();
  }

  Future<void> fetchAvailableDataSources() async {
    _isLoading = true;
    notifyListeners();
    try {
      List<dynamic> data = await ApiService.fetchAvailableDataSources();
      _availableDataSources =
          data.map((json) => AvailableDataSourcesModel.fromJson(json)).toList();

      _error = null;
    } catch (e) {
      _error = 'Error fetching data sources: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCountryByCode(String? code) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (code == 'CN')
        _countryData = await ApiService.fetchCountryByCode(code!);
      if (code == 'LANG')
        _languageData = await ApiService.fetchCountryByCode(code!);
      if (code == 'STAT')
        _stateData = await ApiService.fetchCountryByCode(code!);
      if (code == 'BANK')
        _bankerData = await ApiService.fetchCountryByCode(code!);

      _error = null;
    } catch (e) {
      _error = 'Error fetching data sources: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateTemplateData(List<TemplateData> newValue) {
    _templateData = newValue;
    notifyListeners();
  }

  void updateTemplateDataEntry(List<TemplateDataEntry> newValue) {
    _templateDataEntry = newValue;
    notifyListeners();
  }

  void updateMedia(MediaModel media) {
    _mediaFile = media;
    notifyListeners();
  }

  void addMedia(MediaModel media) {
    _mediaFiles.add(media);
    notifyListeners();
  }
}
