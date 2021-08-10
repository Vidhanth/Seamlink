import 'package:get/get.dart';
import 'package:seamlink/constants/enum.dart';
import 'package:seamlink/controllers/UserController.dart';
import 'package:seamlink/models/result.dart';
import 'package:seamlink/services/client.dart';

class SidebarController extends GetxController {
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
  }

  @override
  void onInit() async {
    await refreshLabels();
    super.onInit();
  }
}
