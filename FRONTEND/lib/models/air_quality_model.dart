class AirQualityModel {
  final String city;
  final String country;
  final String airQuality;
  final String aqi;

  AirQualityModel({
    required this.city,
    required this.country,
    required this.airQuality,
    required this.aqi,
  });

  // Factory method untuk membuat instance dari Map (JSON)
  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    return AirQualityModel(
      city: json['data']['city'] ?? '',
      country: json['data']['country'] ?? '',
      airQuality: json['data']['current']['pollution']['aqius'].toString(),
      aqi: json['data']['current']['pollution']['aqiu'].toString(),
    );
  }
}
