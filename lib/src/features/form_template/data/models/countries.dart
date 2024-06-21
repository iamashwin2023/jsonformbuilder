class CountriesModel {
  int? id;
  String? name;
  int? displayOrder;
  bool? isActive;

  CountriesModel({this.id, this.name, this.displayOrder, this.isActive});

  CountriesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    displayOrder = json['displayOrder'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['displayOrder'] = this.displayOrder;
    data['isActive'] = this.isActive;
    return data;
  }
}
