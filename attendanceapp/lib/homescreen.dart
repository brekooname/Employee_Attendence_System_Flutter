import 'package:attendanceapp/calendarscreen.dart';
import 'package:attendanceapp/loginscreen.dart';
import 'package:attendanceapp/model/user.dart';
import 'package:attendanceapp/profilescreen.dart';
import 'package:attendanceapp/services/location_service.dart';
import 'package:attendanceapp/todayscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color(0xffeef444c);
  int currentIndex = 1;
  List<IconData> navigationIcons = [
    FontAwesomeIcons.calendarAlt,
    FontAwesomeIcons.check,
    FontAwesomeIcons.user
  ];

  @override
  void initState() {
    super.initState();
    _startLocationService();
    getId().then((value) {
      _getCredentials();
      _getProfilePic();
    });
  }

  void _getCredentials() async{
    try{
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection("Employee").doc(User.id).get();
      setState(() {
        User.conEdit = doc['conEdit'];
        User.firstName = doc['firstName'];
        User.lastName = doc['lastName'];
        User.birthDate = doc['birthDate'];
        User.address = doc['address'];
      });
    }catch(e){
      return;
    }
  }

  void _getProfilePic() async{
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("Employee").doc(User.id).get();
    setState(() {
      User.profilePicLinc = doc['profilePic'];
    });
  }

  void _startLocationService() async {
    await LocationService().initialize();

    try {
      final double? longitude = await LocationService().getLongitude();
      final double? latitude = await LocationService().getLatitude();

      if (longitude != null && latitude != null) {
        setState(() {
          User.long = longitude;
          User.lot = latitude;
        });
      }
    } catch (e) {
      print("Error getting location data: $e");
    }
  }

  Future <void> getId() async{
    QuerySnapshot snap = await FirebaseFirestore.instance.collection("Employee")
        .where('id', isEqualTo: User.employeeId).get();
    setState(() {
      User.id = snap.docs[0].id;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
         new CalendarScreen(),
          new TodayScreen(employeeId: User.employeeId), // Pass the employeeId here
          new ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin:const EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 24
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 2)
            )
          ]
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(40)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for(int i = 0; i<navigationIcons.length; i++)...<Expanded>{
                Expanded(
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          currentIndex = i;
                        });
                      },
                      child: Container(
                        height: screenHeight,
                        width: screenWidth,
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                  navigationIcons[i],
                                color: i == currentIndex ? primary : Colors.black26,
                                size: i == currentIndex ? 30 : 26,
                              ),
                              i == currentIndex ? Container(
                                margin: EdgeInsets.only(top: 6),
                                height: 3,
                                width: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(40)),
                                  color: primary
                                ),
                              ): const SizedBox()
                            ],
                          ),
                        ),
                      ),
                    ),
                )
              }
            ],
          ),
        ),
      ),
    );
  }
}
