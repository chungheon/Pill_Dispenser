import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/screens/scheduler_page.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScanPage extends StatefulWidget {
  QrScanPage({
    Key? key,
    this.patientData,
  }) : super(key: key);

  final Map<String, dynamic>? patientData;
  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  Barcode? result;

  QRViewController? controller;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.resumeCamera();
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
        appBar: const StandardAppBar().appBar(),
        child: Column(
          children: [
            const SizedBox(height: 15.0),
            Expanded(
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (result?.code != null) {
                  String code = result!.code!;
                  List<String?> values = code.split("|");
                  //Assume order->name|amt|dosage|type
                  for (int i = values.length; i < 4; i++) {
                    values.add(null.toString());
                  }
                  Get.off(() => SchedulerPage(
                        medName: values[0],
                        pillsRec: int.tryParse(values[1] ?? ''),
                        dosageRec: int.tryParse(values[2] ?? ''),
                        typeRec: int.tryParse(values[3] ?? ''),
                        patientData: widget.patientData,
                      ));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(20.0),
                color: Constants.primary,
                alignment: Alignment.center,
                child: Text(
                  result?.code ?? 'Scan a QR Code to begin',
                  style:
                      const TextStyle(fontSize: 20.0, color: Constants.white),
                ),
              ),
            ),
          ],
        ));
  }
}
