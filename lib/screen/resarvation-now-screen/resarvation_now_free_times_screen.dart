import 'dart:convert';

import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../config/themes/bloc_theme.dart';
import '../../contants/application_color.dart';
import '../../core/constants/url/randevu_al_url_constants.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/custom_confirmation_dialog_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';
import '../../core/widgets/warning_dialog_widget.dart';

const String _kHizliRandevuLog = '[HizliRandevu]';
const String _kAddResSuccess = 'true';
const String _kAddResGenericFail =
    'Randevu oluşturulamadı. Lütfen tekrar deneyiniz.';

/// API `output` bool / int / string dönebiliyor; UI başarı için yalnızca [_kAddResSuccess] bekleniyor.
String _normalizeAddReservationOutput(dynamic output) {
  if (output == null) return _kAddResGenericFail;
  if (output is bool) {
    return output ? _kAddResSuccess : _kAddResGenericFail;
  }
  if (output is num) {
    if (output == 1) return _kAddResSuccess;
    if (output == 0) return _kAddResGenericFail;
    return _kAddResGenericFail;
  }
  if (output is String) {
    final t = output.trim();
    if (t.isEmpty) return _kAddResGenericFail;
    final lower = t.toLowerCase();
    if (lower == 'true' || lower == '1') return _kAddResSuccess;
    if (lower == 'false' || lower == '0') return _kAddResGenericFail;
    return t;
  }
  return _kAddResGenericFail;
}

/// Saat karşılaştırması (10:15 / 10:15:00 uyumu).
String _normalizeTimeKey(String raw) {
  final t = raw.trim();
  if (t.length >= 8) return t.substring(0, 5);
  return t;
}

int? _timeToMinutes(String raw) {
  final key = _normalizeTimeKey(raw);
  final parts = key.split(':');
  if (parts.length < 2) return null;
  final h = int.tryParse(parts[0].trim());
  final m = int.tryParse(parts[1].trim());
  if (h == null || m == null) return null;
  return h * 60 + m;
}

int _compareTimeStrings(String a, String b) {
  final ma = _timeToMinutes(a);
  final mb = _timeToMinutes(b);
  if (ma != null && mb != null) return ma.compareTo(mb);
  return a.compareTo(b);
}

List<String> _stringListFromJson(dynamic v) {
  if (v == null) return [];
  if (v is List) {
    return v
        .map((e) => e.toString().trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
  return [];
}

class _HizliRandevuSlot {
  final String time;
  final bool available;

  const _HizliRandevuSlot({required this.time, required this.available});
}

class ResarvationNowFreeTimes extends StatefulWidget {
  final String id;
  final String dayNumber;
  final String day;
  final String planName;
  final String date;
  final String employeeName;
  const ResarvationNowFreeTimes(
      {Key? key,
      required this.id,
      required this.dayNumber,
      required this.day,
      required this.planName,
      required this.date,
      required this.employeeName})
      : super(key: key);

  @override
  State<ResarvationNowFreeTimes> createState() =>
      _ResarvationNowFreeTimesState();
}

class _ResarvationNowFreeTimesState extends State<ResarvationNowFreeTimes> {
  Future<List<_HizliRandevuSlot>> fetchScheduleSlots() async {
    final List<_HizliRandevuSlot> slots = [];
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final resarvationUrl =
          RandevuAlUrlConstants.getServiceNowPlanGetFreeTimesForResarvationUrl(
              externalApplicationConfig!.onlineReservation,
              widget.dayNumber,
              widget.id);
      final String token = await JwtStorageService.getToken() as String;
      print('$_kHizliRandevuLog GET boş saatler url=$resarvationUrl');
      var response = await RequestUtil.get(resarvationUrl, token: token);
      if (response == null) {
        print('$_kHizliRandevuLog boş saatler: HTTP yanıt null');
        return slots;
      }
      print(
          '$_kHizliRandevuLog boş saatler: status=${response.statusCode} body=${response.body}');
      final decoded = json.decode(response.body);
      final output = decoded['output'];
      print(
          '$_kHizliRandevuLog boş saatler: output runtimeType=${output.runtimeType}');
      if (output is Map) {
        print(
            '$_kHizliRandevuLog boş saatler: output keys=[${output.keys.join(",")}]');
      }
      if (output is! Map) {
        print(
            '$_kHizliRandevuLog boş saatler: output Map değil, avilable_times okunamadı');
        return slots;
      }
      final body = Map<String, dynamic>.from(output);
      final rawSlots = body['avilable_times'];
      print(
          '$_kHizliRandevuLog boş saatler: avilable_times=$rawSlots (${rawSlots.runtimeType})');
      if (rawSlots == null || rawSlots is! List) {
        print(
            '$_kHizliRandevuLog boş saatler: avilable_times yok veya List değil');
        return slots;
      }
      final freeTimes = List.castFrom<dynamic, String>(rawSlots);
      final busyRaw = _stringListFromJson(body['busy_times']);
      print(
          '$_kHizliRandevuLog boş saatler: busy_times=$busyRaw (${busyRaw.length} adet)');

      final freeKeys = freeTimes.map(_normalizeTimeKey).toSet();
      final busyOnly = busyRaw
          .where((t) => !freeKeys.contains(_normalizeTimeKey(t)))
          .toList()
        ..sort(_compareTimeStrings);
      final freeSorted = List<String>.from(freeTimes)..sort(_compareTimeStrings);

      for (final t in freeSorted) {
        slots.add(_HizliRandevuSlot(time: t, available: true));
      }
      for (final t in busyOnly) {
        slots.add(_HizliRandevuSlot(time: t, available: false));
      }

      print(
          '$_kHizliRandevuLog liste: müsait=${freeSorted.length} altta dolu=${busyOnly.length}');
    } catch (e, st) {
      print('$_kHizliRandevuLog boş saatler: hata $e');
      print('$_kHizliRandevuLog boş saatler: stack $st');
    }
    return slots;
  }

  Future<String> addResarvation(String time) async {
    String result = _kAddResSuccess;
    final payload = {
      "service_now_plan_id": widget.id,
      "plan_date": widget.date,
      "plan_time": time,
    };
    print('$_kHizliRandevuLog addResarvation başladı payload=$payload');
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final resarvationUrl =
          RandevuAlUrlConstants.getAddServiceNowPlanAddResarvationUrl(
              externalApplicationConfig!.onlineReservation);
      print('$_kHizliRandevuLog POST url=$resarvationUrl');

      final String token = await JwtStorageService.getToken() as String;

      var response = await RequestUtil.post(resarvationUrl,
          body: payload, token: token);

      if (response == null) {
        print(
            '$_kHizliRandevuLog POST yanıt null (ağ/zaman aşımı veya RequestUtil)');
        result = _normalizeAddReservationOutput(null);
        print('$_kHizliRandevuLog normalize sonrası result="$result"');
        return result;
      }

      print(
          '$_kHizliRandevuLog statusCode=${response.statusCode} body=${response.body}');

      final decoded = json.decode(response.body);
      print(
          '$_kHizliRandevuLog json decoded type=${decoded.runtimeType} value=$decoded');

      if (decoded is Map) {
        print(
            '$_kHizliRandevuLog map keys=${decoded.keys.join(",")} output=${decoded["output"]} outputType=${decoded["output"]?.runtimeType}');
        if (decoded.containsKey('extras')) {
          print('$_kHizliRandevuLog extras=${decoded["extras"]}');
        }
      } else {
        print(
            '$_kHizliRandevuLog uyarı: kök JSON Map değil, output okunamayabilir');
      }

      final rawOutput = decoded is Map ? decoded['output'] : null;
      result = _normalizeAddReservationOutput(rawOutput);
      print(
          '$_kHizliRandevuLog ham output=$rawOutput (${rawOutput?.runtimeType}) -> ui="$result"');
    } catch (e, st) {
      print('$_kHizliRandevuLog catch: $e');
      print('$_kHizliRandevuLog stack: $st');
      result = _normalizeAddReservationOutput(null);
    }
    print('$_kHizliRandevuLog addResarvation bitti return="$result"');
    return result;
  }

  @override
  void initState() {
    initializeDateFormatting();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBarWidget(
        title: "Hızlı Randevu Oluştur",
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(
                top: 20.0, bottom: 10.0, right: 20, left: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 2,
                    blurStyle: BlurStyle.outer,
                    color: ApplicationColor.primaryText,
                    offset: Offset.zero,
                    spreadRadius: 1,
                  )
                ],
                borderRadius: BorderRadius.all(Radius.circular(20))),
            width: MediaQuery.sizeOf(context).width,
            height: 55,
            child: Row(
              children: [
                Expanded(
                    flex: 4,
                    child: Container(
                      margin: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 5),
                      width: MediaQuery.sizeOf(context).width,
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.day + " - " + widget.employeeName,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow:
                                        TextOverflow.ellipsis, // burası önemli
                                    style: TextStyle(
                                      color: ApplicationColor.fourthText,
                                      fontFamily: "Inter",
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<_HizliRandevuSlot>>(
              future: fetchScheduleSlots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingIndicatorWidget());
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return buildPosts(snapshot.data!);
                } else {
                  return const Center(child: NoDataTextWidget());
                }
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        tab: NavTab.home,
      ),
    );
  }

  Widget buildPosts(List<_HizliRandevuSlot> memberExtract) {
    final muted = ApplicationColor.fourthText.withOpacity(0.45);

    return ListView.builder(
      itemCount: memberExtract.length,
      itemBuilder: (context, index) {
        final slot = memberExtract[index];
        final data = slot.time;

        Future<void> onBookTap() async {
          var message = widget.employeeName +
              "\n" +
              widget.planName +
              " \n " +
              widget.day +
              " - " +
              data +
              " saatine randevu oluşturmak istiyor musunuz ?";
          var query = await customConfirmationDialog(
            context,
            message: message,
            svgPath: BlocTheme.theme.attentionSvgPath,
          );
          if (query == true) {
            var result = await addResarvation(data);
            print(
                '$_kHizliRandevuLog UI: onay sonrası result="$result" başarı=${result == _kAddResSuccess}');
            if (result != _kAddResSuccess) {
              var message = result.isNotEmpty
                  ? result
                  : 'Randevu oluşturulurken bir hata oluştu, lütfen daha sonra tekrar deneyiniz.';
              warningDialog(
                context,
                message: message,
                path: BlocTheme.theme.errorSvgPath,
              );
            } else {
              warningDialog(
                context,
                message:
                    "Randevu başarıyla oluşturuldu, randevularım sayfasından görüntüleyebilirsiniz.",
              );
              setState(() {});
            }
          }
        }

        final row = Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  spreadRadius: 1,
                  color: Color.fromARGB(
                    1,
                    249,
                    250,
                    251,
                  ))
            ],
            color: ApplicationColor.primaryBoxBackground,
            border: Border.all(color: Color.fromARGB(1, 249, 250, 251)),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          margin: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
          width: MediaQuery.sizeOf(context).width,
          height: 60,
          child: Row(
            children: [
              Expanded(
                  flex: 6,
                  child: Container(
                    margin: EdgeInsetsDirectional.fromSTEB(20, 5, 10, 5),
                    width: MediaQuery.sizeOf(context).width,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                textAlign: TextAlign.left,
                                widget.planName,
                                maxLines: 3,
                                softWrap: true,
                                style: TextStyle(
                                    color: ApplicationColor.fourthText,
                                    fontFamily: "Inter",
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16),
                              ))
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                textAlign: TextAlign.left,
                                slot.available
                                    ? "Saat : $data"
                                    : "Saat : $data (dolu)",
                                maxLines: 2,
                                softWrap: true,
                                style: TextStyle(
                                    color: slot.available
                                        ? ApplicationColor.fourthText
                                        : muted,
                                    fontFamily: "Inter",
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    decoration: slot.available
                                        ? TextDecoration.none
                                        : TextDecoration.lineThrough,
                                    decorationColor: muted,
                                  ),
                              ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsetsDirectional.fromSTEB(20, 5, 10, 5),
                  width: MediaQuery.sizeOf(context).width,
                  child: Icon(
                    slot.available
                        ? Icons.chevron_right_outlined
                        : Icons.schedule_outlined,
                    color: slot.available
                        ? ApplicationColor.fourthText
                        : muted,
                    size: slot.available ? 36.0 : 24.0,
                    semanticLabel:
                        'Text to announce in accessibility modes',
                  ),
                ),
              ),
            ],
          ),
        );

        if (!slot.available) {
          return row;
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onBookTap,
            child: row,
          ),
        );
      },
    );
  }
}
