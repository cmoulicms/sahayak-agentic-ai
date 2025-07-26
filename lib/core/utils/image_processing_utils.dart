import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageProcessingUtils {
  static Future<Uint8List> compressImage(
    Uint8List imageBytes, {
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    final codec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: maxWidth,
      targetHeight: maxHeight,
    );
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  static Future<String> saveImageToFile(
      Uint8List imageBytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(imageBytes);
    return file.path;
  }

  static Future<Uint8List> captureWidgetAsImage(GlobalKey key) async {
    final RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static Future<String> svgToPng(String svgString,
      {double? width, double? height}) async {
    final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final size = Size(width ?? 400, height ?? 300);
    canvas.scale(size.width / pictureInfo.size.width,
        size.height / pictureInfo.size.height);
    canvas.drawPicture(pictureInfo.picture);

    final picture = recorder.endRecording();
    final image =
        await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    final directory = await getTemporaryDirectory();
    final file = File(
        '${directory.path}/svg_converted_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(byteData!.buffer.asUint8List());

    return file.path;
  }
}
