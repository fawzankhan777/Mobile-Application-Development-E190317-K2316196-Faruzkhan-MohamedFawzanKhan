class Contact {
  int? id;
  String firstName;
  String middleName;
  String lastName;
  String country;
  int age;
  String address;
  String contact;

  Contact({
    this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.country,
    required this.age,
    required this.address,
    required this.contact,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'country': country,
      'age': age,
      'address': address,
      'contact': contact,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      firstName: map['first_name'],
      middleName: map['middle_name'],
      lastName: map['last_name'],
      country: map['country'],
      age: map['age'],
      address: map['address'],
      contact: map['contact'],
    );
  }
}
