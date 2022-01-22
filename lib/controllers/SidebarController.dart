import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:http/http.dart' show get;
import 'package:seamlink/constants/enum.dart';
import 'package:seamlink/constants/strings.dart';
import 'package:seamlink/controllers/UserController.dart';
import 'package:seamlink/models/result.dart';
import 'package:seamlink/services/client.dart';

class SidebarController extends GetxController {
  var userAvatar = Uint8List(0).obs;
  var selectedType = NoteType.ALL.obs;
  var labels = [].obs;
  var labelIndex = (-2).obs;
  var editMode = false.obs;

  Future refreshLabels() async {
    Result result =
        await Client.getLabels(Get.find<UserController>().username.value);
    if (result.success) {
      labels.value = result.message;
    }
    if (userAvatar.value.length == 0)
      try {
        final String url =
            '$avatarApi/${Get.find<UserController>().username}.svg';
        final response = await get(Uri.parse(url));
        userAvatar.value = response.bodyBytes;
      } catch (e) {}
  }

  @override
  void onInit() async {
    super.onInit();
  }
}
