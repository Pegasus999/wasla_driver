import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wasla_driver/Constants.dart';
import 'package:wasla_driver/Models/Driver.dart';
import 'package:wasla_driver/Models/Trip.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wasla_driver/Services/API.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.user});
  final Driver user;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Trip> trips = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTrips();
  }

  getTrips() async {
    try {
      final list = await API.getTrips(context, widget.user.id);
      if (list != null) {
        setState(() {
          trips = list;
        });
      }
    } catch (e) {
      if (mounted) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text("ERROR"),
                  content: SizedBox(
                    height: 200,
                    child: Center(child: Text(e.toString())),
                  ),
                ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 60,
          color: Colors.black,
          child: const Center(
              child: Text(
            "History",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          )),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: trips.isNotEmpty
              ? ListView.separated(
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.transparent,
                    height: 40,
                  ),
                  itemBuilder: (context, index) => _trip(index),
                  itemCount: trips.length,
                )
              : const Center(
                  child: Text("You have no trips yet"),
                ),
        )
      ],
    );
  }

  _trip(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 250,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Constants.greenBack,
            borderRadius: BorderRadius.circular(30)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Constants.greenPop),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 23,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          // "${trips[index].client.firstName} ${trips[index].client.lastName}",
                          "Client Name",
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Constants.orangePop),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 23,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "0${trips[index].client.phoneNumber}",
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                showPopUp(index);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 150,
                    width: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Constants.greenPop),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.clock),
                        const SizedBox(height: 10),
                        const Text(
                          "Date / Time",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          trips.isNotEmpty
                              ? trips[index].date.split('T')[0]
                              : "",
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          trips.isNotEmpty
                              ? trips[index].date.split('T')[1].split('.')[0]
                              : "",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 150,
                    width: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Constants.greenPop),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.coins),
                        const SizedBox(height: 10),
                        Text(
                          "Cost",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "${trips[index].cost} DA",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 150,
                    width: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Constants.greenPop),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        FaIcon(FontAwesomeIcons.userClock),
                        const SizedBox(height: 10),
                        Text(
                          "Duration",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          trips.isNotEmpty && trips[index].duration != null
                              ? "${trips[index].duration!.split('.')[0]} min"
                              : "",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  showPopUp(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
          width: 200,
          height: 200,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${trips[index].client.firstName} ${trips[index].client.lastName}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Text(trips.isNotEmpty ? trips[index].date.split('T')[0] : ""),
              const SizedBox(height: 20),
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 30,
                child: IconButton(
                  onPressed: () {
                    openGoogleMaps(
                        LatLng(trips[index].pickUpLocationLatitude,
                            trips[index].pickUpLocationLongtitude),
                        LatLng(trips[index].destinationLatitude,
                            trips[index].destinationLongtitude));
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.route,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openGoogleMaps(LatLng point1, LatLng point2) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/${point1.latitude},${point1.longitude}/${point2.latitude},${point2.longitude}';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      await launchUrl(Uri.parse(
          "https://play.google.com/store/apps/details?id=com.google.android.apps.maps&pcampaignid=web_share"));
    }
  }
}
