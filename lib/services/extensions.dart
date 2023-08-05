import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

extension d on Duration {
  String toDurationString() {
    String rawString = this.toString();
    rawString = rawString.split('.')[0];

    List<String> rawList = rawString.split(':');

    if (double.parse(rawList[0]) == 0) {
      rawList.removeAt(0);
    }

    String s = '';

    rawList.forEach((element) {
      if (s.isNotEmpty) {
        s += ":";
      }
      s += element;
    });

    return s;
  }
}

extension s on String {
  bool get isValidEmail => RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(this);

  bool get isValidPassword => this.isNotEmpty && this.length >= 6;
  bool get isValidLink {
    return (this.isNotEmpty &&
        (this.startsWith("https://") || this.startsWith("http://")) &&
        !this.contains(",") &&
        !this.contains(" ") &&
        !this.contains("|"));
  }

  bool get isYoutubeLink {
    return this.toLowerCase().contains('youtube.com/') || this.toLowerCase().contains('youtu.be/');
  }

  bool get isRedditLink {
    return this.toLowerCase().contains('reddit.com/') || this.toLowerCase().contains('redd.it/');
  }

  String formatTitle() {
    String title = this;
    title = title.replaceAll("&amp;", "&");
    title = title.replaceAll("&#39;", "'");
    title = title.replaceAll("&quot;", '"');
    return title;
  }

  String clamp({int limit = 60}) {
    return this.length > limit ? this.substring(0, limit) + "..." : this;
  }

  void copyToClipboard() {
    Clipboard.setData(new ClipboardData(text: this));
  }
}

extension dt on DateTime {
  String get displayString {
    DateTime date = DateTime.parse(this.toString());
    DateFormat formatter = DateFormat(DateFormat.YEAR_MONTH_DAY);
    DateFormat time = DateFormat(DateFormat.HOUR_MINUTE);
    return "${formatter.format(date)}  ${time.format(date)}";
  }
}
