import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class QrModalWidget extends StatelessWidget {
  QrModalWidget({Key? key, required this.url}) : super(key: key);

  final String url;
  final ScreenshotController _screenshotController = ScreenshotController();

  void _notifyUserWithSnackBar(
    BuildContext context,
    String message,
    int milliseconds,
  ) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          textAlign: TextAlign.justify,
        ),
        duration: Duration(milliseconds: milliseconds),
      ),
    );
  }

  Future<File?> _captureQrCodeImageToShare() async {
    final Uint8List? qrCodeImage = await _screenshotController.capture();

    if (qrCodeImage != null) {
      final Directory temporaryDirectory = await getTemporaryDirectory();
      final String temporaryPath = temporaryDirectory.path;
      final String captureTimestamp = DateTime.now().toString();
      final File imageFile = File('$temporaryPath/$captureTimestamp.png');
      imageFile.writeAsBytesSync(qrCodeImage);
      return imageFile;
    }
    return null;
  }

  Future<void> _shareQrCode(BuildContext context) async {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final File? qrCodeImage = await _captureQrCodeImageToShare();

    if (qrCodeImage != null) {
      await Share.shareFiles(
        [qrCodeImage.path],
        mimeTypes: ['image/png'],
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    }
  }

  Future<Uint8List?> _captureQrCodeImageToSave() async {
    final Uint8List? qrCodeImage = await _screenshotController.capture();
    return qrCodeImage;
  }

  Future<void> _saveQrCode(BuildContext context) async {
    final Uint8List? qrCodeImage = await _captureQrCodeImageToSave();
    final bool haveStoragePermission =
        await Permission.storage.request().isGranted;

    if (haveStoragePermission && qrCodeImage != null) {
      final String captureTimestamp = DateTime.now().toString();
      await ImageGallerySaver.saveImage(
        Uint8List.fromList(qrCodeImage),
        quality: 100,
        name: captureTimestamp,
      );
      _notifyUserWithSnackBar(
        context,
        'QR code saved in gallery!',
        2500,
      );
    } else {
      _notifyUserWithSnackBar(
        context,
        'Unable to save QR code! Have you given permission for storage?',
        3500,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <IconButton>[
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFF9E9E9E),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              IconButton(
                icon: const Icon(
                  Icons.share,
                  color: Color(0xFF9E9E9E),
                ),
                onPressed: () => _shareQrCode(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).indicatorColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Screenshot(
              controller: _screenshotController,
              child: QrImage(
                data: url,
                size: 210,
                backgroundColor: const Color(0xFFFFFFFF),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                child: const Text(
                  'SAVE TO GALLERY',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => _saveQrCode(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
