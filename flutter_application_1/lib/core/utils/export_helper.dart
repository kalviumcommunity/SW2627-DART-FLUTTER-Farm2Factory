import 'export_helper_stub.dart'
    if (dart.library.html) 'export_helper_web.dart' as platform_export;

class ExportHelper {
  /// Initiates an instant file download on the client device (e.g. Chrome Downloads folder).
  static void downloadFile({
    required String filename,
    required String content,
  }) {
    platform_export.downloadCsvFile(filename, content);
  }
}
