import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:qr_flutter/qr_flutter.dart';

class ShareScreenshotWidget extends StatelessWidget {
  final Widget content;
  final String shareUrl;
  final String baseUrl;

  const ShareScreenshotWidget({
    super.key,
    required this.content,
    required this.shareUrl,
    required this.baseUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cupertino.CupertinoColors.systemGroupedBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: material.Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: material.Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                QrImageView(
                  data: shareUrl,
                  size: 80,
                  backgroundColor: material.Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const material.Text(
                        '扫码打开当前比价',
                        style: material.TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: material.Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      material.SelectableText(
                        baseUrl,
                        style: const material.TextStyle(
                          color: cupertino.CupertinoColors.activeBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        toolbarOptions: material.ToolbarOptions(copy: true),
                        showCursor: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          content,
        ],
      ),
    );
  }
}
