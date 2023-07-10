class SmileData {
  /// User's first name
  final String firstName;

  /// User's last name
  final String lastName;

  /// The country of issuance of the Identity Document
  final String country;

  /// identity Document Number
  final String idNumber;

  /// The type of Identity Document
  /// E.g DRIVERS_LICENSE, NATIONAL_ID, PASSPORT
  ///
  /// Find supported documents types for supported countries at
  /// https://docs.smileidentity.com/supported-id-types/for-individuals-kyc/backed-by-id-authority/supported-countries
  final String idType;

  /// User ID to associate the results of this job to.
  final String userId;

  /// A unique job ID. If not provided, a random job ID will be generated.
  final String? jobId;

  /// An identifier for the images that will be captured via selfie and/or
  /// document capture screens.
  ///
  /// If not provided, a random job tag will be generated.
  final String? tag;

  /// Learn more about job types at
  /// https://docs.smileidentity.com/integration-options/mobile/android/products-and-job-types
  final int jobType;

  /// Default is Environment.test. Don't forget to change it to Environment.prod
  /// when you're ready for production
  final Environment environment;

  /// Anything extra which you may need associated with the current job
  final Map<String, dynamic>? additionalValues;

  final CaptureType captureType;

  SmileData({
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.idNumber,
    required this.idType,
    required this.userId,
    required this.jobType,
    this.jobId,
    this.tag,
    this.environment = Environment.test,
    this.additionalValues,
    required this.captureType,
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
    int? jobType,
    Environment? environment,
    Map<String, dynamic>? additionalValues,
    CaptureType? captureType,
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
      jobType: jobType ?? this.jobType,
      environment: environment ?? this.environment,
      additionalValues: additionalValues ?? this.additionalValues,
      captureType: captureType ?? this.captureType,
    );
  }

  @override
  String toString() {
    return 'SmileData(firstName: $firstName, lastName: $lastName, country: $country, idNumber: $idNumber, idType: $idType, userId: $userId, jobId: $jobId, tag: $tag)';
  }

  Map<String, String> get captureParams {
    return <String, String>{
      "tag": tag!,
      "captureType": captureType.label,
    };
  }

  Map<String, dynamic> get submitParams {
    return <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'country': country,
      'idNumber': idNumber,
      'idType': idType,
      'userId': userId,
      'jobId': jobId!,
      'tag': tag!,
      'jobType': jobType,
      'environment': environment.label,
      'additionalValues': additionalValues,
      'captureType': captureType.label,
    };
  }
}

enum Environment {
  test("TEST"),
  prod("PROD"),
  ;

  final String label;
  const Environment(this.label);
}

enum CaptureType {
  selfie("SELFIE"),
  idCapture("ID_CAPTURE"),
  selfieAndIdCapture("SELFIE_AND_ID_CAPTURE"),
  idCaptureAndSelfie("ID_CAPTURE_AND_SELFIE"),
  ;

  final String label;
  const CaptureType(this.label);
}
