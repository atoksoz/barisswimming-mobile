import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialIcon extends StatelessWidget {
  final String url;
  final String assetPath;
  final double width;
  final double height;

  const SocialIcon({
    Key? key,
    required this.url,
    required this.assetPath,
    required this.width,
    required this.height,
  }) : super(key: key);

  void _launchIfNotEmpty(BuildContext context) async {
    try {
      if (url.isNotEmpty) {
        final uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Failed to open URL: $url — $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchIfNotEmpty(context),
      child: SvgPicture.asset(
        assetPath,
        width: 44,
        height: 44,
      ),
    );
  }
}
