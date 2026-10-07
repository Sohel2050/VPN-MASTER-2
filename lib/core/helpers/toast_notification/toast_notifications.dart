import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:timeago/timeago.dart' as timeago;
import 'package:toastification/toastification.dart';
import 'package:winsguard/config/routes/app_routes.dart';

class ToastNotifications{
  const ToastNotifications._();


  static void showSuccessToast(String message) {
    toastification.show(
      overlayState: navigatorKey.currentState?.overlay,
      type: ToastificationType.success,
      style: ToastificationStyle.minimal,
      title: Text('Success'),
      description: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: Duration(seconds: 3),
      icon: Icon(Icons.check_circle, color: Colors.green),
    );
  }


  static void showErrorToast({required String title, required String message}) {
    toastification.show(
      overlayState: navigatorKey.currentState?.overlay,
      type: ToastificationType.error,
      style: ToastificationStyle.minimal,
      title: Text(title),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      icon: const Icon(Icons.error,),
    );
  }


  static void showApiErrorToast(int statusCode, String message) {
    toastification.show(
      overlayState: navigatorKey.currentState?.overlay,
      type: ToastificationType.error,
      style: ToastificationStyle.minimal,
      title: Text("Status Code: $statusCode"),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      icon: const Icon(Icons.error,),
    );
  }


}