import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/widgets/app_snack_bar.dart';

class JoinGroupScannerPage extends StatefulWidget {
  const JoinGroupScannerPage({super.key});

  @override
  State<JoinGroupScannerPage> createState() => _JoinGroupScannerPageState();
}

class _JoinGroupScannerPageState extends State<JoinGroupScannerPage> {
  bool _didScan = false;

  void _handleDetection(BarcodeCapture capture) {
    if (_didScan) {
      return;
    }

    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    final code = _inviteCodeFrom(rawValue);
    if (code == null) {
      showAppSnackBar(
        context: context,
        message: context.l10n.joinGroupInvalidQr,
      );
      return;
    }

    _didScan = true;
    context.pop(code);
  }

  String? _inviteCodeFrom(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    final queryCode = uri?.queryParameters['code'];
    final code = queryCode == null || queryCode.trim().isEmpty
        ? _codeFromInviteText(trimmed) ?? trimmed
        : queryCode.trim();

    if (!RegExp(r'^[A-Za-z0-9]{4,24}$').hasMatch(code)) {
      return null;
    }

    return code.toUpperCase();
  }

  String? _codeFromInviteText(String value) {
    final match = RegExp(
      r'(?:code|invite|код)[^A-Za-z0-9]*([A-Za-z0-9]{4,24})',
      caseSensitive: false,
    ).firstMatch(value);

    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.joinGroupScanTitle),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _handleDetection,
            errorBuilder: (context, error) {
              return Center(child: Text(l10n.joinGroupCameraError));
            },
          ),
          SafeArea(
            minimum: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(l10n.joinGroupScanBody)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
