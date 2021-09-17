class Biometrics {
  String temperature;
  String breathingRate;
  String date;
  Biometrics({this.breathingRate, this.temperature, this.date});
  static List<Biometrics> fromFirebase(List<dynamic> list) {
    List<Biometrics> bioList = [];
    for (int i = 0; i < list.length; i += 3) {
      bioList.add(Biometrics(
          breathingRate: list[i],
          temperature: list[i + 1],
          date: (i / 3).toString()));
    }
    return bioList;
  }

  static List<String> toFirebase(List<Biometrics> list) {
    List<String> bioList = [];
    for (var bio in list) {
      bioList.add(bio.breathingRate);
      bioList.add(bio.temperature);
      bioList.add(bio.date.toString());
    }
    return bioList;
  }
}
