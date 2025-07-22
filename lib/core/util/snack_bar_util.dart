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

  // Convenience methods for common types
  static SnackBar success({required String title, required String message}) {
    return createAwesome(
      title: title,
      message: message,
      contentType: ContentType.success,
    );
  }

  static SnackBar error({required String title, required String message}) {
    return createAwesome(
      title: title,
      message: message,
      contentType: ContentType.failure,
    );
  }

  static SnackBar warning({required String title, required String message}) {
    return createAwesome(
      title: title,
      message: message,
      contentType: ContentType.warning,
    );
  }

  static SnackBar info({required String title, required String message}) {
    return createAwesome(
      title: title,
      message: message,
      contentType: ContentType.help,
    );
  }
}
