import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../../../../../../utils/constants/colors.dart';

/// Web-only webcam capture. Opens a dialog with a live camera preview and a
/// Capture button; returns the captured JPEG bytes (or null if cancelled / no
/// camera / permission denied). The admin panel is a web build, so dart:html
/// and dart:ui_web are available.
int _viewSeq = 0;

Future<Uint8List?> captureFromCamera(BuildContext context) async {
  html.MediaStream? stream;
  try {
    stream = await html.window.navigator.mediaDevices
        ?.getUserMedia({'video': true, 'audio': false});
  } catch (_) {
    _toast(context, 'Camera unavailable or permission denied. Use Upload instead.');
    return null;
  }
  if (stream == null) {
    _toast(context, 'No camera found. Use Upload instead.');
    return null;
  }

  final video = html.VideoElement()
    ..autoplay = true
    ..muted = true
    ..setAttribute('playsinline', 'true')
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.objectFit = 'cover';
  video.srcObject = stream;

  final viewType = 'brandshoot-cam-${_viewSeq++}';
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) => video);

  Uint8List? result;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Take a photo of the product'),
      content: SizedBox(
        width: 380,
        height: 320,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: HtmlElementView(viewType: viewType),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
          onPressed: () {
            try {
              final w = video.videoWidth;
              final h = video.videoHeight;
              if (w == 0 || h == 0) return;
              final canvas = html.CanvasElement(width: w, height: h);
              canvas.context2D.drawImage(video, 0, 0);
              final dataUrl = canvas.toDataUrl('image/jpeg', 0.92);
              result = base64Decode(dataUrl.split(',').last);
            } catch (_) {}
            Navigator.pop(ctx);
          },
          icon: const Icon(Icons.camera_alt, color: Colors.white),
          label: const Text('Capture', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  // Always release the camera.
  for (final track in stream.getTracks()) {
    track.stop();
  }
  return result;
}

void _toast(BuildContext context, String msg) {
  ScaffoldMessenger.maybeOf(context)
      ?.showSnackBar(SnackBar(content: Text(msg)));
}
