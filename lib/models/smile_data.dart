import 'dart:convert';

class SmileData {
  final String firstName;
  final String lastName;
  final String country;
  final String idNumber;
  final String idType;
  final String userId;
  final String? jobId;
  final String? tag;

  SmileData({
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.idNumber,
    required this.idType,
    required this.userId,
    this.jobId,
    this.tag,
  });

  SmileData copyWith({
    String? firstName,
    String? lastName,
    String? country,
    String? idNumber,
    String? idType,
    String? userId,
    String? jobId,
    String? tag,
  }) {
    return SmileData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      country: country ?? this.country,
      idNumber: idNumber ?? this.idNumber,
      idType: idType ?? this.idType,
      userId: userId ?? this.userId,
      jobId: jobId ?? this.jobId,
      tag: tag ?? this.tag,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'country': country,
      'idNumber': idNumber,
      'idType': idType,
      'userId': userId,
      'jobId': jobId,
      'tag': tag,
    };
  }

  factory SmileData.fromMap(Map<String, dynamic> map) {
    return SmileData(
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      country: map['country'] as String,
      idNumber: map['idNumber'] as String,
      idType: map['idType'] as String,
      userId: map['userId'] as String,
      jobId: map['jobId'] != null ? map['jobId'] as String : null,
      tag: map['tag'] != null ? map['tag'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SmileData.fromJson(String source) =>
      SmileData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SmileData(firstName: $firstName, lastName: $lastName, country: $country, idNumber: $idNumber, idType: $idType, userId: $userId, jobId: $jobId, tag: $tag)';
  }
}
