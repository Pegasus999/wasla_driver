import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:wasla_driver/Models/Driver.dart';
import 'package:wasla_driver/Models/Trip.dart';

class API {
  static String base_url = "https://wasla.online/api/";
  // static String base_url = "http://10.0.2.2:5000/api/";

  static Future login(BuildContext context, String phoneNumber) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final url = Uri.parse('${base_url}auth/loginDriver');
      final body = jsonEncode({'phoneNumber': phoneNumber.trim()});
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        Driver? user = Driver.fromJson(json["user"]);

        return user;
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("No such user")));
      }
    } catch (err) {
      print(err);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error occured")));
    }
  }

  static Future getTrips(BuildContext context, String id) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final url = Uri.parse('${base_url}driver/trips');
      final body = jsonEncode({"id": id});
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        List<Trip> trips = list.map((json) => Trip.fromJson(json)).toList();
        return trips;
      }
    } catch (err) {
      print(err);
      throw Exception("An error Occured");
    }
  }

  static Future getState(BuildContext context, String id) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final url = Uri.parse('${base_url}driver/state');
      final body = jsonEncode({"id": id});
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['active'];
      }
    } catch (err) {
      print(err);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error occured")));
      return false;
    }
  }

  static Future getIncome(BuildContext context, String id) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final url = Uri.parse('${base_url}driver/getIncome');
      final body = jsonEncode({"id": id});
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['active'];
      }
    } catch (err) {
      print(err);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error occured")));
      return false;
    }
  }

  static Future turnOn(BuildContext context, bool active, String id) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final url = Uri.parse('${base_url}driver/changeState');
      final body = jsonEncode({"id": id, 'active': active});
      final response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(active ? "You're Now Active" : "You're now offline")));
        return active;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Something wrong happened")));
        return !active;
      }
    } catch (err) {
      print(err);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error occured")));
      return !active;
    }
  }
}
