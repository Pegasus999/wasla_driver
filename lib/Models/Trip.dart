import 'package:wasla_driver/Models/Driver.dart';
import 'package:wasla_driver/Models/User.dart';

class Trip {
  String id = '';
  String clientId = '';
  String? driverId;
  double pickUpLocationLatitude = 0;
  double pickUpLocationLongtitude = 0;
  double destinationLatitude = 0;
  double destinationLongtitude = 0;
  Driver? driver;
  int cost = 0;
  Client client;

  Trip(
      {required this.id,
      required this.clientId,
      required this.pickUpLocationLatitude,
      required this.pickUpLocationLongtitude,
      required this.cost,
      required this.destinationLatitude,
      required this.client,
      required this.destinationLongtitude,
      this.driverId,
      this.driver});

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
        clientId: json['clientId'],
        cost: json['cost'],
        destinationLatitude: json['destinationLatitude'],
        destinationLongtitude: json['destinationLongtitude'],
        id: json['id'],
        driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
        client: Client.fromJson(json['client']),
        pickUpLocationLatitude: json['pickUpLocationLatitude'],
        pickUpLocationLongtitude: json['pickUpLocationLongtitude'],
        driverId: json['driverId']);
  }
}
