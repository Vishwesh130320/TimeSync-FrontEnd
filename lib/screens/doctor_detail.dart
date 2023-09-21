import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:medicare/styles/colors.dart';
import 'package:medicare/styles/styles.dart';
import "package:latlong2/latlong.dart" as latLng;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show showCupertinoModalPopup;

class SliverDoctorDetail extends StatefulWidget {
  const SliverDoctorDetail({Key? key}) : super(key: key);

  @override
  _SliverDoctorDetailState createState() => _SliverDoctorDetailState();
}

class _SliverDoctorDetailState extends State<SliverDoctorDetail> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime selectedDate1 = DateTime.now();

  _selectDate()  {

    // final DateTime? pickedDate = await
    // showDatePicker(
    //   context: context,
    //   initialDate: DateTime.now(),
    //   firstDate: DateTime.now(),
    //   lastDate: DateTime(DateTime.now().year + 1),
    //     keyboardType : TextInputType.datetime
    // );

    // if (pickedDate != null && pickedDate != selectedDate) {
    //   setState(() {
    //     selectedDate1 = newDate;
    //   });
    // }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Future<void> _bookAppointment() async {
    if (selectedDate != null && selectedTime != null) {
      print("selectedDate $selectedDate");
      print("selectedTime $selectedTime");
    } else {
      // Handle the case when date or time is not selected
      print('Date and time not selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text('Detail Doctor'),
            backgroundColor: Color(MyColors.primary),
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Image(
                image: AssetImage('assets/hospital.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: DetailBody(
              selectDate: _selectDate,
              selectTime: _selectTime,
              bookAppointment: _bookAppointment,
              selectedDate1: selectedDate1,
            ),
          )
        ],
      ),
    );
  }
}

// class DetailBody extends StatelessWidget {
//   final VoidCallback selectDate;
//   final VoidCallback selectTime;
//   final VoidCallback bookAppointment;
//   final DateTime selectedDate1;
//
//   const DetailBody({
//     Key? key,
//     required this.selectDate,
//     required this.selectTime,
//     required this.bookAppointment,
//     required this.selectedDate1,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(20),
//       margin: EdgeInsets.only(bottom: 30),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           DetailDoctorCard(),
//           SizedBox(
//             height: 15,
//           ),
//           DoctorInfo(),
//           SizedBox(
//             height: 30,
//           ),
//           Text(
//             'About Doctor',
//             style: kTitleStyle,
//           ),
//           SizedBox(
//             height: 15,
//           ),
//           Text(
//             'Dr. Joshua Simorangkir is a specialist in internal medicine who specialized blah blah.',
//             style: TextStyle(
//               color: Color(MyColors.purple01),
//               fontWeight: FontWeight.w500,
//               height: 1.5,
//             ),
//           ),
//           SizedBox(
//             height: 25,
//           ),
//           Text(
//             'Location',
//             style: kTitleStyle,
//           ),
//           SizedBox(
//             height: 25,
//           ),
//           DoctorLocation(),
//           SizedBox(
//             height: 25,
//           ),
//           ElevatedButton(
//             style: ButtonStyle(
//               backgroundColor: MaterialStateProperty.all<Color>(
//                 Color(MyColors.primary),
//               ),
//             ),
//             child: Text('Book Appointment'),
//             onPressed: ()  {
//               print("Date is :"+selectedDate1.toString());
//               CupertinoDatePicker(
//                 mode: CupertinoDatePickerMode.dateAndTime,
//                 initialDateTime: selectedDate1,
//                 onDateTimeChanged: (DateTime newDate) async  {
//                   selectedDate1;
//                   //selectedDate1 = newDate;
//                 },
//               );
//               // selectDate(); // Show date picker
//               // selectTime(); // Show time picker
//               // bookAppointment(); // Book the appointment
//             },
//           )
//         ],
//       ),
//     );
//   }
// }

class DetailBody extends StatefulWidget {
  final VoidCallback selectDate;
  final VoidCallback selectTime;
  final VoidCallback bookAppointment;
  final DateTime selectedDate1;

  const DetailBody({
    Key? key,
    required this.selectDate,
    required this.selectTime,
    required this.bookAppointment,
    required this.selectedDate1,
  }) : super(key: key);

  @override
  _DetailBodyState createState() => _DetailBodyState();
}

class _DetailBodyState extends State<DetailBody> {
  late DateTime selectedDate1;

  @override
  void initState() {
    super.initState();
    selectedDate1 = widget.selectedDate1;
  }

  void _updateSelectedDate(DateTime newDate) {
    setState(() {
      selectedDate1 = newDate;
    });
  }

  Future<void> createAppointment(DateTime date, String? doctorId, String? patientId) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/appointment/create'),
        // Use the correct cancel endpoint
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NTA5NGVkNjkxYjA0N2VkYzgwZTBmNjciLCJyb2xlIjoicGF0aWVudCIsImlhdCI6MTY5NTE3MzI4NH0.exwFyhCYpaWPhNw6GeNeAG8TOvEZEtwnPX8tyUW9hto"
        },
        body: jsonEncode({
          "doctorId": doctorId,
          "patientId": patientId,
          "appointmentDate": date.toUtc().toString(),
          "durationInMinutes": 60,
          "status": "Scheduled",
          "location": "123 Main St",
          "notes": "Follow-up appointment"
        }), // Send the updated status
      );

      if (response.statusCode == 201) {
        // If the cancellation is successful, update the local status

        print("Successfully created for $date");
      } else {
        throw Exception('Failed to create appointment ');
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> map = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    String? doctorId = map['doctorId'];
    String? patientId = map['patientId'];
    print('doctor and patient in doctor_details $doctorId $patientId');

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DetailDoctorCard(),
          SizedBox(
            height: 15,
          ),
          DoctorInfo(),
          SizedBox(
            height: 30,
          ),
          Text(
            'About Doctor',
            style: kTitleStyle,
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Dr. Joshua Simorangkir is a specialist in internal medicine who specialized blah blah.',
            style: TextStyle(
              color: Color(MyColors.purple01),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Text(
            'Location',
            style: kTitleStyle,
          ),
          SizedBox(
            height: 25,
          ),
          DoctorLocation(),
          SizedBox(
            height: 25,
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Color(MyColors.primary),
              ),
            ),
            child: Text('Book Appointment'),
            onPressed: () async {
              final DateTime newDate1 = await showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) {
                  DateTime selectedDate = selectedDate1;
                  return Container(
                    color: Colors.blueAccent,
                      height: MediaQuery.of(context).size.height*.35,
                      child:
                    Column(
                      children: [
                    Container(
                      height: MediaQuery.of(context).size.height*.25,

                      child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.dateAndTime,
                          initialDateTime: selectedDate1,
                          onDateTimeChanged: (DateTime newDate) {
                            selectedDate = newDate;
                          },
                        ),),
                        ElevatedButton(

                          child: Text('Confirm appointment'),
                          onPressed: () => {
                            print("selectedDateselectedDateselectedDateselectedDate $selectedDate"),
                            createAppointment(selectedDate, doctorId == null ? "" : doctorId, patientId),
                            Navigator.pop(context)
                          },
                        )
                      ],
                    )
                  );
                },
              );

              // if (newDate != null) {
              //   _updateSelectedDate(newDate);
              // }
            },
          )
        ],
      ),
    );
  }
}


class DoctorLocation extends StatelessWidget {
  const DoctorLocation({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          options: MapOptions(
            center: latLng.LatLng(51.5, -0.09),
            zoom: 13.0,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorInfo extends StatelessWidget {
  const DoctorInfo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        NumberCard(
          label: 'Patients',
          value: '100+',
        ),
        SizedBox(width: 15),
        NumberCard(
          label: 'Experiences',
          value: '10 years',
        ),
        SizedBox(width: 15),
        NumberCard(
          label: 'Rating',
          value: '4.0',
        ),
      ],
    );
  }
}

class NumberCard extends StatelessWidget {
  final String label;
  final String value;

  const NumberCard({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(MyColors.bg03),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 15,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Color(MyColors.grey02),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              value,
              style: TextStyle(
                color: Color(MyColors.header01),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailDoctorCard extends StatelessWidget {
  const DetailDoctorCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: EdgeInsets.all(15),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. Josua Simorangkir',
                      style: TextStyle(
                          color: Color(MyColors.header01),
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Heart Specialist',
                      style: TextStyle(
                        color: Color(MyColors.grey02),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Image(
                image: AssetImage('assets/doctor01.jpeg'),
                width: 100,
              )
            ],
          ),
        ),
      ),
    );
  }
}