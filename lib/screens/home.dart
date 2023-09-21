import 'package:flutter/material.dart';
import 'package:medicare/styles/colors.dart';
import 'package:medicare/tabs/HomeTab.dart';
import 'package:medicare/tabs/ScheduleTab.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:medicare/Model/doctorlist.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

List<Map> navigationBarItems = [
  {'icon': Icons.local_hospital, 'index': 0},
  {'icon': Icons.calendar_today, 'index': 1},
];

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  late List<DoctorList> userDataList = [];
  void goToSchedule() {
    setState(() {
      _selectedIndex = 1;
    });
  }
  // Function to fetch user profile data
/*  Future<void> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-auth-token': "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NTAzZWE2ODAyNGI3MTI1NWVkNDY0MjAiLCJyb2xlIjoicGF0aWVudCIsImlhdCI6MTY5NDc1NTQ2MX0.TRAt-ahuebzpaeE33SWJuxahTX7o2Jk8oeKkqYtye_w"
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        final userProfile = json.decode(response.body);
        final userFullName = userProfile['username']; // Assuming the API response has a 'username' field
        setState(() {
          userName = userFullName.toString();
        });
      } else {
        print('Failed to fetch user profile');
      }
    } catch (error) {
      // Handle network errors or other exceptions...
      print('Error: $error');
    }
  }*/

  // Function to fetch user profile data
  Future<void> fetchAllDoctors() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/doctors'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          final dynamic decodedData = json.decode(response.body);
          userDataList = (decodedData as List).map((e) => DoctorList.fromJson(e)).toList();
            // userDataList = decodedData
            //     .map((data) => {
            //   "username": data["username"],
            //   "email": data["email"],
            //   "role": data["role"],
            // })
            //     .toList();
        });
        print(userDataList);

      } else {
        print('Failed to fetch user profile');
      }
    } catch (error) {
      // Handle network errors or other exceptions...
      print('Error: $error');
    }
  }
  @override
  void initState() {
    super.initState();
    // fetchUserProfile();
    fetchAllDoctors();
    // fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {

    final String? patientId = ModalRoute.of(context)!.settings.arguments as String?;
    List<Widget> screens = [
      HomeTab(
        onPressedScheduleCard: goToSchedule,
          doctorsList : userDataList,
        patientId: patientId
      ),
      ScheduleTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(MyColors.primary),
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 0,
        selectedItemColor: Color(MyColors.primary),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          for (var navigationBarItem in navigationBarItems)
            BottomNavigationBarItem(
              icon: Container(
                height: 55,
                decoration: BoxDecoration(
                  border: Border(
                    top: _selectedIndex == navigationBarItem['index']
                        ? BorderSide(color: Color(MyColors.bg01), width: 5)
                        : BorderSide.none,
                  ),
                ),
                child: Icon(
                  navigationBarItem['icon'],
                  color: _selectedIndex == 0
                      ? Color(MyColors.bg01)
                      : Color(MyColors.bg02),
                ),
              ),
              label: '',
            ),
        ],
        currentIndex: _selectedIndex,
        onTap: (value) => setState(() {
          _selectedIndex = value;
        }),
      ),
    );
  }
}
