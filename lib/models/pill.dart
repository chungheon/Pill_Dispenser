enum IngestType { afterMeal, beforeMeal }

class Pill {
  Pill({this.pill, this.ingestType, this.frequency, this.amount});
  String? pill;
  IngestType? ingestType;
  int? frequency;
  int? amount;

  Pill.fromJson(Map<String, dynamic> json) {
    pill = json['pill'] == '' ? null : json['pill'];
    frequency = json['frequency'] == 0 ? null : json['frequency'];
    amount = json['amount'] == 0 ? null : json['amount'];
    ingestType = json['ingestType'] == -1
        ? null
        : IngestType.values[json['ingestType'] % 2];
  }

  Map<String, dynamic> toMap() {
    return {
      'pill': pill ?? '',
      'frequency': frequency ?? 0,
      'amount': amount ?? 0,
      'ingestType': ingestType?.index ?? -1,
    };
  }
}
