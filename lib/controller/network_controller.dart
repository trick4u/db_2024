import 'dart:async';



import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:tushar_db/app_routes.dart';
import 'package:tushar_db/projectPages/main_screen.dart';


import '../services/toast_util.dart';

class NetworkController extends GetxController {
  RxBool isOnline = true.obs;
  StreamSubscription? connectionStream;
  bool isInitialCheck = true;
  // Add a debouncer to prevent rapid state changes
  Timer? _navigationDebouncer;

  @override
  void onInit() {
    super.onInit();
    checkInitialConnection();
    listenToConnectionChanges();
  }

  Future<void> checkInitialConnection() async {
    isOnline.value = await InternetConnection().hasInternetAccess;
    if (!isOnline.value) {
      Get.offNamedUntil(AppRoutes.NETWORK, (route) => false);
    }
    isInitialCheck = false;
  }

  void listenToConnectionChanges() {
    connectionStream = InternetConnection().onStatusChange.listen((event) async {
      switch (event) {
        case InternetStatus.connected:
          if (!isInitialCheck && !isOnline.value) {
            isOnline.value = true;
            // Cancel any pending navigation
            _navigationDebouncer?.cancel();
            // Add a small delay before navigation to allow UI to update
            _navigationDebouncer = Timer(const Duration(milliseconds: 300), () {
              if (isOnline.value) {
                // Only navigate if we're still online after the delay
                if (!Get.currentRoute.contains('MainScreen')) {
                  Get.off(
                    () => MainScreen(),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 500),
                  );
                }
              }
            });
          }
          break;
        case InternetStatus.disconnected:
          isOnline.value = false;
          if (!isInitialCheck) {
            // Cancel any pending navigation
            _navigationDebouncer?.cancel();
            ToastUtil.showToast(
              'No Internet',
              'Please check your internet connection',
            );
            if (!Get.currentRoute.contains('NETWORK')) {
              Get.offNamedUntil(
                AppRoutes.NETWORK,
                (route) => false,
          
              );
            }
          }
          break;
      }
    });
  }

  Future<void> checkNetworkConnectivity() async {
    bool hasInternet = await InternetConnection().hasInternetAccess;
    isOnline.value = hasInternet;
    if (hasInternet) {
      navigateToMainScreen();
    } else {
      ToastUtil.showToast(
        'No Internet',
        'Please check your internet connection',
      );
    }
  }

  void navigateToMainScreen() {
    if (!Get.currentRoute.contains('MainScreen')) {
      Get.off(
        () => MainScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  void onClose() {
    _navigationDebouncer?.cancel();
    connectionStream?.cancel();
    super.onClose();
  }
}