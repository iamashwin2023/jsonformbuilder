import 'dart:convert';

import 'package:flutter/material.dart';

class FormElement {
  final String type;
  final String? label;
  final String? hint;
  final String? datasource;
  final bool? mandatory;
  final String? key;
  late final int? sequenceNumber;

  FormElement({
    required this.type,
    this.label,
    this.hint,
    this.datasource,
    this.mandatory,
    this.key,
    this.sequenceNumber,
    //required this.panNumber,
    //required this.natureOfBusiness,
  });

  factory FormElement.fromJson(Map<String, dynamic> json) {
    return FormElement(
      type: json['type'],
      label: json['label'] as String?,
      hint: json['hint'] as String?,
      datasource: json['datasource'] as String?,
      mandatory: json['isMandatory'] as bool?,
      key: json['key'],
      //key:json['key'],
      sequenceNumber: json['sequenceNumber'] as int,
      //panNumber: json['panNumber'] as String?,
      //natureOfBusiness: json
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'label': label,
      'hint': hint,
      'datasource': datasource,
      'isMandatory': mandatory,
      'sequenceNumber': sequenceNumber,
      'key': key
      // 'panNumber':panNumber,
    };
  }
}
