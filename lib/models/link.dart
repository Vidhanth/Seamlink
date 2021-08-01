import 'dart:convert';

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
  });

  String uid;
  String url;
  String title;
  DateTime timestamp;
  String user;
  List<String> labels;
  int colorIndex;
  bool autotitle;
  String? subtitle;
  String? message;

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        uid: json["uid"],
        url: json["url"],
        title: json["title"],
        timestamp: DateTime.parse(json["timestamp"]),
        user: json["user"],
        labels: List<String>.from(json["labels"].map((x) => x)),
        colorIndex: json["color"],
        autotitle: json["autotitle"],
      );

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
