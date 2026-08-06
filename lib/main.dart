import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await [Permission.microphone, Permission.camera].request();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const LepidopteraApp());
}

class LepidopteraApp extends StatelessWidget {
  const LepidopteraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Night Flyers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF0C0A09)),
      home: const LepidopteraViewer(),
    );
  }
}

class LepidopteraViewer extends StatefulWidget {
  const LepidopteraViewer({super.key});

  @override
  State<LepidopteraViewer> createState() => _LepidopteraViewerState();
}

class _LepidopteraViewerState extends State<LepidopteraViewer> {
  String? _htmlPath;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final html = await rootBundle.loadString('assets/lepidoptera.html');
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/lepidoptera.html');
    await file.writeAsString(html);
    if (mounted) setState(() => _htmlPath = file.path);
  }

  @override
  Widget build(BuildContext context) {
    if (_htmlPath == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0C0A09),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD6D3D1)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0C0A09),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri.uri(Uri.file(_htmlPath!)),
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          allowFileAccessFromFileURLs: true,
          allowUniversalAccessFromFileURLs: true,
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: true,
          databaseEnabled: true,
          domStorageEnabled: true,
        ),
        onPermissionRequest: (_, request) async {
          return PermissionResponse(
            resources: request.resources,
            action: PermissionResponseAction.GRANT,
          );
        },
      ),
    );
  }
}
