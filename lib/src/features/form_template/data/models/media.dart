class MediaRequestModel {
  String? mediaFile;
  String? title;
  String? description;
  String? mediaType;
  String? fileType;
  int? templateDataId;

  MediaRequestModel(
      {this.mediaFile,
      this.title,
      this.description,
      this.mediaType,
      this.fileType,
      this.templateDataId});

  MediaRequestModel.fromJson(Map<String, dynamic> json) {
    mediaFile = json['mediaFile'];
    title = json['title'];
    description = json['description'];
    mediaType = json['mediaType'];
    fileType = json['fileType'];
    templateDataId = json['templateDataId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mediaFile'] = this.mediaFile;
    data['title'] = this.title;
    data['description'] = this.description;
    data['mediaType'] = this.mediaType;
    data['fileType'] = this.fileType;
    data['templateDataId'] = this.templateDataId;
    return data;
  }
}

class MediaResponseModel {
  String? guid;
  String? mediaFile;
  String? title;
  String? description;
  String? mediaType;
  String? fileType;
  int? templateDataId;

  MediaResponseModel(
      {this.guid,
      this.mediaFile,
      this.title,
      this.description,
      this.mediaType,
      this.fileType,
      this.templateDataId});

  MediaResponseModel.fromJson(Map<String, dynamic> json) {
    guid = json['guid'];
    mediaFile = json['mediaFile'];
    title = json['title'];
    description = json['description'];
    mediaType = json['mediaType'];
    fileType = json['fileType'];
    templateDataId = json['templateDataId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['guid'] = this.guid;
    data['mediaFile'] = this.mediaFile;
    data['title'] = this.title;
    data['description'] = this.description;
    data['mediaType'] = this.mediaType;
    data['fileType'] = this.fileType;
    data['templateDataId'] = this.templateDataId;
    return data;
  }
}
