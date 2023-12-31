import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show showCupertinoModalPopup;
import 'package:medicare/styles/colors.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({Key? key}) : super(key: key);

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

enum FilterStatus { Upcoming, Completed, Canceled }

class ScheduleItem {
  final String id; // Added an ID field
  final String doctorName;
  final String doctorTitle;
  final String reservedDate;
  final String time;
  FilterStatus status;

  ScheduleItem({
    required this.id,
    required this.doctorName,
    required this.doctorTitle,
    required this.reservedDate,
    required this.time,
    required this.status,
  });
}

class _ScheduleTabState extends State<ScheduleTab> {
  FilterStatus status = FilterStatus.Upcoming;
  Alignment _alignment = Alignment.centerLeft;

  List<ScheduleItem> schedules = [];
  var format = new DateFormat.yMMMMEEEEd('en_US');
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchSchedules();
  }

  Future<void> fetchSchedules() async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/appointment/get'), headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'x-auth-token': "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NTA5NGVkNjkxYjA0N2VkYzgwZTBmNjciLCJyb2xlIjoicGF0aWVudCIsImlhdCI6MTY5NTE3MzI4NH0.exwFyhCYpaWPhNw6GeNeAG8TOvEZEtwnPX8tyUW9hto"
        });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        schedules = data.map((item) {
          return ScheduleItem(
            id: item['_id'] ?? '',
            // Provide a default value if 'id' is null
            doctorName: item['doctorName'] ?? '',
            doctorTitle: item['doctorTitle'] ?? '',
            reservedDate: item['appointmentDate'] ?? '',
            time: item['appointmentTime'] ?? '',
            status: FilterStatus.values.firstWhere(
              (e) => e.toString().split('.')[1] == (item['status'] ?? ''),
              orElse: () => FilterStatus.Upcoming,
            ),
          );
        }).toList();
      });
    } else {
      throw Exception('Failed to load schedules');
    }
  }

  Future<void> cancelAppointment(String id) async {
    print("object111 $id");
    try {
      final response = await http.put(
        Uri.parse('http://localhost:8000/appointment/cancel/$id'),
        // Use the correct cancel endpoint
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // 'x-auth-token': "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NTA5NGVkNjkxYjA0N2VkYzgwZTBmNjciLCJyb2xlIjoicGF0aWVudCIsImlhdCI6MTY5NTE3MzI4NH0.exwFyhCYpaWPhNw6GeNeAG8TOvEZEtwnPX8tyUW9hto"
        },
        body: jsonEncode({'status': 'Canceled'}), // Send the updated status
      );

      if (response.statusCode == 200) {
        // If the cancellation is successful, update the local status
        setState(() {
          final appointment =
              schedules.firstWhere((element) => element.id == id);
          appointment.status = FilterStatus.Canceled;
        });
        print("Successfully deleted $id");
      } else {
        throw Exception('Failed to cancel appointment ');
      }
    } catch (error) {
      print(error);
    }
  }
  Future<void> rescheduleAppointment(String id,String date) async {
    print("date111 $date");
    try {
      final response = await http.put(
        Uri.parse('http://localhost:8000/appointment/reschedule/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NTA5NGVkNjkxYjA0N2VkYzgwZTBmNjciLCJyb2xlIjoicGF0aWVudCIsImlhdCI6MTY5NTE3MzI4NH0.exwFyhCYpaWPhNw6GeNeAG8TOvEZEtwnPX8tyUW9hto"
        },
        body: jsonEncode({'appointmentDate': '$date'}), // Send the updated status
      );

      if (response.statusCode == 200) {
        // If the cancellation is successful, update the local status


        setState(() {
          var appointment =
          schedules.firstWhere((element) => element.id == id);
          appointment = new ScheduleItem(id: appointment.id, doctorName: appointment.doctorName, doctorTitle: appointment.doctorTitle, reservedDate: date, time: appointment.time, status: FilterStatus.values.firstWhere(
                (e) => e.toString().split('.')[1] == ("Scheduled" ?? ''),
            orElse: () => FilterStatus.Upcoming,
          ));
        });
        print("Successfully updated $date");
      } else {
        throw Exception('Failed to cancel appointment ');
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ScheduleItem> filteredSchedules = schedules.where((schedule) {
      return schedule.status == status;
    }).toList();
    // var dateString = format.format(_schedule.reservedDate);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 30, top: 30, right: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Schedule',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (FilterStatus filterStatus in FilterStatus.values)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                status = filterStatus;
                                if (filterStatus == FilterStatus.Upcoming) {
                                  _alignment = Alignment.centerLeft;
                                } else if (filterStatus ==
                                    FilterStatus.Completed) {
                                  _alignment = Alignment.center;
                                } else if (filterStatus ==
                                    FilterStatus.Canceled) {
                                  _alignment = Alignment.centerRight;
                                }
                              });
                            },
                            child: Center(
                              child: Text(
                                filterStatus.toString().split('.').last,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedAlign(
                  duration: Duration(milliseconds: 200),
                  alignment: _alignment,
                  child: Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        status.toString().split('.').last,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredSchedules.length,
                itemBuilder: (context, index) {
                  var _schedule = filteredSchedules[index];
                  bool isLastElement = filteredSchedules.length == index + 1;
                  return Card(
                    margin: !isLastElement
                        ? EdgeInsets.only(bottom: 20)
                        : EdgeInsets.zero,
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(
                                    'assets/doctor02.png'),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _schedule.doctorName,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    _schedule.doctorTitle,
                                    style: TextStyle(
                                      color: Colors.lightBlueAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          DateTimeCard(
                            date: format.format(DateTime.parse(_schedule
                                .reservedDate)) /*_schedule.reservedDate*/,
                            time: _schedule.time,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          status == FilterStatus.Upcoming
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          // Call the cancelAppointment function with the appointment's ID
                                          cancelAppointment(_schedule.id);
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: ElevatedButton(
                                        child: Text('Reschedule'),
                                        onPressed: () => {
                                        showCupertinoModalPopup<void>(
                                        context: context,
                                        builder: (BuildContext context) {
                                        return _buildCupertinoDatePicker(_schedule.id);
                                        },
                                        )
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : Container()
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCupertinoDatePicker(String id) {
    return Container(
      height: 500,
      child: Column(
        children: [
          Container(
            height: 200,
            child: CupertinoDatePicker(

              mode: CupertinoDatePickerMode.dateAndTime,
              initialDateTime: _selectedDate,
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  _selectedDate = newDate;
                });
              },
            ),
          ),
          ElevatedButton(
            child: Text('Reschedule'),
            onPressed: () => {
              rescheduleAppointment(id,_selectedDate.toString()),
              Navigator.pop(context)
            },
          ),
        ],
      ),
    );
  }
}

class DateTimeCard extends StatelessWidget {
  final String date;
  final String time;

  DateTimeCard({
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(MyColors.bg01),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white, // Replace with your desired color
                size: 17,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white, // Replace with your desired color
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.access_alarm,
                color: Colors.white, // Replace with your desired color
                size: 17,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue, // Replace with your desired color
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



