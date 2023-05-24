
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ameripro_app/partials/Drawer.dart';
import 'package:ameripro_app/partials/UserTopMenu.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../partials/AppbarGlobalFunc.dart';
import 'package:ameripro_app/models/AppData.dart';

class SubmittedJobs extends StatefulWidget {
  const SubmittedJobs({Key? key}) : super(key: key);

  @override
  State<SubmittedJobs> createState() => _SubmittedJobsState();
}

class _SubmittedJobsState extends State<SubmittedJobs> {
  get myIcon => null;
  final bool _isObscure = true;
  bool isChecked = false;
  List<String> states = [];
  final globalKey = GlobalKey<ScaffoldState>();
  String lastDays = "Last 7 Days";
  String Stage = "Select Stage";
  String txtCreated = "Inspections Created";
  int totalVisits = 0;
  int totalVisitsCreated = 0;
  List<dynamic> prospects = [];

  bool showSpinner = false;

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  final txtEmail = TextEditingController();
  final txtPassword = TextEditingController();

  get floatingActionButton => null;

  @override
  void dispose() {
    txtEmail.dispose();
    txtPassword.dispose();
    _customInfoWindowController.dispose();
    super.dispose();
  }

  late GoogleMapController _googleMapController;
  late LatLng startLocation = const LatLng(0, 0);
  final CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();
  Set<Marker> markers = {};

  Future<BitmapDescriptor> getIcon(String color) async {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)), 'assets/images/marker/black.png',
    );

    if(isIOS){
      markerbitmap = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)), 'assets/images/marker/black_ios.png',
      );
    }


    switch (color) {
      case 'Orange':
        if(isIOS){
          markerbitmap = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48, 48)), 'assets/images/marker/orange_ios.png',
          );
        }else {
          markerbitmap = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48, 48)), 'assets/images/marker/orange.png',
          );
        }
        break;
      case 'Green':
        if(isIOS){
          markerbitmap = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48, 48)), 'assets/images/marker/green_ios.png',
          );
        }else {
          markerbitmap = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48, 48)), 'assets/images/marker/green.png',
          );
        }
        break;
      case 'Blue':
        if(isIOS){
          markerbitmap = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48, 48)), 'assets/images/marker/blue_ios.png',
          );
        }else {
          markerbitmap = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48, 48)), 'assets/images/marker/blue.png',
          );
        }
        break;
    }
    return markerbitmap;
  }

  Future<Color> getInfoWindowColor(String color) async {
    Color infoWindowColor = Colors.black;

    switch (color) {
      case 'Orange':
        infoWindowColor = Color(0xffffab40);
        break;
      case 'Green':
        infoWindowColor = Color(0xff4caf50);
        break;
      case 'Blue':
        infoWindowColor = Color(0xff2196f3);
        break;
    }
    return infoWindowColor;
  }

  addMarkers([String searchDays = "", String searchType = ""]) async {
    List<dynamic> data = await AppData.getMySubmittedJobs(searchDays, searchType);

    Set<Marker> mapMarkers = {};

    setState(() {
      totalVisits = 0;
      totalVisitsCreated = 0;
      startLocation = LatLng(0, 0);
      prospects = data;
    });

    int totalInspections = 0;
    int totalRetail = 0;
    int totalClaim = 0;
    int totalAdjuster = 0;

    for (var d in data) {
      if(d['marker_color'].toString() != 'null') {
        BitmapDescriptor markerBitmap = await getIcon(d['marker_color']);
        Color infoWindowColor = await getInfoWindowColor(d['marker_color']);
        LatLng markerLocation = LatLng(double.parse(d['lat']), double.parse(d['lng']));

        setState(() {
          if (d['type'] == 'Inspection' && Stage == 'Inspection') {
            txtCreated = 'Inspection Created';
            totalInspections++;
            totalVisitsCreated = totalInspections;
          }else if (d['type'] == 'Retail' && Stage == 'Retail') {
            txtCreated = 'Retail Created';
            totalRetail++;
            totalVisitsCreated = totalRetail;
          }else if (d['type'] == 'Adjuster Appointment' && Stage == 'Adjuster Appointment') {
            txtCreated = 'Adjuster Appointment Created';
            totalAdjuster++;
            totalVisitsCreated = totalAdjuster;
          }else if (d['type'] == 'Claim' && Stage == 'Claim') {
            txtCreated = 'Claim Created';
            totalClaim++;
            totalVisitsCreated = totalClaim;
          }else if (Stage == 'Select Stage') {
            txtCreated = 'Inspections Created';
            totalVisitsCreated = totalInspections;
          }

          totalVisits++;
          startLocation = LatLng(double.parse(data[0]['lat']), double.parse(data[0]['lng']));
        });

        mapMarkers.add(Marker(
          //add start location marker
          markerId: MarkerId(markerLocation.toString()),
          position: markerLocation, //position of marker
          onTap: () {
            _customInfoWindowController.addInfoWindow!(
                SizedBox(
                    height: 00,
                    width: 00,
                    child: SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 300,
                            height: 125,
                            decoration: BoxDecoration(
                              color: infoWindowColor,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d['address'].toString(),
                                    softWrap: true,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Log an Activity: ${d['log_an_activity']
                                        .toString()}',
                                    softWrap: true,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Open Active Job: ${d['active_job_id']
                                        .toString()}',
                                    softWrap: true,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Opportunity Indicators: ${d['opportunity_indicator']
                                        .toString()}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                markerLocation);
          },
          icon: markerBitmap, //Icon for Marker
        ));
      }
    }

    /*
    String imgurl = "https://www.fluttercampus.com/img/car.png";
    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(imgurl))
        .load(imgurl))
        .buffer
        .asUint8List();

    mapMarkers.add(
        Marker( //add start location marker
          markerId: MarkerId(carLocation.toString()),
          position: carLocation, //position of marker
          infoWindow: InfoWindow( //popup info
            title: 'Car Point ',
            snippet: 'Car Marker',
          ),
          icon: BitmapDescriptor.fromBytes(bytes), //Icon for Marker
        )
    );
     */

    setState(() {
      markers = mapMarkers;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getActivityData();
    });
  }

  void getActivityData() async {
    setState(() {
      showSpinner = true;
    });

    await addMarkers(lastDays,Stage);

    setState(() {
      showSpinner = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    var inputLabelStyle = const TextStyle(
      fontSize: 10,
      height: 0,
      color: Color(0xff202020),
    );
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;


    bool isDesktop(BuildContext context) =>
        MediaQuery.of(context).size.width >= 600;
    bool isMobile(BuildContext context) =>
        MediaQuery.of(context).size.width < 600;

    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        key: globalKey,
        backgroundColor: const Color(0xffffffff),
        resizeToAvoidBottomInset: true,
        endDrawer: const MyDrawer(),
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // <-- SEE HERE
            statusBarIconBrightness: Brightness.light, //<-- For Android SEE HERE (light icons)
            statusBarBrightness: Brightness.dark, //<-- For iOS SEE HERE (light icons)
          ),
          toolbarHeight: AppbarGlobalFunc.newestBinary,
          backgroundColor: AppbarGlobalFunc.NavbarColor,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: SizedBox(
                width: screenWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/dashboard');
                            },
                            child: const Icon(Icons.arrow_back,color: Colors.white,size: 25,),
                          ),
                          const UserTopMenu(),
                        ],
                      ),
                      if(isDesktop(context))
                        const Text("Submitted Jobs",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w500),
                        ),
                      IconButton(
                          padding: const EdgeInsets.fromLTRB(0, 0, 20, 10),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            globalKey.currentState?.openEndDrawer();
                          },
                          icon: const Icon(
                            Icons.menu,color: Color(0x90ffffff),size: 40,)
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: SizedBox(
                  width: screenWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Submitted Jobs",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                ),
                              ),
                            ],
                          ),

                          /*
                          TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/job-profile');
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Container(
                                      width: 45,
                                      height: 45,
                                      decoration: const BoxDecoration(
                                          color: Color(0x00808080),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(200))),
                                      child: const Icon(
                                        Icons.add,
                                        size: 35,
                                        color: Color(0xff003A92),
                                      ),
                                    ),
                                  )
                                ],
                              ))
                           */
                        ],
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                          child: Text(
                            "Sales person will add a new site visit.",
                            style: TextStyle(
                                color: Color(0x90000000),
                                fontWeight: FontWeight.w300,
                                fontSize: 16),
                          ),
                        ),
                      ),


                      SizedBox(
                        width: screenWidth,
                        child: GridView.count(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: isMobile(context)==true ? 1 : 2,
                          childAspectRatio: isMobile(context)==true ? (1 / .17) : (1 / .3),
                          padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 0),
                          mainAxisSpacing: 0,
                          crossAxisSpacing: isMobile(context)==true ? 0 : 10,
                          children: [

                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: screenWidth,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFF2F3F5),
                                      borderRadius: BorderRadius.all(Radius.circular(8))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              borderRadius:
                                              BorderRadius.all(Radius.circular(8))),
                                          child: const Icon(
                                            Icons.search,
                                            size: 35,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Total Visits",
                                                style: TextStyle(
                                                    color: Color(0x80000000),
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 12),
                                              ),
                                              Text(
                                                totalVisits.toString(),
                                                style: const TextStyle(
                                                    color: Color(0xff000000),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16),
                                              ),
                                            ],
                                          )),
                                      Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                txtCreated,
                                                style: const TextStyle(
                                                    color: Color(0x80000000),
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 12),
                                              ),
                                              Text(
                                                totalVisitsCreated.toString(),
                                                style: const TextStyle(
                                                    color: Color(0xff000000),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16),
                                              ),
                                            ],
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: isMobile(context) ? EdgeInsets.only(right: (screenWidth>390) ? 5 : 0,) : const EdgeInsets.only(right: 0),
                                        child: Container(
                                          width: isMobile(context) ? screenWidth / 2.3 : 150,
                                          decoration: const BoxDecoration(
                                            color: Color(0xffF2F3F5),
                                            borderRadius:
                                            BorderRadius.all(Radius.circular(8)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 2),
                                            child: DropdownButton(
                                              isExpanded: true,
                                              underline: Container(),
                                              icon: const RotationTransition(
                                                turns:
                                                AlwaysStoppedAnimation(270 / 360),
                                                child: Icon(
                                                    Icons.arrow_back_ios_new_outlined,
                                                    size: 18),
                                              ),
                                              items: const [
                                                DropdownMenuItem(
                                                  value: "Last 7 Days",
                                                  child: Text("Last 7 Days"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "Last Month",
                                                  child: Text("Last Month"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "Last Year",
                                                  child: Text("Last Year"),
                                                ),
                                              ],
                                              onChanged: (value) async {
                                                setState(() {
                                                  lastDays = value!;
                                                  print(lastDays);
                                                });
                                                await addMarkers(lastDays, Stage);
                                              },
                                              hint: Text(lastDays),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: isMobile(context) ? EdgeInsets.only(left: (screenWidth>390) ? 5 : 0,) : const EdgeInsets.only(left: 0),
                                      child: Container(
                                        width: isMobile(context) ? screenWidth / 2.3 : 200,
                                        decoration: const BoxDecoration(
                                          color: Color(0xffF2F3F5),
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 2),
                                          child: DropdownButton(
                                            isExpanded: true,
                                            underline: Container(),
                                            icon: const RotationTransition(
                                              turns: AlwaysStoppedAnimation(270 / 360),
                                              child: Icon(
                                                  Icons.arrow_back_ios_new_outlined,
                                                  size: 18),
                                            ),
                                            items: const [
                                              DropdownMenuItem(
                                                value: "Select Stage",
                                                child: Text("Select Stage"),
                                              ),
                                              DropdownMenuItem(
                                                value: "Inspection",
                                                child: Text("Inspection"),
                                              ),
                                              DropdownMenuItem(
                                                value: "Claim",
                                                child: Text("Claim"),
                                              ),
                                              DropdownMenuItem(
                                                value: "Adjuster Appointment",
                                                child: Text("Adjuster Appointment"),
                                              ),
                                              DropdownMenuItem(
                                                value: "Retail",
                                                child: Text("Retail"),
                                              ),
                                            ],
                                              onChanged: (value) async {
                                                setState(() {
                                                  if(value == 'Inspection') { txtCreated = 'Inspections Created'; }
                                                  if(value == 'Retail') { txtCreated = 'Retail Created'; }
                                                  if(value == 'Adjuster Appointment') { txtCreated = 'Adjuster Appointment Created'; }
                                                  if(value == 'Claim') { txtCreated = 'Claim Created'; }

                                                  Stage = value!;
                                                });
                                                await addMarkers(lastDays, Stage);
                                              },
                                              hint: Text(Stage),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),

                      Container(
                        height: 20,
                      ),

                      SizedBox(
                        width: screenWidth,
                        child: GridView.count(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: isMobile(context) == true ? 1 : 2,
                          childAspectRatio:
                          isMobile(context) == true ? (1 / 1.5) : (1 / 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 0),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: isMobile(context) == true ? 0 : 10,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    SizedBox(
                                      width: screenWidth,
                                      height: (screenWidth > 390) ? 500 : 420,
                                      child: Stack(
                                        children: [
                                          if(startLocation.latitude != 0) ... {
                                            GoogleMap(
                                                initialCameraPosition:
                                                CameraPosition(
                                                  target: startLocation,
                                                  zoom: 12.0,
                                                ),
                                                mapToolbarEnabled: true,
                                                myLocationButtonEnabled: false,
                                                scrollGesturesEnabled: true,
                                                compassEnabled: false,
                                                zoomGesturesEnabled: true,
                                                tiltGesturesEnabled: true,
                                                rotateGesturesEnabled: true,
                                                zoomControlsEnabled: true,
                                                markers: markers,
                                                //markers to show on map
                                                mapType: MapType.normal,
                                                //map type
                                                onMapCreated: (GoogleMapController controller) {
                                                  //method called when map is created
                                                  setState(() {
                                                    _googleMapController = controller;
                                                    _customInfoWindowController.googleMapController = controller;
                                                  });
                                                },
                                                onTap: (position) {
                                                  _customInfoWindowController
                                                      .hideInfoWindow!();
                                                },
                                                onCameraMove: (position) {
                                                  _customInfoWindowController
                                                      .onCameraMove!();
                                                },

                                                gestureRecognizers: Set()
                                                  ..add(Factory<
                                                      OneSequenceGestureRecognizer>(
                                                          () =>
                                                          EagerGestureRecognizer()))..add(
                                                      Factory<
                                                          PanGestureRecognizer>(
                                                              () =>
                                                              PanGestureRecognizer()))..add(
                                                      Factory<
                                                          ScaleGestureRecognizer>(
                                                              () =>
                                                              ScaleGestureRecognizer()))..add(
                                                      Factory<
                                                          TapGestureRecognizer>(
                                                              () =>
                                                              TapGestureRecognizer()))..add(
                                                      Factory<
                                                          VerticalDragGestureRecognizer>(
                                                              () =>
                                                              VerticalDragGestureRecognizer()))),
                                            CustomInfoWindow(
                                              controller:
                                              _customInfoWindowController,
                                              height: 200,
                                              width: 400,
                                              offset: 35,
                                            )
                                          }
                                        ],
                                      ),
                                    ),

                                    /*
                                    Positioned(
                                      top:20,
                                      left: 15,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: screenWidth/1.2,
                                          height: 60,
                                          child: TextFormField(
                                            keyboardType: TextInputType.text,
                                            //autofocus: true,
                                            style: const TextStyle(
                                              color: Color(0xff051C48),
                                            ),
                                            decoration: const InputDecoration(
                                              hintText: "110 Oaks Ave, Asheville, N Caroline 28801",
                                              hintStyle: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'AvenirLight',
                                                  color: Color(0xff051C48)
                                              ),
                                              contentPadding: EdgeInsets.all(20),
                                              labelStyle: TextStyle(
                                                color: Color(0xff051C48),
                                                fontSize: 11,
                                                fontFamily: 'AvenirLight',
                                              ),
                                              filled: true,
                                              fillColor: Color(0xffF2F3F5),
                                              floatingLabelBehavior:FloatingLabelBehavior.always,
                                              labelText: "",
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                     */
                                  ],
                                ),
                              ],
                            ),


                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [

                                for(var d in prospects) ... {
                                  Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              color: Color(0x20808080),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8))),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 18.0, vertical: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [

                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                                                          CameraPosition(
                                                            target: LatLng(double.parse(d['lat'].toString()), double.parse(d['lng'].toString())),
                                                            zoom: 12.0
                                                          )
                                                      ));
                                                    });
                                                  },
                                                  child: Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                        color: (d['marker_color'] == 'Blue' ? Colors.blue : (d['marker_color'] == 'Green' ? Colors.green : (d['marker_color'] == 'Orange' ? Colors.orangeAccent : Color(0xff000000)))),
                                                        borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                200))),
                                                    child: const Icon(
                                                      Icons.home,
                                                      size: 35,
                                                      color: Color(0xffffffff),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 18),
                                                  child: SizedBox(
                                                    width: isMobile(context)
                                                        ? screenWidth / 1.9
                                                        : 220,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              '${d['firstname']} ${d['lastname']}',
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                                  color:
                                                                  Colors.black,
                                                                  fontSize: 20),
                                                            )),
                                                        Container(height: 8),
                                                        Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              "Address: ${d['address'].toString()}",
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                                  color:
                                                                  Colors.black,
                                                                  fontSize: 12),
                                                            )),
                                                        Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              "Phone1: ${d['phone1'].toString()}",
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                                  color:
                                                                  Colors.black,
                                                                  fontSize: 12),
                                                            )),
                                                        Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              "Phone2: ${d['phone2'].toString()}",
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                                  color:
                                                                  Colors.black,
                                                                  fontSize: 12),
                                                            )),
                                                        Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              "Email: ${d['email'].toString()}",
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                                  color:
                                                                  Colors.black,
                                                                  fontSize: 12),
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          width: 33,
                                          height: 33,
                                          decoration: const BoxDecoration(
                                              color: Color(0xff3779EF),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(200))),
                                          child: TextButton(
                                              onPressed: () {
                                                // Navigator.pushReplacementNamed(context, '/edit-visits');
                                              },
                                              child: Image.asset(
                                                'assets/images/editPen.png',
                                                width: 15,
                                              )),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: -8,
                                        right: 4,
                                        child: Container(
                                          child: TextButton(
                                              onPressed: () {
                                                // Navigator.pushReplacementNamed(context, '/edit-visits');
                                              },
                                              child: Text(
                                                d['prospect_dt'].toString(),
                                                style: const TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.black),
                                              )),
                                        ),
                                      )
                                    ],
                                  ),
                                }
                              ],
                            ),
                            /*
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Color(0x20808080),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 18.0, vertical: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: const BoxDecoration(
                                                    color: Color(0xff000000),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                200))),
                                                child: const Icon(
                                                  Icons.home,
                                                  size: 35,
                                                  color: Color(0xffffffff),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 18),
                                                child: SizedBox(
                                                  width: isMobile(context)
                                                      ? screenWidth / 1.9
                                                      : 220,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            "Michael Clark",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    Colors.black,
                                                                fontSize: 20),
                                                          )),
                                                      Container(height: 8),
                                                      const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            "Address: 1062 Star Route, Wheeling, IL, 60090",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color:
                                                                    Colors.black,
                                                                fontSize: 12),
                                                          )),
                                                      const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            "Phone: (123) 554-8876",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color:
                                                                    Colors.black,
                                                                fontSize: 12),
                                                          )),
                                                      const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            "Email: michael@example.com",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color:
                                                                    Colors.black,
                                                                fontSize: 12),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        width: 33,
                                        height: 33,
                                        decoration: const BoxDecoration(
                                            color: Color(0xff3779EF),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(200))),
                                        child: TextButton(
                                            onPressed: () {
                                              // Navigator.pushReplacementNamed(context, '/edit-visits');
                                            },
                                            child: Image.asset(
                                              'assets/images/editPen.png',
                                              width: 15,
                                            )),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -8,
                                      right: 4,
                                      child: Container(
                                        child: TextButton(
                                            onPressed: () {
                                              // Navigator.pushReplacementNamed(context, '/edit-visits');
                                            },
                                            child: const Text(
                                              "2/18/2023 - 2pm",
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.black),
                                            )),
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  height: 10,
                                ),
                                Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Color(0x20808080),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 18.0, vertical: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: const BoxDecoration(
                                                    color: Colors.orangeAccent,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                200))),
                                                child: const Icon(
                                                  Icons.home,
                                                  size: 35,
                                                  color: Color(0xffffffff),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 18),
                                                child: SizedBox(
                                                  width: isMobile(context)
                                                      ? screenWidth / 1.9
                                                      : 220,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            "William Stephen",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    Colors.black,
                                                                fontSize: 20),
                                                          )),
                                                      Container(height: 8),
                                                      const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            "Address: 1062 Star Route, Wheeling, IL, 60090",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color:
                                                                    Colors.black,
                                                                fontSize: 12),
                                                          )),
                                                      const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            "Phone: (123) 554-8876",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color:
                                                                    Colors.black,
                                                                fontSize: 12),
                                                          )),
                                                      const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            "Email: michael@example.com",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color:
                                                                    Colors.black,
                                                                fontSize: 12),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        width: 33,
                                        height: 33,
                                        decoration: const BoxDecoration(
                                            color: Color(0xff3779EF),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(200))),
                                        child: TextButton(
                                            onPressed: () {
                                              // Navigator.pushReplacementNamed(context, '/edit-visits');
                                            },
                                            child: Image.asset(
                                              'assets/images/editPen.png',
                                              width: 15,
                                            )),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -8,
                                      right: 4,
                                      child: Container(
                                        child: TextButton(
                                            onPressed: () {
                                              // Navigator.pushReplacementNamed(context, '/edit-visits');
                                            },
                                            child: const Text(
                                              "2/18/2023 - 2pm",
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.black),
                                            )),
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  height: 10,
                                ),
                                Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Color(0x20808080),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 18.0, vertical: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: const BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                200))),
                                                child: const Icon(
                                                  Icons.home,
                                                  size: 35,
                                                  color: Color(0xffffffff),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 18),
                                                child: SizedBox(
                                                  width: isMobile(context)
                                                      ? screenWidth / 1.9
                                                      : 220,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            "Jayden Seales",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    Colors.black,
                                                                fontSize: 20),
                                                          )),
                                                      Container(height: 8),
                                                      const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            "Address: 1062 Star Route, Wheeling, IL, 60090",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color:
                                                                    Colors.black,
                                                                fontSize: 12),
                                                          )),
                                                      const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            "Phone: (123) 554-8876",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color:
                                                                    Colors.black,
                                                                fontSize: 12),
                                                          )),
                                                      const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            "Email: michael@example.com",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color:
                                                                    Colors.black,
                                                                fontSize: 12),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        width: 33,
                                        height: 33,
                                        decoration: const BoxDecoration(
                                            color: Color(0xff3779EF),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(200))),
                                        child: TextButton(
                                            onPressed: () {
                                              // Navigator.pushReplacementNamed(context, '/edit-visits');
                                            },
                                            child: Image.asset(
                                              'assets/images/editPen.png',
                                              width: 15,
                                            )),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -8,
                                      right: 4,
                                      child: Container(
                                        child: TextButton(
                                            onPressed: () {
                                              // Navigator.pushReplacementNamed(context, '/edit-visits');
                                            },
                                            child: const Text(
                                              "2/18/2023 - 2pm",
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.black),
                                            )),
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  height: 10,
                                ),
                                Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Color(0x20808080),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 18.0, vertical: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: const BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                200))),
                                                child: const Icon(
                                                  Icons.home,
                                                  size: 35,
                                                  color: Color(0xffffffff),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 18),
                                                child: SizedBox(
                                                  width: isMobile(context)
                                                      ? screenWidth / 1.9
                                                      : 220,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            "John Paul",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    Colors.black,
                                                                fontSize: 20),
                                                          )),
                                                      Container(height: 8),
                                                      const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            "Address: 1062 Star Route, Wheeling, IL, 60090",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color:
                                                                    Colors.black,
                                                                fontSize: 12),
                                                          )),
                                                      const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            "Phone: (123) 554-8876",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color:
                                                                    Colors.black,
                                                                fontSize: 12),
                                                          )),
                                                      const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            "Email: michael@example.com",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color:
                                                                    Colors.black,
                                                                fontSize: 12),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        width: 33,
                                        height: 33,
                                        decoration: const BoxDecoration(
                                            color: Color(0xff3779EF),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(200))),
                                        child: TextButton(
                                            onPressed: () {
                                              // Navigator.pushReplacementNamed(context, '/edit-visits');
                                            },
                                            child: Image.asset(
                                              'assets/images/editPen.png',
                                              width: 15,
                                            )),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -8,
                                      right: 4,
                                      child: Container(
                                        child: TextButton(
                                            onPressed: () {
                                              // Navigator.pushReplacementNamed(context, '/edit-visits');
                                            },
                                            child: const Text(
                                              "2/18/2023 - 2pm",
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.black),
                                            )),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                             */
                          ],
                        ),
                      ),

                      Container(
                        height: 20,
                      ),

                      //Enddd


                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
