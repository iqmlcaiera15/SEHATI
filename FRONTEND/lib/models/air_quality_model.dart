class AirQualityModel {
  final String status;
  final AirQualityData data;

  AirQualityModel({
    required this.status,
    required this.data,
  });

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    return AirQualityModel(
      status: json['status'],
      data: AirQualityData.fromJson(json['data']),
    );
  }
}

class AirQualityData {
  final String city;
  final String state;
  final String country;
  final Location location;
  final Current current;

  AirQualityData({
    required this.city,
    required this.state,
    required this.country,
    required this.location,
    required this.current,
  });

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    return AirQualityData(
      city: json['city'],
      state: json['state'],
      country: json['country'],
      location: Location.fromJson(json['location']),
      current: Current.fromJson(json['current']),
    );
  }
}

class Location {
  final String type;
  final List<double> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'],
      coordinates: List<double>.from(json['coordinates'].map((x) => x.toDouble())),
    );
  }
}

class Current {
  final Pollution pollution;
  final Weather weather;

  Current({
    required this.pollution,
    required this.weather,
  });

  factory Current.fromJson(Map<String, dynamic> json) {
    return Current(
      pollution: Pollution.fromJson(json['pollution']),
      weather: Weather.fromJson(json['weather']),
    );
  }
}

class Pollution {
  final String ts;
  final int aqius;
  final String mainus;
  final int aqicn;
  final String maincn;

  Pollution({
    required this.ts,
    required this.aqius,
    required this.mainus,
    required this.aqicn,
    required this.maincn,
  });

  factory Pollution.fromJson(Map<String, dynamic> json) {
    return Pollution(
      ts: json['ts'],
      aqius: json['aqius'],
      mainus: json['mainus'],
      aqicn: json['aqicn'],
      maincn: json['maincn'],
    );
  }
}

class Weather {
  final String ts;
  final String ic;
  final int hu;
  final int pr;
  final int tp;
  final int wd;
  final double ws;

  Weather({
    required this.ts,
    required this.ic,
    required this.hu,
    required this.pr,
    required this.tp,
    required this.wd,
    required this.ws,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      ts: json['ts'],
      ic: json['ic'],
      hu: json['hu'],
      pr: json['pr'],
      tp: json['tp'],
      wd: json['wd'],
      ws: json['ws'].toDouble(),
    );
  }
}