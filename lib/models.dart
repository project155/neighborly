// models.dart
class Camp {
  String id;
  String name;
  String description;
  String address;
  double latitude;
  double longitude;
  List<String> imageUrls;
  int peopleCount;
  List<Person> peopleList;

  Camp({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.peopleCount,
    required this.peopleList,
  });
}

class Person {
  String id;
  String name;
  int age;
  String additionalInfo;
  String campId;

  Person({
    required this.id,
    required this.name,
    required this.age,
    required this.additionalInfo,
    required this.campId,
  });
}
