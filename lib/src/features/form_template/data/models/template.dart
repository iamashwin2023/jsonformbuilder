class TemplateRequestModel {
  String? name;
  String? templateData;

  TemplateRequestModel({this.name, this.templateData});

  TemplateRequestModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    templateData = json['templateData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['templateData'] = this.templateData;
    return data;
  }
}

class TemplateResponseModel {
  int? id;
  String? name;
  String? templateData;

  TemplateResponseModel({this.name, this.templateData});

  TemplateResponseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    templateData = json['templateData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['templateData'] = this.templateData;
    return data;
  }
}
