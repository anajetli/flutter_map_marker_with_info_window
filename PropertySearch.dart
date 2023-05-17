import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ameripro_app/partials/Drawer.dart';
import 'package:ameripro_app/partials/UserTopMenu.dart';
import 'package:flutter/services.dart';
import '../partials/AppbarGlobalFunc.dart';

import 'package:ameripro_app/models/AppData.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../partials/AppbarGlobalFunc.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart' as FGPH;
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geocoding/geocoding.dart' as GEO;

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

const kGoogleApiKey = AppData.kGoogleApiKey;

class PropertySearch extends StatefulWidget {
  const PropertySearch({Key? key}) : super(key: key);

  @override
  State<PropertySearch> createState() => _PropertySearchState();
}

class OpportunityInd {
  final int id;
  final String name;

  OpportunityInd({
    required this.id,
    required this.name,
  });
}

class _PropertySearchState extends State<PropertySearch> {

  static List<OpportunityInd> indOpt = [
    OpportunityInd(id: 2, name: "Aluminum Siding"),
    OpportunityInd(id: 3, name: "Old"),
    OpportunityInd(id: 4, name: "Damaged"),
    OpportunityInd(id: 5, name: "Flat Roof"),
  ];
  final _items = indOpt
      .map((indOpt) => MultiSelectItem<OpportunityInd>(indOpt, indOpt.name))
      .toList();
  List<OpportunityInd> _selectedAnimals2 = [];
  List<OpportunityInd> _selectedAnimals3 = [];
  List<OpportunityInd> _selectedAnimals5 = [];
  final _multiSelectKey = GlobalKey<FormFieldState>();

  final globalKey = GlobalKey<ScaffoldState>();

  /***** ***** ***** ***** *****/
  /***** Search Address - Start *****/
  /***** ***** ***** ***** *****/
  bool showSpinner = false;
  List<dynamic> searchedProperty = [];
  late List<String> fullAddress;
  late GEO.Placemark addLocation;
  FocusNode a1 = FocusNode();
  final txtAddress = TextEditingController();


  Future<GEO.Placemark> _getAddressFromLatLng(lat, lang) async {
    late GEO.Placemark place;
    //print(fullAddress);
    await GEO
        .placemarkFromCoordinates(lat, lang)
        .then((List<GEO.Placemark> placemarks) {
      place = placemarks[0];
      setState(() {
        addLocation = place;
        //print('${addLocation.name}, ${addLocation.locality}, ${addLocation.administrativeArea}, ${addLocation.postalCode}');
      });
    }).catchError((e) {
      debugPrint(e);
    });
    return place;
  }
  /***** ***** ***** ***** *****/
  /***** Search Address - End *****/
  /***** ***** ***** ***** *****/

  bool btnAddNewProspect = false;
  bool btnAddNewLogActivity = false;

  String selectSourceHint = "Select Source";
  DropDownSource selectedSource = const DropDownSource('0', 'Select Source');
  List<DropDownSource> sources = <DropDownSource>[const DropDownSource('0', 'Select Source')];

  String selectReferralHint = "Select Referral Code";
  DropDownSource selectedReferral = const DropDownSource('0', 'Select Referral Code');
  List<DropDownSource> referrals = <DropDownSource>[const DropDownSource('0', 'Select Referral Code')];

  late List<dynamic> selectedProspect;

  String selectedProspectID = "0";
  String selectedPropertyID = "0";
  List<dynamic> noteHistory = [];
  List<dynamic> prospects = [];

  int Hour = 11;
  int Minute = 33;
  bool AM = false;
  int Hour_Sec = 11;
  int Minute_Sec = 33;
  bool AM_Sec = false;

  int logHour = 11;
  int logMinute = 33;
  bool logAM = false;

  var log_Date = "mm-dd-yyyy";
  var logDate = "mm-dd-yyyy";

  FocusNode n1 = FocusNode();
  final txtLogNote = TextEditingController();

  String selectedLogActivityTypeHint = "Select Activity Type";
  DropDownSource selectedLogActivity = const DropDownSource('0', 'Select Activity Type');
  List<DropDownSource> logActivities = <DropDownSource>[const DropDownSource('0', 'Select Activity Type')];


  String dropdownvalue_Src = 'Item 1';
  var items_Src = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
  ];
  String dropdownvalue_Ref = 'Item 1';
  var items_Ref = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
  ];

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

    // Log Activities
    List<dynamic> dataATs = [];
    var data = await AppData.getStoredData('_prospect_activity_type');
    if (data.toString() == 'null' || data.toString() == '[{}]') {
      dataATs = await AppData.getProspectActivityType();
    }else{
      dataATs = jsonDecode(data);
    }
    for (var d in dataATs) {
      setState(() {
        logActivities.add(DropDownSource(d['id'], d['name']));
      });
    }



    // Sources
    dataATs = [];
    data = await AppData.getStoredData('_source');
    if (data.toString() == 'null' || data.toString() == '[{}]') {
      dataATs = await AppData.getJobSource();
    }else{
      dataATs = jsonDecode(data);
    }
    for (var d in dataATs) {
      setState(() {
        sources.add(DropDownSource(d['id'], d['name']));
      });
    }


    // Sources
    dataATs = [];
    data = await AppData.getStoredData('_referral');
    if (data.toString() == 'null' || data.toString() == '[{}]') {
      dataATs = await AppData.getJobSource();
    }else{
      dataATs = jsonDecode(data);
    }
    for (var d in dataATs) {
      setState(() {
        referrals.add(DropDownSource(d['id'], d['name']));
      });
    }



    setState(() {
      showSpinner = false;
    });
  }

  Future resetActivity() async {
    setState(() {
      showSpinner = true;
    });

    List<dynamic> res = await AppData.getProperty(
        fullAddress[0],
        fullAddress[fullAddress.length - 3],
        fullAddress[fullAddress.length - 2],
        addLocation.postalCode.toString());

    setState(() {
      searchedProperty = res;
      noteHistory = searchedProperty[0]['prospect_activity_log'];
      selectedProspectID = searchedProperty[0]['prospect'][0]['id'].toString();
      selectedPropertyID = searchedProperty[0]['prospect'][0]['propertyid'].toString();
    });

    setState(() {
      showSpinner = false;
    });
  }

  @override
  void dispose() {
    txtAddress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final _formKey = GlobalKey<FormState>();
    String lastDays = "Last 7 Days";
    var phoneCodeMaskFormatter = MaskTextInputFormatter(mask: '(###) ####-#####', filter: { "#": RegExp(r'[0-9]') });

    bool isDesktop(BuildContext context) =>
        MediaQuery.of(context).size.width >= 600;
    bool isMobile(BuildContext context) =>
        MediaQuery.of(context).size.width < 600;


    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        key: globalKey,
        backgroundColor: const Color(0xffffffff),
        resizeToAvoidBottomInset : true,
        endDrawer: MyDrawer(),
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
              child: Container(
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
                          UserTopMenu(),
                        ],
                      ),
                      if(isDesktop(context))
                        const Text("Property Search",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w500),
                        ),
                      IconButton(
                          padding: EdgeInsets.fromLTRB(0, 0, 20, 10),
                          constraints: BoxConstraints(),
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
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[




                Container(
                  width: screenWidth,
                  child: GridView.count(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: isMobile(context)==true ? 1 : 2,
                    childAspectRatio: isMobile(context)==true ? (1 / .26) : (1 / .3),
                    padding: EdgeInsets.symmetric(horizontal: 5,vertical: 0),
                    mainAxisSpacing: 0,
                    crossAxisSpacing: isMobile(context)==true ? 0 : 10,
                    children: [

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 0), //apply padding to all four sides
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Address",
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 0,
                                  color: Color(0x60202020),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),

                          ),
                          TextFormField(
                            controller: txtAddress,
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
                            onTap: () async {
                              Prediction? place = await FGPH.PlacesAutocomplete.show(
                                  context: context,
                                  apiKey: kGoogleApiKey,
                                  mode: FGPH.Mode.overlay,
                                  language: "en",
                                  components: [
                                    Component(Component.country, "us")
                                  ],
                                  onError: (err) {
                                    print(err);
                                  });

                              if (place != null) {
                                setState(() {
                                  txtAddress.text = place.description.toString();
                                  fullAddress = txtAddress.text.split(',');
                                });

                                //form google_maps_webservice package
                                final plist = GoogleMapsPlaces(
                                  apiKey: kGoogleApiKey,
                                  apiHeaders: await GoogleApiHeaders().getHeaders(),
                                  //from google_api_headers package
                                );

                                String placeid = place.placeId.toString();
                                final detail = await plist.getDetailsByPlaceId(placeid);
                                final geometry = detail.result.geometry!;
                                final lat = geometry.location.lat;
                                final lang = geometry.location.lng;

                                addLocation = await _getAddressFromLatLng(lat, lang);
                                //print(fullAddress[0] + ' ' + fullAddress[fullAddress.length-3] + ' ' + fullAddress[fullAddress.length-2] + ' ' + addLocation.postalCode.toString());

                                setState(() {
                                  showSpinner = true;
                                });


                                List<dynamic> res = await AppData.getProperty(
                                    fullAddress[0],
                                    fullAddress[fullAddress.length - 3],
                                    fullAddress[fullAddress.length - 2],
                                    addLocation.postalCode.toString());

                                print(res);

                                setState(() {
                                  btnAddNewLogActivity = false;
                                  prospects.clear();
                                  searchedProperty = res;
                                  showSpinner = false;
                                });

                                if(searchedProperty.isEmpty || searchedProperty.toString() == '[{}]'){
                                  ArtDialogResponse response =
                                  await ArtSweetAlert.show(
                                      barrierDismissible: false,
                                      context: context,
                                      artDialogArgs: ArtDialogArgs(
                                        showCancelBtn: false,
                                        denyButtonText: "Create New",
                                        title: "Do you want to submit this as a new property?",
                                        confirmButtonText: "Cancel",
                                      ));

                                  if (response == null) {
                                    return;
                                  }

                                  if (response.isTapConfirmButton) {
                                    print('cancel');
                                    return;
                                  }

                                  if (response.isTapDenyButton) {
                                    var resAdd = await AppData.addNewAddress(
                                        fullAddress[0],
                                        fullAddress[fullAddress.length - 3],
                                        fullAddress[fullAddress.length - 2],
                                        addLocation.postalCode.toString(),
                                        lat.toString(),
                                        lang.toString()
                                    );

                                    Address newProperty = resAdd;
                                    setState(() {
                                      selectedPropertyID = newProperty.id;
                                    });
                                    AppData.storeData('_fps_address', txtAddress.text);
                                    AppData.storeData('_fps_street', fullAddress[0]);
                                    AppData.storeData('_fps_city', fullAddress[fullAddress.length - 3]);
                                    AppData.storeData('_fps_state', fullAddress[fullAddress.length - 2]);
                                    AppData.storeData('_fps_zipcode', addLocation.postalCode.toString());
                                    AppData.storeData('_fps_lat', lat.toString());
                                    AppData.storeData('_fps_lng', lang.toString());

                                    ArtSweetAlert.show(
                                        context: context,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.success,
                                            title: "Address created"));
                                    return;
                                  }

                                  return;
                                }




                                // Address Exists BUT no Prospect
                                if(searchedProperty[0]['prospect'].length == 0){
                                  ArtDialogResponse response =
                                  await ArtSweetAlert.show(
                                      barrierDismissible: false,
                                      context: context,
                                      artDialogArgs: ArtDialogArgs(
                                        showCancelBtn: false,
                                        denyButtonText: "Start a new job",
                                        title: "would you like to start a new job?",
                                        confirmButtonText: "Cancel",
                                      ));

                                  if (response == null) {
                                    return;
                                  }

                                  if (response.isTapConfirmButton) {
                                    //print('cancel');
                                    return;
                                  }

                                  if (response.isTapDenyButton) {
                                    setState(() {
                                      //btnAddNewProspect = true;
                                      selectedPropertyID = searchedProperty[0]['id'];
                                    });
                                    AppData.storeData('_from_property_search', '1');
                                    AppData.storeData('_fps_address', txtAddress.text);
                                    AppData.storeData('_fps_street', fullAddress[0]);
                                    AppData.storeData('_fps_city', fullAddress[fullAddress.length - 3]);
                                    AppData.storeData('_fps_state', fullAddress[fullAddress.length - 2]);
                                    AppData.storeData('_fps_zipcode', addLocation.postalCode.toString());
                                    AppData.storeData('_fps_lat', lat.toString());
                                    AppData.storeData('_fps_lng', lang.toString());
                                    AppData.storeData('_fps_property_id', selectedPropertyID);

                                    AppData.storeData('_activity_newjob_movement', "0");
                                    AppData.storeData('_prospect_structure_trade', "[{}]");
                                    Navigator.pushReplacementNamed(context, '/job-profile');
                                    //print('create new');
                                    return;
                                  }

                                  return;
                                }


                                setState(() {
                                  btnAddNewLogActivity = true;
                                  noteHistory = searchedProperty[0]['prospect_activity_log'];
                                  selectedProspectID = searchedProperty[0]['prospect'][0]['id'].toString();
                                  selectedPropertyID = searchedProperty[0]['prospect'][0]['propertyid'].toString();
                                  prospects = searchedProperty[0]['prospect'];
                                });
                              }
                            },
                          ),
                        ],
                      ),

                      /*
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0,0,0,20),
                            child: Container(
                              width: isMobile(context) ? screenWidth : 100,
                              margin: isMobile(context) ? EdgeInsets.only(top: 0) : EdgeInsets.only(top: 40),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.white,
                                  padding: isMobile(context) ? EdgeInsets.fromLTRB(0, 15, 0, 15) : EdgeInsets.fromLTRB(0, 22, 0, 22),
                                  backgroundColor: const Color(0xff051C48),
                                  textStyle: const TextStyle(fontSize: 16, color: const Color(0xff000000)),
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                ),
                                onPressed: () async {
                                  await resetActivity();
                                },
                                child: const Text("Search"),
                              ),
                            ),
                          ),
                        ],
                      ),
                      */

                    ],
                  ),
                ),
                Container(
                  width: screenWidth,
                  child: GridView.count(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: isMobile(context)==true ? 1 : 2,
                    childAspectRatio: isMobile(context)==true ? (1 / .26) : (1 / .3),
                    padding: EdgeInsets.symmetric(horizontal: 5,vertical: 0),
                    mainAxisSpacing: 0,
                    crossAxisSpacing: isMobile(context)==true ? 0 : 10,
                    children: [
                      if (btnAddNewProspect) ...[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              //apply padding to all four sides
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Source",
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 0,
                                    color: Color(0x60202020),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xffF2F3F5),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                                ),
                                width: screenWidth,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 0),
                                  child: DropdownButton<DropDownSource>(
                                    isExpanded: true,
                                    underline: Container(),
                                    icon: RotationTransition(
                                      turns:
                                      new AlwaysStoppedAnimation(270 / 360),
                                      child: const Icon(
                                          Icons.arrow_back_ios_new_outlined,
                                          size: 18),
                                    ),
                                    value: selectedSource,
                                    onChanged: (DropDownSource? newValue) {
                                      setState(() {
                                        selectedSource = newValue!;
                                        //print(selectedSource.id + ' | ' + selectedSource.name);
                                      });
                                    },
                                    items: sources.map((DropDownSource jsource) {
                                      return DropdownMenuItem<DropDownSource>(
                                        value: jsource,
                                        child: Text(
                                          jsource.name,
                                          style:
                                          new TextStyle(color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                    hint: Text(selectSourceHint),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              //apply padding to all four sides
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Referral Code",
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 0,
                                    color: Color(0x60202020),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xffF2F3F5),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                                ),
                                width: screenWidth,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 0),
                                  child: DropdownButton<DropDownSource>(
                                    isExpanded: true,
                                    underline: Container(),
                                    icon: const RotationTransition(
                                      turns: AlwaysStoppedAnimation(270 / 360),
                                      child: Icon(
                                          Icons.arrow_back_ios_new_outlined,
                                          size: 18),
                                    ),
                                    value: selectedReferral,
                                    onChanged: (DropDownSource? newValue) {
                                      setState(() {
                                        selectedReferral = newValue!;
                                        //print(selectedReferral.id + ' | ' + selectedReferral.name);
                                      });
                                    },
                                    items:
                                    referrals.map((DropDownSource jsource) {
                                      return DropdownMenuItem<DropDownSource>(
                                        value: jsource,
                                        child: Text(
                                          jsource.name,
                                          style:
                                          new TextStyle(color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                    hint: Text(selectReferralHint),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isDesktop(context) == true)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                //apply padding to all four sides
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "",
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 0,
                                      color: Color(0x60202020),
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                              child: Container(
                                width: screenWidth,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    padding: isMobile(context)
                                        ? EdgeInsets.fromLTRB(0, 22, 0, 22)
                                        : EdgeInsets.fromLTRB(0, 22, 0, 22),
                                    backgroundColor: const Color(0xff051C48),
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        color: const Color(0xff000000)),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                  ),
                                  onPressed: () async {

                                    if (selectedSource.id == "0") {
                                      ArtSweetAlert.show(
                                          context: context,
                                          artDialogArgs: ArtDialogArgs(
                                              confirmButtonColor:
                                              const Color(0xff051C48),
                                              type: ArtSweetAlertType.danger,
                                              title: "Source is missing",
                                              text: "Please select Source"));
                                      return;
                                    }

                                    /*
                                                  if (selectedReferral.id == "0") {
                                                    ArtSweetAlert.show(
                                                        context: context,
                                                        artDialogArgs: ArtDialogArgs(
                                                            confirmButtonColor:
                                                                const Color(0xff051C48),
                                                            type: ArtSweetAlertType.danger,
                                                            title: "Referral is missing",
                                                            text: "Please select Referral"));
                                                    return;
                                                  }
                                                   */

                                    String propertyid = selectedPropertyID;
                                    String referralcodeid = selectedReferral.id;
                                    String leadsourceid = selectedSource.id;

                                    setState(() {
                                      showSpinner = true;
                                    });

                                    selectedProspect = await AppData.addNewProspect(propertyid, referralcodeid, leadsourceid);

                                    setState(() {
                                      selectedProspectID = selectedProspect[0]['id'].toString();
                                      showSpinner = false;

                                      btnAddNewProspect = false;
                                    });

                                    ArtSweetAlert.show(
                                        context: context,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.success,
                                            title: "New prospect created"));
                                  },
                                  child: const Text("Add new Prospect"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                    ],
                  ),
                ),


                const Padding(
                  padding: EdgeInsets.only(bottom: 5), //apply padding to all four sides
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Property Activity History",
                      style: TextStyle(
                        fontSize: 16,
                        height: 0,
                        color: Color(0x60202020),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),


                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black)),
                    child: Table(
                      columnWidths: {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(2),
                        3: FlexColumnWidth(6),
                      },
                      border: TableBorder.symmetric(
                        inside: BorderSide(
                          width: 1,
                          color: Colors.black,
                        ),
                      ),
                      defaultVerticalAlignment:
                      TableCellVerticalAlignment.middle,
                      children: [
                        //Table Head
                        TableRow(
                            decoration: BoxDecoration(color: Color(0x20000000)),
                            children: [
                              Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 5),
                                    child: Text(
                                      "Date",
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                  )),
                              Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 5),
                                    child: Text(
                                      "Time",
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                  )),
                              Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 5),
                                    child: Text(
                                      "Type",
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                  )),
                              Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 5),
                                    child: Text(
                                      "Note",
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                  )),
                            ]),

                        //Table Body
                        for (var log in noteHistory) ...{
                          TableRow(children: [
                            Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 5),
                                  child: Text(
                                    log['activity_date'].toString(),
                                    style: TextStyle(fontSize: 15.0),
                                  ),
                                )),
                            Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 5),
                                  child: Text(
                                    log['activity_time'].toString(),
                                    style: TextStyle(fontSize: 15.0),
                                  ),
                                )),
                            Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 5),
                                  child: Text(
                                    log['activity_type'].toString(),
                                    style: TextStyle(fontSize: 15.0),
                                  ),
                                )),
                            Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 5),
                                  child: Text(
                                    log['note'].toString(),
                                    style: TextStyle(fontSize: 15.0),
                                  ),
                                )),
                          ]),
                        },
                        TableRow(children: [
                          Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 5),
                                child: Text(
                                  "",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )),
                          Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 5),
                                child: Text(
                                  "",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )),
                          Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 5),
                                child: Text(
                                  "",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )),
                          Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 5),
                                child: Text(
                                  "",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )),
                        ]),
                        TableRow(children: [
                          Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 5),
                                child: Text(
                                  "",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )),
                          Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 5),
                                child: Text(
                                  "",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )),
                          Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 5),
                                child: Text(
                                  "",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )),
                          Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 5),
                                child: Text(
                                  "",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )),
                        ]),
                        TableRow(children: [
                          Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 5),
                                child: Text(
                                  "",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )),
                          Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 5),
                                child: Text(
                                  "",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )),
                          Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 5),
                                child: Text(
                                  "",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )),
                          Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 5),
                                child: Text(
                                  "",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )),
                        ]),
                        TableRow(children: [
                          Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 5),
                                child: Text(
                                  "",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )),
                          Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 5),
                                child: Text(
                                  "",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )),
                          Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 5),
                                child: Text(
                                  "",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )),
                          Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 5),
                                child: Text(
                                  "",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )),
                        ]),
                      ],
                    ),
                  ),
                ),


                if(btnAddNewLogActivity) ... [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 0),
                        child: Container(
                          width: isMobile(context) ? screenWidth / 2.5 : 150,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              backgroundColor: const Color(0xff051C48),
                              textStyle: const TextStyle(
                                  fontSize: 16, color: const Color(0xff000000)),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                            ),
                            onPressed: () async {
                              if (selectedPropertyID == "0") {
                                ArtSweetAlert.show(
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                        confirmButtonColor:
                                        const Color(0xff051C48),
                                        type: ArtSweetAlertType.danger,
                                        title: "Address missing",
                                        text:
                                        "Please enter address"));
                                return;
                              }

                              showDialog(
                                context: context,
                                builder: (context) {
                                  String contentText = "Content of Dialog";
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return AlertDialog(
                                        content: SingleChildScrollView(
                                          child: Stack(
                                            children: <Widget>[
                                              Positioned(
                                                right: -40.0,
                                                top: -40.0,
                                                child: InkResponse(
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: CircleAvatar(
                                                    child: Icon(Icons.close),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                ),
                                              ),
                                              Form(
                                                key: _formKey,
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 5),
                                                      //apply padding to all four sides
                                                      child: Align(
                                                        alignment:
                                                        Alignment.centerLeft,
                                                        child: Text(
                                                          "Log Visit Notes",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              height: 0,
                                                              color: Color(
                                                                  0xff000000),
                                                              fontWeight:
                                                              FontWeight
                                                                  .w600),
                                                          textAlign:
                                                          TextAlign.left,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 20,
                                                    ),
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 5),
                                                      //apply padding to all four sides
                                                      child: Align(
                                                        alignment:
                                                        Alignment.centerLeft,
                                                        child: Text(
                                                          "Activity Type",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            height: 0,
                                                            color:
                                                            Color(0x97202020),
                                                          ),
                                                          textAlign:
                                                          TextAlign.left,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                      EdgeInsets.all(1.0),
                                                      child: Container(
                                                        height: 35,
                                                        width: screenWidth,
                                                        decoration:
                                                        const BoxDecoration(
                                                          color:
                                                          Color(0xffF2F3F5),
                                                          borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8)),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              vertical: 0,
                                                              horizontal: 10),
                                                          child:
                                                          DropdownButtonHideUnderline(
                                                            child: DropdownButton(
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0x90000000),
                                                                fontSize: 12,
                                                              ),
                                                              value:
                                                              selectedLogActivity,
                                                              onChanged:
                                                                  (DropDownSource?
                                                              newValue) {
                                                                setState(() {
                                                                  selectedLogActivity =
                                                                  newValue!;
                                                                  //print(selectedSource.id + ' | ' + selectedSource.name);
                                                                });
                                                              },
                                                              items: logActivities
                                                                  .map((DropDownSource
                                                              jsource) {
                                                                return DropdownMenuItem<
                                                                    DropDownSource>(
                                                                  value: jsource,
                                                                  child: Text(
                                                                    jsource.name,
                                                                    style: new TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                );
                                                              }).toList(),
                                                              hint: Text(
                                                                  selectedLogActivityTypeHint),
                                                              /*
                                                                value: followUpdate,
                                                                icon: const Icon(Icons.keyboard_arrow_down),
                                                                items: items.map((String items) {
                                                                  return DropdownMenuItem(
                                                                    value: items,
                                                                    child: Text(items),
                                                                  );
                                                                }).toList(),
                                                                onChanged: (String? newValue) {
                                                                  setState(() {
                                                                    followUpdate = newValue!;
                                                                  });
                                                                },

                                                                 */
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 15,
                                                    ),

                                                    TextField(
                                                      focusNode: n1,
                                                      controller: txtLogNote,
                                                      maxLines: 2,
                                                      //or null
                                                      style: TextStyle(
                                                        color: Color(0x90000000),
                                                        fontSize: 12,
                                                      ),
                                                      decoration: InputDecoration(
                                                        hintText: "Note",
                                                        hintStyle: TextStyle(
                                                            fontSize: 12,
                                                            fontFamily:
                                                            'AvenirLight',
                                                            color: Color(
                                                                0x60000000)),
                                                        contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 15),
                                                        labelStyle: TextStyle(
                                                          color:
                                                          Color(0xff051C48),
                                                          fontSize: 11,
                                                          fontFamily:
                                                          'AvenirLight',
                                                        ),
                                                        filled: true,
                                                        fillColor:
                                                        Color(0x10000000),
                                                        floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .always,
                                                        labelText: "",
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 5,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 0,
                                                          horizontal: 0),
                                                      child: Container(
                                                        width: 100,
                                                        margin: EdgeInsets.only(
                                                            top: 10),
                                                        child: TextButton(
                                                          style: TextButton
                                                              .styleFrom(
                                                            primary: Colors.white,
                                                            padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 5,
                                                                horizontal:
                                                                10),
                                                            backgroundColor:
                                                            const Color(
                                                                0xff051C48),
                                                            textStyle: const TextStyle(
                                                                fontSize: 16,
                                                                color: const Color(
                                                                    0xff000000)),
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                    .circular(
                                                                    5))),
                                                          ),
                                                          onPressed: () async {
                                                            if (selectedLogActivity
                                                                .id ==
                                                                "0") {
                                                              ArtSweetAlert.show(
                                                                  context:
                                                                  context,
                                                                  artDialogArgs: ArtDialogArgs(
                                                                      confirmButtonColor:
                                                                      const Color(
                                                                          0xff051C48),
                                                                      type: ArtSweetAlertType
                                                                          .danger,
                                                                      title:
                                                                      "Activity Type missing",
                                                                      text:
                                                                      "Please select activity type"));
                                                              return;
                                                            }

                                                            if (txtLogNote.text ==
                                                                "") {
                                                              ArtSweetAlert.show(
                                                                  context:
                                                                  context,
                                                                  artDialogArgs: ArtDialogArgs(
                                                                      confirmButtonColor:
                                                                      const Color(
                                                                          0xff051C48),
                                                                      type: ArtSweetAlertType
                                                                          .danger,
                                                                      title:
                                                                      "Note missing",
                                                                      text:
                                                                      "Please enter note"));
                                                              return;
                                                            }

                                                            setState(() {
                                                              showSpinner = true;
                                                            });

                                                            var res = await AppData.addPropertyLogActivity(
                                                                selectedPropertyID,
                                                                selectedLogActivity.id,
                                                                txtLogNote.text);

                                                            setState(() {
                                                              noteHistory = res;
                                                              log_Date = "mm-dd-yyyy";
                                                              txtLogNote.text = "";
                                                              showSpinner = false;
                                                            });

                                                            Navigator.pop(
                                                                context);

                                                            await resetActivity();

                                                            ArtSweetAlert.show(
                                                                context: context,
                                                                artDialogArgs: ArtDialogArgs(
                                                                    type: ArtSweetAlertType
                                                                        .success,
                                                                    title:
                                                                    "Log Activity added"));
                                                            // Navigator.pushReplacementNamed(context, '/dashboard');
                                                          },
                                                          child: const Text(
                                                            "Submit",
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            child: const Text(
                              "Log Activity (+)",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                Container(height:30),
                const Padding(
                  padding: EdgeInsets.only(bottom: 5), //apply padding to all four sides
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Job History",
                      style: TextStyle(
                        fontSize: 16,
                        height: 0,
                        color: Color(0x60202020),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),





                Container(
                  width: screenWidth,
                  child: GridView.count(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: isMobile(context)==true ? 1 : 3,
                    childAspectRatio: isMobile(context)==true ? (1 / .18) : (1 / .3),
                    padding: EdgeInsets.symmetric(horizontal: 5,vertical: 0),
                    mainAxisSpacing: 0,
                    crossAxisSpacing: isMobile(context)==true ? 0 : 10,
                    children: [


                      for(var prospect in prospects) ... {
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: screenWidth,
                              decoration: BoxDecoration(
                                  color: Color(0x10000000),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(5))
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                child: Text(
                                  "${prospect['userid']} - ${prospect['user_name']} - ${prospect['source_name']} ${prospect['job_date']}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 0,
                                    color: Color(0xff202020),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ],
                        ),
                      },
                    ],
                  ),
                ),




                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 0),
                      child: Container(
                        width: isMobile(context) ? screenWidth/2.5 : 150,
                        margin: EdgeInsets.fromLTRB(5, 10, 0, 0),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                            backgroundColor: const Color(0xff051C48),
                            textStyle: const TextStyle(fontSize: 16, color: const Color(0xff000000)),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          ),
                          onPressed: () async {
                            if (txtAddress.text.isEmpty) {
                              ArtSweetAlert.show(
                                  context: context,
                                  artDialogArgs: ArtDialogArgs(
                                      confirmButtonColor: const Color(0xff051C48),
                                      type: ArtSweetAlertType.danger,
                                      title: "Address missing",
                                      text: "Please enter property address."));
                              return;
                            }
                            AppData.storeData('_from_property_search', '1');
                            AppData.storeData('_fps_property_id', selectedPropertyID);

                            AppData.storeData('_activity_newjob_movement', "0");
                            AppData.storeData('_prospect_structure_trade', "[{}]");
                            Navigator.pushReplacementNamed(context, '/job-profile');
                          },
                          child: const Text("Start A New Job (+)",style: TextStyle(fontSize: 12),),
                        ),
                      ),
                    ),
                  ],
                ),

              ],

            ),
          ),

        ),

      ),
    );
  }

}