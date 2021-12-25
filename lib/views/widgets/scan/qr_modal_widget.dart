import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import '../../../controllers/stores/user_store.dart';
import '../../../controllers/stores/filter_store.dart';

import '../../../models/database/link_model.dart';

class QrModalWidget extends StatefulWidget {
  const QrModalWidget({
    Key? key,
    required this.url,
    required this.resumeCamera,
  }) : super(key: key);

  final String url;
  final Future<void> Function() resumeCamera;

  @override
  State<QrModalWidget> createState() => _QrModalWidgetState();
}

class _QrModalWidgetState extends State<QrModalWidget> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _closeQrModalWidget(BuildContext context) async {
    await widget.resumeCamera();
    Navigator.of(context).pop();
  }

  Future<void> _launchUrl(BuildContext context) async {
    final bool canLaunchUrl = await canLaunch(widget.url);
    if (canLaunchUrl) {
      launch(widget.url);
    } else {
      _closeQrModalWidget(context);
    }
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
      _closeQrModalWidget(context);
    } else {
      _closeQrModalWidget(context);
    }
  }

  Future<void> _copyUrlToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: widget.url)).then((_) {
      _closeQrModalWidget(context);
    });
  }

  Future<void> _addLinkIntoDatabase(BuildContext context) async {
    final UserStore userStore = GetIt.I.get<UserStore>();
    final FilterStore filterStore = GetIt.I.get<FilterStore>();
    final String? userUID = userStore.user.id;
    final String filter = filterStore.filter;

    if (userUID == null) return;

    final DatabaseReference database = FirebaseDatabase.instance.reference();

    final String datetime =
        DateFormat('dd-MM-yyyy-HH:mm:ss').format(DateTime.now());
    final String date = DateFormat('dd/MM/yyyy').format(DateTime.now());

    final LinkModel newLink = LinkModel(
      title: 'New Link',
      url: widget.url,
      date: date,
      datetime: datetime,
    );

    await database
        .child('users')
        .child(userUID)
        .child('filters')
        .child(filter)
        .set({'filter': filter});

    await database
        .child('users')
        .child(userUID)
        .child('links')
        .child(filter)
        .child(datetime)
        .set({
      'title': newLink.title,
      'url': newLink.url,
      'date': newLink.date,
      'datetime': newLink.datetime,
    }).then((_) => _closeQrModalWidget(context));
  }

  Future<void> _resumeCamera() async {
    await widget.resumeCamera();
  }

  @override
  void dispose() {
    _resumeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 460,
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
                onPressed: () => _closeQrModalWidget(context),
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              IconButton(
                onPressed: () => _shareQrCode(context),
                icon: const Icon(
                  Icons.share,
                  color: Color(0xFF9E9E9E),
                ),
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
                data: widget.url,
                size: 210,
                backgroundColor: const Color(0xFFFFFFFF),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <TextButton>[
                    TextButton(
                      onPressed: () => _launchUrl(context),
                      child: Row(
                        children: const <Widget>[
                          Icon(
                            Icons.open_in_new,
                            color: Color(0xFF9E9E9E),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Open Link',
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _saveQrCode(context),
                      child: Row(
                        children: const <Widget>[
                          Icon(
                            Icons.photo_library,
                            color: Color(0xFF9E9E9E),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Save Link',
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <TextButton>[
                    TextButton(
                      onPressed: () => _copyUrlToClipboard(context),
                      child: Row(
                        children: const <Widget>[
                          Icon(
                            Icons.copy,
                            color: Color(0xFF9E9E9E),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Copy Link',
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _addLinkIntoDatabase(context),
                      child: Row(
                        children: const <Widget>[
                          Icon(
                            Icons.add,
                            color: Color(0xFF9E9E9E),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Add Link',
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
