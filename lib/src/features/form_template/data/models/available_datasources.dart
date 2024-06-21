class AvailableDataSourcesModel {
  int? id;
  String? name;
  String? code;
  bool? isActive;

  AvailableDataSourcesModel({this.id, this.name, this.code, this.isActive});

  AvailableDataSourcesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['code'] = this.code;
    data['isActive'] = this.isActive;
    return data;
  }
}
