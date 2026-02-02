import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<void> compartilharPdf({
    required File pdfFile,
    required String mensagem,
  }) async {
    await Share.shareXFiles(
      [XFile(pdfFile.path)],
      text: mensagem,
    );
  }
}
