class StateModel {
  int? id;
  String? name;
  int? countryId;
  bool? isActive;

  StateModel({this.id, this.name, this.countryId, this.isActive});

  StateModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    countryId = json['countryId'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['countryId'] = this.countryId;
    data['isActive'] = this.isActive;
    return data;
  }
}
