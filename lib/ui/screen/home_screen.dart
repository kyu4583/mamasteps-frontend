import 'package:flutter/material.dart';
import 'package:charts_flutter_updated/flutter.dart' as charts;
import 'package:mamasteps_frontend/calendar/component/calendar_server_communication.dart';
import 'package:mamasteps_frontend/calendar/model/calendar_schedule_model.dart';
import 'package:mamasteps_frontend/login/screen/login_page.dart';
import 'package:mamasteps_frontend/storage/login/login_data.dart';
import 'package:mamasteps_frontend/storage/user/user_data.dart';
import 'package:mamasteps_frontend/ui/component/user_server_comunication.dart';
import 'package:mamasteps_frontend/ui/layout/home_screen_default_layout.dart';
import 'package:mamasteps_frontend/ui/model/user_data_model.dart';

class HomeScreen extends StatefulWidget {
  // final int weeks = 16;
  // final int todayWalkTimeMin = 17;
  // final int thisWeekWalkTimeHour = 1;
  // final int thisWeekWalkTimeMin = 26;
  // final int thisWeekAchievement = 10;
  // final int totalWeekAchievement = 20;

  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int weeks = 0;
  late int todayWalkTimeTotalSeconds = 0;
  // late int todayWalkTimeMin = 0;
  late int thisWeekWalkTimeTotalSeconds = 0;
  late int recommended = 0;
  // late int thisWeekWalkTimeHour = 0;
  // late int thisWeekWalkTimeMin = 0;
  late int thisWeekAchievement = 0;
  late int totalWeekAchievement;
  late List<int> weekWalkTime = [0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    pageInit();
    acceptResponse();
    acceptUserResponse();
    acceptGetInfo();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double progressRatio = thisWeekAchievement / totalWeekAchievement;
    double progressBarWidth = screenWidth * progressRatio;
    return HomeScreenDefaultLayout(
        Header: _Header(
          weeks: weeks,
        ),
        Body: buildWidgetsList(
          screenWidth,
          // todayWalkTimeMin,
          // thisWeekWalkTimeHour,
          // thisWeekWalkTimeMin,
          todayWalkTimeTotalSeconds,
          thisWeekWalkTimeTotalSeconds,
          thisWeekAchievement,
          totalWeekAchievement,
          weekWalkTime,
          recommended,
          progressBarWidth,
        ));
  }

  void pageInit() {
    weeks = 0;
    todayWalkTimeTotalSeconds = 0;
    thisWeekWalkTimeTotalSeconds = 0;
    recommended = 0;
    thisWeekAchievement = 0;
    totalWeekAchievement = 2;
    weekWalkTime = [0, 0, 0, 0, 0, 0, 0];
  }

  void initThisWeekAchievement() {
    setState(() {
      for (int i = 0; i < weekWalkTime.length; i++) {
        if (weekWalkTime[i] > recommended * 0.9) {
          thisWeekAchievement++;
        }
      }
    });
  }

  void acceptGetInfo() async {
    myInfo apiResponse = await getMyInfo();
    setState(() {
      if (apiResponse.isSuccess) {
        recommended = apiResponse.targetTime ~/ 60;
      }
    });
  }

  void acceptUserResponse() async {
    getMeResponse apiResponse = await getMe();
    setState(() {
      DateTime now = DateTime.now();
      Duration difference = now.difference(DateTime(
          apiResponse.pregnancyStartDate[0],
          apiResponse.pregnancyStartDate[1],
          apiResponse.pregnancyStartDate[2]));
      weeks = difference.inDays ~/ 7;
      // if (apiResponse.isSuccess) {
      //   weeks = weeks;
      // }
      user_storage.write(
          key: 'guardianPhoneNumber', value: apiResponse.guardianPhoneNumber);
    });
  }

  void acceptResponse() async {
    bool isSameDate(DateTime date1, DateTime date2) {
      return date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day == date2.day;
    }

    getRecordResponse apiResponse = await getRecords();
    setState(() {
      if (apiResponse.isSuccess) {
        DateTime now = DateTime.now();

        DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        DateTime endOfWeek =
            now.add(Duration(days: DateTime.daysPerWeek - now.weekday + 1));
        for (int i = 0; i < apiResponse.result.length; i++) {
          DateTime apiDate = apiResponse.result[i].date;
          int apiCompletedTimeSeconds =
              apiResponse.result[i].completedTimeSeconds.toInt() ~/ 60;
          int diffrence = apiDate.difference(startOfWeek).inDays + 1;
          // 이번주 총 산책 시간 계산
          if (apiResponse.result[i].date.isAfter(startOfWeek) &&
              apiResponse.result[i].date.isBefore(endOfWeek)) {
            // 요일별 시간 저장
            weekWalkTime[diffrence] += apiCompletedTimeSeconds;
            thisWeekWalkTimeTotalSeconds +=
                apiResponse.result[i].completedTimeSeconds;
          }
          // 오늘 산책 시간 계산
          isSameDate(apiDate, now)
              ? todayWalkTimeTotalSeconds +=
                  apiResponse.result[i].completedTimeSeconds
              : null;
        }
        for (int i = 0; i < weekWalkTime.length; i++) {
          if (weekWalkTime[i] > recommended * 0.9) {
            thisWeekAchievement++;
          }
        }
      }
    });
  }
}

class _Header extends StatelessWidget {
  final int weeks;
  const _Header({
    super.key,
    required this.weeks,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            child: Image.asset(
              'asset/image/root_tab_top_image.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 5,
            top: 10,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: Image.asset(
                "asset/image/mamasteps_logo.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                deleteAll();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => GoogleLogin()), (route) => false);
              },
            ),
          ),
          Positioned(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    '임신',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  child: Text(
                    weeks.toString(),
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  child: Text(
                    '주차',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class walkTime {
  final String day_of_week;
  final int sales;

  walkTime(this.day_of_week, this.sales);
}

class SimpleBarChart extends StatelessWidget {
  final List<int> walkTimeList;
  final int recommended;

  const SimpleBarChart({
    super.key,
    required this.walkTimeList,
    required this.recommended,
  });

  @override
  Widget build(BuildContext context) {
    final List<walkTime> seriesList = [
      walkTime(
        '월',
        walkTimeList[0],
      ),
      walkTime(
        '화',
        walkTimeList[1],
      ),
      walkTime(
        '수',
        walkTimeList[2],
      ),
      walkTime(
        '목',
        walkTimeList[3],
      ),
      walkTime(
        '금',
        walkTimeList[4],
      ),
      walkTime(
        '토',
        walkTimeList[5],
      ),
      walkTime(
        '일',
        walkTimeList[6],
      ),
    ];

    List<charts.Series<walkTime, String>> series = [
      charts.Series(
        id: 'Sales',
        data: seriesList,
        domainFn: (walkTime day_of_week, _) => day_of_week.day_of_week,
        measureFn: (walkTime time, _) => time.sales,
      ),
    ];

    return charts.BarChart(
      primaryMeasureAxis: new charts.NumericAxisSpec(
          tickProviderSpec:
              charts.StaticNumericTickProviderSpec(<charts.TickSpec<num>>[
        charts.TickSpec<num>(0),
        charts.TickSpec<num>(20),
        charts.TickSpec<num>(40),
        charts.TickSpec<num>(60),
      ])),
      series,
      animate: true,
      behaviors: [
        new charts.RangeAnnotation(
          [
            charts.LineAnnotationSegment(
              recommended,
              charts.RangeAnnotationAxisType.measure,
              color: charts.MaterialPalette.red.shadeDefault,
              labelDirection: charts.AnnotationLabelDirection.horizontal,
              labelAnchor: charts.AnnotationLabelAnchor.start,
            ),
          ],
        ),
      ],
    );
  }
}

List<Widget> buildWidgetsList(
  double screenWidth,
  // int todayWalkTimeMin,
  // int thisWeekWalkTimeHour,
  // int thisWeekWalkTimeMin,
  int todayWalkTimeTotalSeconds,
  int thisWeekWalkTimeTotalSeconds,
  int thisWeekAchievement,
  int totalWeekAchievement,
  List<int> weekWalkTime,
  int recommended,
  double progressBarWidth,
) {
  int todayHours = todayWalkTimeTotalSeconds ~/ 3600;
  int todayMinutes = (todayWalkTimeTotalSeconds % 3600) ~/ 60;
  int thisWeekWalkTimeHour = thisWeekWalkTimeTotalSeconds ~/ 3600;
  int thisWeekWalkTimeMin = (thisWeekWalkTimeTotalSeconds % 3600) ~/ 60;

  return [
    SizedBox(
      width: screenWidth,
      height: 100,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '오늘의 산책 시간',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                todayHours > 0
                    ? '${todayHours.toString().padLeft(2, '0')} 시간 ${todayMinutes.toString().padLeft(2, '0')} 분'
                    : '${todayMinutes.toString().padLeft(2, '0')} 분',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffa412db),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 20),
    SizedBox(
      width: screenWidth,
      height: 100,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '이번 주 총 산책 시간',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                thisWeekWalkTimeHour > 0
                    ? '${thisWeekWalkTimeHour.toString().padLeft(2, '0')} 시간 ${thisWeekWalkTimeMin.toString().padLeft(2, '0')} 분'
                    : '${thisWeekWalkTimeMin.toString().padLeft(2, '0')} 분',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffa412db),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 20),
    SizedBox(
      width: screenWidth,
      height: 100,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '이번 주 목표 달성률',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.17,
                  height: 23,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    elevation: 2,
                    shadowColor: Colors.blue,
                    child: Center(
                      child: Text(
                        '$thisWeekAchievement/$totalWeekAchievement',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Stack(
                children: <Widget>[
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 20,
                      width: progressBarWidth,
                      decoration: BoxDecoration(
                        color: Color(0xffa412db),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 20),
    SizedBox(
      width: screenWidth,
      height: 400,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '일별 산책 시간',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SimpleBarChart(
                  walkTimeList: weekWalkTime,
                  recommended: recommended,
                ), // 여기에 SimpleBarChart 위젯의 정의가 필요합니다.
              ),
            ),
          ],
        ),
      ),
    ),
  ];
}
