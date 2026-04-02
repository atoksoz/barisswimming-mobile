import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class SelectedAttachment {
  SelectedAttachment({
    required this.name,
    required this.path,
    required this.isImage,
  });

  final String name;
  final String path;
  final bool isImage;
}

class MeasurementInputFormWidget extends StatelessWidget {
  final TextEditingController weightController;
  final TextEditingController heightController;
  final TextEditingController chestController;
  final TextEditingController armController;
  final TextEditingController shoulderController;
  final TextEditingController waistController;
  final bool readOnly;
  final List<SelectedAttachment>? attachments;

  const MeasurementInputFormWidget({
    Key? key,
    required this.weightController,
    required this.heightController,
    required this.chestController,
    required this.armController,
    required this.shoulderController,
    required this.waistController,
    this.readOnly = false,
    this.attachments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BlocTheme.theme.defaultWhiteColor,
        border: Border.all(
          color: BlocTheme.theme.defaultGray300Color,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 0, top: 20, right: 10),
            child: SvgPicture.asset(
              BlocTheme.theme.bodySvgPath,
              width: 120,
              height: 240,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _buildInput(AppLabels.current.weight, weightController, readOnly, attachments),
                const SizedBox(height: 12),
                _buildInput(AppLabels.current.arm, armController, readOnly, attachments),
                const SizedBox(height: 12),
                _buildInput(AppLabels.current.shoulder, shoulderController, readOnly, attachments),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                _buildInput(AppLabels.current.height, heightController, readOnly, attachments),
                const SizedBox(height: 12),
                _buildInput(AppLabels.current.chest, chestController, readOnly, attachments),
                const SizedBox(height: 12),
                _buildInput(AppLabels.current.abdomen, waistController, readOnly, attachments),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    bool isReadOnly,
    List<SelectedAttachment>? attachments,
  ) {
    return TextFormField(
      readOnly: isReadOnly,
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      style: TextStyle(
        fontFamily: BlocTheme.theme.fontFamily,
        letterSpacing: 0,
      ),
      maxLength: isReadOnly ? 3 : null,
      maxLengthEnforcement: isReadOnly
          ? MaxLengthEnforcement.enforced
          : MaxLengthEnforcement.none,
      cursorColor: BlocTheme.theme.default900Color,
      validator: isReadOnly
          ? null
          : (value) {
              // Eğer görsel/dosya varsa alanlar zorunlu değil
              if (attachments != null && attachments!.isNotEmpty) {
                return null;
              }
              // Eğer görsel/dosya yoksa alanlar zorunlu
              if (value == null || value.trim().isEmpty) {
                return '$label ${AppLabels.current.fieldCannotBeEmpty}';
              }
              return null;
            },
    );
  }
}

