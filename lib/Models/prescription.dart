class Prescription {
  String name;
  String period;
  String amount;
  String notes;
  Prescription({this.name, this.amount, this.notes, this.period});
  static List<String> toFirebase(List<Prescription> prescriptionList) {
    List<String> list = [];
    for (Prescription prescription in prescriptionList) {
      list.add(prescription.name);
      list.add(prescription.period);
      list.add(prescription.amount);
      list.add(prescription.notes);
    }
    return list;
  }

  static List<Prescription> fromFirebase(List<dynamic> list) {
    if (list.length == 0) return null;
    List<Prescription> prescriptionList = [];
    for (int i = 0; i < list.length; i += 4) {
      prescriptionList.add(Prescription(
        name: list[i],
        period: list[i + 1],
        amount: list[i + 2],
        notes: list[i + 3],
      ));
    }
    return prescriptionList;
  }
}
