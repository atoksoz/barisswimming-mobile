import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/screen/panel/common/content/content_screen.dart';
import 'package:flutter/material.dart';

class ServiceRules extends StatelessWidget {
  const ServiceRules({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentScreen(
      contentType: ContentType.serviceRules,
      appBarTitle: AppLabels.current.quickReservationRules,
    );
  }
}
