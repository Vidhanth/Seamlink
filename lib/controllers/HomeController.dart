import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seamlink/controllers/SidebarController.dart';
import 'package:seamlink/models/link.dart';
import 'package:seamlink/models/result.dart';
import 'package:seamlink/services/client.dart';
import 'package:seamlink/services/utils.dart';

class HomeController extends GetxController {
  var linksList = <Link>[].obs;
  var searchText = ''.obs;
  var isLoading = true.obs;
  var showSidebar = false.obs;

  void linkAdded(link, {String? uid}) {
    if (uid == null) {
      linksList.add(link);
    } else {
      int index = linksList.indexWhere((ele) => ele.uid == link.uid);
      linksList[index] = link;
    }
    linksList.sort((link1, link2) => compareLinksList(link1, link2));
  }

  Future<void> deleteLink(context, uid) async {
    Result result = await Client.deleteLink(uid);
    if (result.success) {
      linksList.removeWhere((link) => link.uid == result.message);
    } else
      showSnackBar(context, 'There was an error.', error: true);
  }

  void refreshLinks({String? sortBy, bool? ascending}) async {
    isLoading(true);
    Get.find<SidebarController>().refreshLabels();
    final list = await Client.fetchLinks(sortBy: sortBy, ascending: ascending);
    if (list is List<dynamic>) {
      var newList = linkFromJson(list);
      linksList.value = newList;
    } else {
      Get.showSnackbar(GetBar(
        title: "Connection error",
        message: "Please make sure you have internet connectivity.",
        backgroundColor: Colors.red,
        duration: 2.seconds,
      ));
    }
    isLoading(false);
  }
}
