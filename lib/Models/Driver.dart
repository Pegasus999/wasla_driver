class Driver {
  String id = '';
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';
  String licensePlate = '';
  String carBrand = '';
  String carName = '';
  int wilaya;
  bool active;
  iDriver type = iDriver.taxi;

  Driver(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.active,
      required this.wilaya,
      required this.phoneNumber,
      required this.licensePlate,
      required this.carBrand,
      required this.carName});

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
        id: json['id'],
        firstName: json['firstName'],
        wilaya: json['wilaya'],
        lastName: json['lastName'],
        active: json['active'],
        carBrand: json['carBrand'],
        licensePlate: json['licensePlate'],
        phoneNumber: json["phoneNumber"],
        carName: json['carName']);
  }
}

enum iDriver { taxi, tow }
