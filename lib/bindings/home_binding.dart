import 'package:get/get.dart';

import '../api/api_client.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
