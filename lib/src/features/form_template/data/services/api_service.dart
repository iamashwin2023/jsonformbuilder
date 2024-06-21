import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://keysapi.bsite.net/api';
  static const String byCode = 'ByCode';
  static Future<List<dynamic>> fetchCountryByCode(String code) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/availabledatasources/$byCode/$code'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data sources');
    }
  }

  static Future<List<dynamic>> fetchAvailableDataSources() async {
    final response =
        await http.get(Uri.parse('$_baseUrl/availabledatasources'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data sources');
    }
  }

  static Future<List<dynamic>> getAllTemplates() async {
    final url = '$_baseUrl/Templates';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server returns a successful response, parse the JSON
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data sources');
    }
  }

  static Future<dynamic> getTemplate(String? id) async {
    final url = '$_baseUrl/Templates/$id';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server returns a successful response, parse the JSON
      final dynamic data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data sources');
    }
  }

  static Future<List<dynamic>> getAllDataWithTemplate() async {
    final url = '$_baseUrl/TemplateData';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server returns a successful response, parse the JSON
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data sources');
    }
  }

  static void deleteTemplate(String? id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/Templates/$id'));
    if (response.statusCode == 204) {
      print('Template deleted successfully.');
    } else {
      print('Failed to delete template. Status code: ${response.statusCode}');
    }
  }

  static void deleteTemplatesWithData(String? id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/TemplateData/$id'));
    if (response.statusCode == 204) {
      print('Template deleted successfully.');
    } else {
      print('Failed to delete template. Status code: ${response.statusCode}');
    }
  }
}
