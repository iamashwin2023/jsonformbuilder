class TemplateData {
  String? componentName;
  String? id;
  String? label;
  String? hint;
  String? datasource;
  bool? mandatory;
  String? sequenceNumber;

  TemplateData(
      {this.componentName,
      this.id,
      this.label,
      this.datasource,
      this.sequenceNumber,
      this.mandatory,
      this.hint});

  TemplateData.fromJson(Map<String, dynamic> json) {
    componentName = json['ComponentName'];
    id = json['Id'];
    label = json['Label'];
    datasource = json['DataSource'];
    sequenceNumber = json['SequenceNumber'];
    mandatory = json['Mandatory'];
    hint = json['Hint'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ComponentName'] = this.componentName;
    data['Id'] = this.id;
    data['Label'] = this.label;
    data['DataSource'] = this.datasource;
    data['SequenceNumber'] = this.sequenceNumber;
    data['Mandatory'] = this.mandatory;
    data['Hint'] = this.hint;

    return data;
  }
}

class TemplateDataEntry {
  String? componentName;
  String? id;
  String? label;
  String? hint;
  String? datasource;
  bool? mandatory;
  String? sequenceNumber;
  String? value;

  TemplateDataEntry(
      {this.componentName,
      this.id,
      this.label,
      this.datasource,
      this.sequenceNumber,
      this.mandatory,
      this.value,
      this.hint});

  TemplateDataEntry.fromJson(Map<String, dynamic> json) {
    componentName = json['ComponentName'];
    id = json['Id'];
    label = json['Label'];
    datasource = json['DataSource'];
    sequenceNumber = json['SequenceNumber'];
    mandatory = json['Mandatory'];
    value = json['Value'];
    hint = json['Hint'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ComponentName'] = this.componentName;
    data['Id'] = this.id;
    data['Label'] = this.label;
    data['DataSource'] = this.datasource;
    data['SequenceNumber'] = this.sequenceNumber;
    data['Mandatory'] = this.mandatory;
    data['Value'] = this.value;
    data['Hint'] = this.hint;

    return data;
  }
}
// class FileInfo {
//   String? name;
//   String? format;
//   String? type;

//   FileInfo({this.name, this.format, this.type});

//   FileInfo.fromJson(Map<String, dynamic> json) {
//     name = json['Name'];
//     format = json['Format'];
//     type = json['Type'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['Name'] = this.name;
//     data['Format'] = this.format;
//     data['Type'] = this.type;
//     return data;
//   }
// }
// class SavedTemplateData {
//   String? componentName;
//   String? id;
//   String? label;
//   String? value;

//   SavedTemplateData({this.componentName, this.id, this.label, this.value});

//   SavedTemplateData.fromJson(Map<String, dynamic> json) {
//     componentName = json['ComponentName'];
//     id = json['Id'];
//     label = json['Label'];
//     value = json['Value'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['ComponentName'] = this.componentName;
//     data['Id'] = this.id;
//     data['Label'] = this.label;
//     data['Value'] = this.value;
//     return data;
//   }
// }
