class Client {
  String id = '';
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';

  Client(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.phoneNumber});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        phoneNumber: json['phoneNumber']);
  }

  toJson() {
    return {
      "id": id,
      "firstName": firstName,
      "lastName": lastName,
      "phoneNumber": phoneNumber,
    };
  }
}
