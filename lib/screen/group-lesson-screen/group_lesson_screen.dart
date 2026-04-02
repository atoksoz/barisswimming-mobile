import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/data/model/group_lesson_resarvation_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../contants/application_color.dart';
import '../../core/services/resarvation_service.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/day_selector_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';
import '../../data/model/group_lesson_model.dart';
import '../package-screen/branch_package_history_detail_screen.dart';
import 'group_lesson_detail_screen.dart';

class GroupLesson extends StatefulWidget {
  const GroupLesson({Key? key}) : super(key: key);

  @override
  State<GroupLesson> createState() => _GroupLessonState();
}

class _GroupLessonState extends State<GroupLesson> {
  int selectedTab = 0;
  int selectedDay = 0;
  bool dateChanging = false;
  String dateRange = "";

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late Future<List<GroupLessonModel>> groupLessons;
  late Future<List<GroupLessonResarvationModel>> groupLessonResarvations;

  Future<void> changeDay(int dayNumber) async {
    if (dateChanging == false) {
      setState(() {
        dateChanging = true;
        selectedDay = dayNumber;
      });
    }
  }

  String _getSelectedDateString() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime targetDate = now.add(Duration(days: selectedDay - currentWeekday));
    return "${DateFormat('d MMMM yyyy', 'tr_TR').format(targetDate)} Grup Dersi Listesi";
  }

  @override
  void initState() {
    setState(() {
      DateTime now = DateTime.now();
      selectedDay = now.weekday;
      changeDay(selectedDay);

      DateTime nextWeek = now.add(Duration(days: 7));
      String startMonth = DateTime.now().month.toString();
      String endMonth = nextWeek.month.toString();
      dateRange = now.day.toString();
      if (startMonth == endMonth) {
        dateRange += " - " + nextWeek.day.toString();
        dateRange += " " + DateFormat.MMMM("tr").format(nextWeek);
      } else {
        dateRange += " " + DateFormat.MMMM("tr").format(now);
        dateRange += " - " +
            nextWeek.day.toString() +
            " " +
            DateFormat.MMMM("tr").format(nextWeek);
      }
      dateRange += " " + DateFormat.y("tr").format(nextWeek);
    });

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    groupLessons =
        ResarvationService.fetchGroupLessons(context, dayNumber: selectedDay);
    groupLessonResarvations =
        ResarvationService.fetchGroupLessonResarvations(context);
    return Scaffold(
      appBar: TopAppBarWidget(
        title: "Grup Dersleri",
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const BranchPackageHistoryDetailScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.info_outline,
              color: Color.fromARGB(255, 55, 80, 0),
              size: 36,
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(
                top: 10.0, bottom: 20.0, right: 20, left: 20),
            width: MediaQuery.sizeOf(context).width,
            height: 50,
            alignment: AlignmentDirectional.center,
            child: Row(children: [
              Expanded(
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedTab = 0;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: (selectedTab == 0
                                ? ApplicationColor.primary
                                : Colors.white),
                            border: Border.all(
                                color: (selectedTab == 1
                                    ? BlocTheme.theme.default900Color
                                    : Color.fromARGB(1, 249, 250, 251))),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        margin: EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                        alignment: Alignment.center,
                        child: Text(
                          "Randevu Oluştur",
                          style: TextStyle(
                              color: BlocTheme.theme.default900Color,
                              fontFamily: "Inter",
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600,
                              fontSize: 18),
                        ),
                      ))),
              Expanded(
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedTab = 1;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: (selectedTab == 1
                                ? ApplicationColor.primary
                                : Colors.white),
                            border: Border.all(
                                color: (selectedTab == 0
                                    ? BlocTheme.theme.default900Color
                                    : Color.fromARGB(1, 249, 250, 251))),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        margin: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        alignment: Alignment.center,
                        child: Text(
                          "Randevularım",
                          style: TextStyle(
                              color: BlocTheme.theme.default900Color,
                              fontFamily: "Inter",
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600,
                              fontSize: 18),
                        ),
                      ))),
            ]),
          ),
          if (selectedTab == 0) ...[
            Container(
              margin: const EdgeInsets.only(
                  top: 0.0, bottom: 10.0, right: 20, left: 20),
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
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              width: MediaQuery.sizeOf(context).width,
              height: 55,
              child: Row(
                children: [
                  Expanded(
                      flex: 4,
                      child: Container(
                        margin: EdgeInsetsDirectional.fromSTEB(10, 5, 0, 5),
                        width: MediaQuery.sizeOf(context).width,
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    textAlign: TextAlign.center,
                                    dateRange,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(
                                        color: BlocTheme.theme.default900Color,
                                        fontFamily: "Inter",
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18),
                                  ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10,
                  0), // sol, üst, sağ, alt (10 olan alt boşluğu 0 yaptık)
              child: DaySelector(
                selectedDay: selectedDay,
                onDayChanged: (day) {
                  setState(() {
                    selectedDay = day;
                  });
                  changeDay(day);
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                  top: 0.0, bottom: 10.0, right: 20, left: 20),
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
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              width: MediaQuery.sizeOf(context).width,
              height: 35,
              child: Row(
                children: [
                  Expanded(
                      flex: 4,
                      child: Container(
                        margin: EdgeInsetsDirectional.fromSTEB(10, 5, 10, 5),
                        width: MediaQuery.sizeOf(context).width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getSelectedDateString(),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                  color: BlocTheme.theme.default900Color,
                                  fontFamily: "Inter",
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            Expanded(
              /*child: RefreshIndicator(
              key: _refreshIndicatorKey,
              color: BlocTheme.theme.default900Color,*/
              child: FutureBuilder<List<GroupLessonModel>>(
                future: groupLessons,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // until data is fetched, show loader
                    return const Center(child: LoadingIndicatorWidget());
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final order = snapshot.data!;
                    // Kayıt olunan dersleri en üste taşı
                    order.sort((a, b) {
                      if (a.member_registered == b.member_registered) {
                        return 0;
                      }
                      return a.member_registered == true ? -1 : 1;
                    });
                    return buildGroupLessons(order);
                  } else {
                    // if no data, show simple Text
                    return const Center(child: NoDataTextWidget());
                  }
                },
              ),
              /*onRefresh: () {
                var data = fetchGroupLessons();
                setState(() {
                  groupLessons = data;
                });
                return data;
              },*/
            )
            //),
          ] else ...[
            Expanded(
              child: FutureBuilder<List<GroupLessonResarvationModel>>(
                future: groupLessonResarvations,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // until data is fetched, show loader
                    return const Center(child: LoadingIndicatorWidget());
                  } else if (snapshot.hasData && snapshot.data!.length > 0) {
                    final order = snapshot.data!;
                    return buildGroupLessonResarvations(order);
                  } else {
                    // if no data, show simple Text
                    return const Center(child: NoDataTextWidget());
                  }
                },
              ),
            )
          ],
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        tab: NavTab.home,
      ),
    );
  }

  Widget buildGroupLessons(List<GroupLessonModel> groupLesson) {
    return ListView.builder(
      itemCount: groupLesson.length,
      padding: EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        final data = groupLesson[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupLessonDetail(
                  lesson: data,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: ApplicationColor.primaryBoxBackground,
              borderRadius: BorderRadius.all(Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            margin: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 15),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data.service_plan_name,
                        style: TextStyle(
                          color: BlocTheme.theme.default900Color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildCapacityBadge(data),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    if (data.employee_image != null &&
                        data.employee_image!.isNotEmpty)
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(data.employee_image!),
                      )
                    else
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            BlocTheme.theme.default900Color.withOpacity(0.1),
                        child: Icon(Icons.person,
                            color: BlocTheme.theme.default900Color, size: 24),
                      ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.employee_name,
                            style: TextStyle(
                              color: BlocTheme.theme.default900Color,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            "Eğitmen",
                            style: TextStyle(
                              color: BlocTheme.theme.default900Color
                                  .withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Builder(
                    builder: (context) {
                      List<Widget> infoItems = [];

                      // 1. Ders Saati
                      infoItems.add(_buildInfoItem(
                        Icons.access_time_filled,
                        "Ders Saati",
                        data.time,
                      ));

                      // 2. Kontenjan
                      infoItems.add(_buildInfoItem(
                        Icons.event_available,
                        "Kontenjan",
                        "${data.person_limit} Kişi",
                      ));

                      // 2.5 Min Limit
                      if (data.min_limit > 0) {
                        infoItems.add(_buildInfoItem(
                          Icons.group_outlined,
                          "Min Katılım",
                          "${data.min_limit} Kişi",
                        ));
                      }

                      // 3. Açılış (Şartlı)
                      if (data.enable_time.trim().isNotEmpty &&
                          data.enable_time.trim() != "00:00:00" &&
                          data.enable_time.trim() != "00:00") {
                        infoItems.add(_buildInfoItem(
                          Icons.timer_outlined,
                          "Açılış",
                          data.enable_time,
                        ));
                      }

                      // 4. Ücret
                      infoItems.add(_buildInfoItem(
                        data.is_paid ? Icons.payments : Icons.card_giftcard,
                        "Ücret",
                        data.is_paid ? "Ücretli" : "Ücretsiz",
                        valueColor: data.is_paid
                            ? BlocTheme.theme.defaultRed700Color
                            : BlocTheme.theme.default900Color,
                      ));

                      // 5. Konum (Şartlı)
                      if (data.enable_seat_selection &&
                          data.seat_selection != null &&
                          data.seat_selection!.locations.isNotEmpty) {
                        infoItems.add(_buildInfoItem(
                          Icons.location_on,
                          "Konum",
                          data.seat_selection!.locations.first.name,
                        ));
                      }

                      // 6. Kısıt (Şartlı)
                      if (data.only_purchased_members_can_register) {
                        infoItems.add(_buildInfoItem(
                          Icons.verified_user,
                          "Kayıt Yetkisi",
                          "Dersi satın alanlar",
                          valueColor: BlocTheme.theme.defaultRed700Color,
                        ));
                      }

                      // İkili satırlar oluştur
                      List<Widget> rows = [];
                      for (int i = 0; i < infoItems.length; i += 2) {
                        rows.add(
                          Row(
                            children: [
                              Expanded(child: infoItems[i]),
                              if (i + 1 < infoItems.length)
                                Expanded(child: infoItems[i + 1])
                              else
                                const Expanded(child: SizedBox()),
                            ],
                          ),
                        );
                        if (i + 2 < infoItems.length) {
                          rows.add(const SizedBox(height: 10));
                        }
                      }

                      return Column(children: rows);
                    },
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(data),
                    Icon(
                      data.member_registered == true
                          ? Icons.check_circle
                          : Icons.arrow_forward_ios,
                      color: data.member_registered == true
                          ? BlocTheme.theme.default600Color
                          : BlocTheme.theme.default900Color,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCapacityBadge(GroupLessonModel data) {
    bool isFull = data.person_count >= data.person_limit;
    Color contentColor = isFull
        ? BlocTheme.theme.defaultRed700Color
        : BlocTheme.theme.default900Color;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: contentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people,
            size: 14,
            color: contentColor,
          ),
          SizedBox(width: 4),
          Text(
            "${data.person_count}/${data.person_limit}",
            style: TextStyle(
              color: contentColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBadge(GroupLessonModel data) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: data.is_paid
            ? Colors.orange.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        data.is_paid ? "Ücretli" : "Ücretsiz",
        style: TextStyle(
          color: data.is_paid
              ? BlocTheme.theme.defaultOrange400Color
              : BlocTheme.theme.default900Color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              size: 16, color: valueColor ?? BlocTheme.theme.default800Color),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: BlocTheme.theme.default900Color.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? BlocTheme.theme.default900Color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(GroupLessonModel data) {
    String statusText = "";
    Color statusColor = BlocTheme.theme.default900Color;

    if (data.member_registered == true) {
      statusText = (data.seat_selection?.member?.selected_seat_name != null &&
              data.seat_selection!.member!.selected_seat_name!.isNotEmpty)
          ? "Kayıt Yapıldı - ${data.seat_selection!.member!.selected_seat_name}"
          : "Kayıt Yapıldı";
      statusColor = BlocTheme.theme.default600Color;
    } else if (data.remain_limit > 0 &&
        data.member_registered == false &&
        data.can_today_resarvation == true) {
      statusText = "Kayıt Yapılabilir";
      statusColor = Colors.blue;
    } else if (data.remain_limit == 0 && data.can_today_resarvation) {
      statusText = "Kontenjan Doldu";
      statusColor = BlocTheme.theme.defaultRed700Color;
    } else {
      statusText = "Rezervasyon ders günü yapılır.";
      statusColor = BlocTheme.theme.defaultOrange400Color;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLessonInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon,
              size: 16,
              color: BlocTheme.theme.default900Color.withOpacity(0.7)),
          SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              color: BlocTheme.theme.default900Color.withOpacity(0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: BlocTheme.theme.default900Color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(GroupLessonModel data) {
    String statusText = "";
    Color statusColor = BlocTheme.theme.default900Color;

    if (data.member_registered == true) {
      statusText = (data.seat_selection?.member?.selected_seat_name != null &&
              data.seat_selection!.member!.selected_seat_name!.isNotEmpty)
          ? "Kayıt Yapıldı - ${data.seat_selection!.member!.selected_seat_name}"
          : "Kayıt Yapıldı";
      statusColor = BlocTheme.theme.default600Color;
    } else if (data.remain_limit > 0 &&
        data.member_registered == false &&
        data.can_today_resarvation == true) {
      statusText = "Kayıt Yapılabilir";
      statusColor = Colors.blue;
    } else if (data.remain_limit == 0 && data.can_today_resarvation) {
      statusText = "Kontenjan Doldu";
      statusColor = ApplicationColor.error;
    } else {
      statusText = "Rezervasyon ders günü yapılır.";
      statusColor = BlocTheme.theme.defaultOrange400Color;
    }

    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildGroupLessonResarvations(
      List<GroupLessonResarvationModel> resarvation) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: resarvation.length,
      itemBuilder: (context, index) {
        final data = resarvation[index];
        if (data.servicePlanName.trim().isEmpty) {
          return const SizedBox.shrink();
        }

        final bool isCancelled =
            data.deletedAt != null && data.deletedAt!.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: ApplicationColor.primaryBoxBackground,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          margin: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 15),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data.servicePlanName,
                      style: TextStyle(
                        color: BlocTheme.theme.default900Color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration:
                            isCancelled ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCancelled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: BlocTheme.theme.defaultRed700Color
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "İptal Edildi",
                        style: TextStyle(
                          color: BlocTheme.theme.defaultRed700Color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ApplicationColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Aktif",
                        style: TextStyle(
                          color: ApplicationColor.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        BlocTheme.theme.default900Color.withOpacity(0.1),
                    child: Icon(Icons.person,
                        color: BlocTheme.theme.default900Color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.employeeName,
                          style: TextStyle(
                            color: BlocTheme.theme.default900Color,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "Eğitmen",
                          style: TextStyle(
                            color:
                                BlocTheme.theme.default900Color.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            Icons.access_time_filled,
                            "Ders Saati",
                            data.formattedTime,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            Icons.calendar_today,
                            "Tarih",
                            data.formattedDate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            Icons.event,
                            "Gün",
                            data.dayName,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
