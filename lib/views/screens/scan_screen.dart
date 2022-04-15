import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../models/utils/constants.dart';

import '../widgets/scan/qr_modal_widget.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final GlobalKey qrViewKey = GlobalKey();

  final BannerAd _bannerAd = BannerAd(
    adUnitId: Constants.instance.bannerAdUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError loadAdError) async {
      await ad.dispose();
    }),
  );

  QRViewController? qrViewController;
  PermissionStatus cameraPermissionStatus = PermissionStatus.denied;

  void _onQRViewCreated(QRViewController qrViewController) {
    setState(() {
      this.qrViewController = qrViewController;
    });
    qrViewController.scannedDataStream.listen((Barcode barcode) async {
      if (barcode.code != null) {
        await qrViewController.pauseCamera();
        showModalBottomSheet(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          isScrollControlled: true,
          context: context,
          builder: (_) => QrModalWidget(
            url: barcode.code!,
            resumeCamera: qrViewController.resumeCamera,
          ),
        );
      }
    });
  }

  Future<void> _requestCameraPermission() async {
    await Permission.camera
        .request()
        .then((PermissionStatus permissionStatus) => {
              setState(() {
                cameraPermissionStatus = permissionStatus;
              })
            });
  }

  @override
  void initState() {
    super.initState();
    _bannerAd.load();

    final bool notHaveCameraPermission =
        cameraPermissionStatus != PermissionStatus.granted;
    if (notHaveCameraPermission) {
      _requestCameraPermission();
    }
  }

  @override
  void dispose() {
    qrViewController?.dispose();
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cameraPermissionStatus.isGranted) {
      return SafeArea(
        child: Stack(
          fit: StackFit.expand,
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            QRView(
              key: qrViewKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: const Color(0xFFFFFFFF),
              ),
            ),
            Positioned(
              child: SizedBox(
                child: AdWidget(ad: _bannerAd),
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
              ),
              top: 10,
            ),
          ],
        ),
      );
    } else {
      return SafeArea(
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: Center(
            child: SizedBox(
              width: 210,
              height: 50,
              child: ElevatedButton(
                child: const Text('Grant camera permission'),
                onPressed: _requestCameraPermission,
              ),
            ),
          ),
        ),
      );
    }
  }
}
