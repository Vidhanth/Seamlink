import 'dart:convert';

import 'package:seamlink/constants/enum.dart';
import 'package:seamlink/services/extensions.dart';

List<Link> linkFromJson(json) => List<Link>.from(json.map((x) {
      return Link.fromJson(x);
    }));

String linkToJson(List<Link> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Link {
  Link({
    required this.uid,
    required this.url,
    required this.title,
    required this.timestamp,
    required this.user,
    required this.labels,
    required this.colorIndex,
    required this.autotitle,
    this.subtitle,
    this.message,
    this.thumbnail,
    this.type,
  });

  String uid;
  String url;
  String title;
  DateTime timestamp;
  String user;
  List<int> labels;
  int colorIndex;
  bool autotitle;
  String? subtitle;
  String? message;
  String? thumbnail;
  NoteType? type;

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      uid: json["uid"],
      url: json["url"],
      title: json["title"],
      timestamp: DateTime.parse(json["timestamp"]),
      user: json["user"],
      labels: List<int>.from(json["labels"].map((x) => x)),
      colorIndex: json["color"],
      autotitle: json["autotitle"],
      type: json["url"].toString().isValidLink ? NoteType.LINK : NoteType.NOTE,
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "url": url,
        "title": title,
        "timestamp": timestamp.toIso8601String(),
        "user": user,
        "labels": List<dynamic>.from(labels.map((x) => x)),
        "color": colorIndex,
        "autotitle": autotitle,
      };

  bool contains(String query) {
    return url.toLowerCase().contains(query) ||
        title.toLowerCase().contains(query) ||
        (subtitle?.toLowerCase().contains(query) ?? false) ||
        (message?.toLowerCase().contains(query) ?? false);
  }
}
