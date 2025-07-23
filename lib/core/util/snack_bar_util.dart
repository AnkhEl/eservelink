import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class SnackBarUtils {
  static SnackBar createAwesome({
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    return SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );
  }

  ///
  /// A SnackBar widget denoting a success Message
  ///
  static SnackBar success({required String title, required String message}) {
    return createAwesome(
      title: title,
      message: message,
      contentType: ContentType.success,
    );
  }

  ///
  /// A SnackBar widget denoting a failure/error Message
  ///
  static SnackBar error({required String title, required String message}) {
    return createAwesome(
      title: title,
      message: message,
      contentType: ContentType.failure,
    );
  }

  ///
  /// A SnackBar widget denoting a warning Message
  ///
  static SnackBar warning({required String title, required String message}) {
    return createAwesome(
      title: title,
      message: message,
      contentType: ContentType.warning,
    );
  }

  ///
  /// A SnackBar widget denoting an info Message
  ///
  static SnackBar info({required String title, required String message}) {
    return createAwesome(
      title: title,
      message: message,
      contentType: ContentType.help,
    );
  }
}
