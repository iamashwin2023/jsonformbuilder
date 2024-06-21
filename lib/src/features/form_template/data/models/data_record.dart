import 'package:jsontoformbuilder/src/features/form_template/data/models/template_data.dart';

class DataRecordResponseModel {
  int? id;
  String? inputData;

  DataRecordResponseModel({this.id, this.inputData});

  DataRecordResponseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    inputData = json['inputData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['inputData'] = this.inputData;

    return data;
  }
}

class DataRecordRequestModel {
  String? inputData;

  DataRecordRequestModel({this.inputData});

  DataRecordRequestModel.fromJson(Map<String, dynamic> json) {
    inputData = json['inputData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['inputData'] = this.inputData;

    return data;
  }
}
