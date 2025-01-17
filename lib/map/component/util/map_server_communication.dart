import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamasteps_frontend/login/screen/login_page.dart';
import 'package:mamasteps_frontend/map/model/route_model.dart';
import 'package:http/http.dart' as http;
import 'package:mamasteps_frontend/storage/login/login_data.dart';

List<Coordinate> convertMarkersToList(Set<Marker> markers) {
  return markers.map((marker) {
    return Coordinate(
      latitude: marker.position.latitude,
      longitude: marker.position.longitude,
    );
  }).toList();
}

Future<void> editRequestProfile(
  BuildContext context,
  totalSec,
  currentPosition,
  startClosewayPoints,
  endClosewayPoints,
    walkSpeed,
) async {
  const url = 'https://dev.mamasteps.dev/api/v1/routes/editRequestProfile';
  final AccessToken = await storage.read(key: 'access_token');
  List<Coordinate> redMarker;
  List<Coordinate> blueMarker;
  if(startClosewayPoints.isEmpty){
    redMarker = [];
  }
  else{
    redMarker = convertMarkersToList(startClosewayPoints);
  }
  if(endClosewayPoints.isEmpty){
    blueMarker = [];
  }
  else{
    blueMarker = convertMarkersToList(endClosewayPoints);
  }
  // List<Coordinate> redMarker = convertMarkersToList(startClosewayPoints);
  // List<Coordinate> blueMarker = convertMarkersToList(endClosewayPoints);

  var requestData = RequestData(
    targetTime: totalSec,
    walkSpeed: walkSpeed,
    origin: Coordinate(
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude),
    startCloseWaypoints: redMarker,
    endCloseWaypoints: blueMarker,
    createdAt: DateTime.now().toString(),
    updatedAt: DateTime.now().toString(),
  );

  Map<String, dynamic> jsonData = requestData.toJson();
  String jsonString = jsonEncode(jsonData);

  try {
    print(jsonString);
    final response = await http.patch(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $AccessToken',
      },
      body: jsonString,
    );

    print('editRequestProfile Server Response: ${response.statusCode}');
    print('editRequestProfile Server Response: ${response.body}');

    if (response.statusCode == 200) {
      print('success');
      // final jsonResponse = jsonDecode(response.body);
      // print(jsonResponse);
      // final ApiResponse apiResponse = ApiResponse.fromJson(jsonResponse);
      // return apiResponse;
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const GoogleLogin(),
        ),
        (route) => false,
      );
      return Future.error('editRequestProfile server error');
    }
  } catch (error) {
    return Future.error(error);
  }
}

Future<void> setOrigin(Position currentPosition) async {
  const url = 'https://dev.mamasteps.dev/api/v1/users/set-origin';
  final AccessToken = await storage.read(key: 'access_token');
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $AccessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'origin': {
          'latitude': currentPosition.latitude,
          'longitude': currentPosition.longitude,
        },
      }),
    );

    print('set-origin Server Response: ${response.statusCode}');
    print('set-origin Server Response: ${response.body}');

    if (response.statusCode == 200) {
      print('set-origin Server Response: ${response.statusCode}');
    } else {
      print('set-origin Server Error');
    }
  } catch (error) {
    print('set-origin Server Error : $error');
  }
}

Future<void> createRequestProfile() async {
  const url = 'https://dev.mamasteps.dev/api/v1/routes/createRequestProfile';
  final AccessToken = await storage.read(key: 'access_token');
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $AccessToken',
      },
    );

    print('createRequestProfile Server Response: ${response.statusCode}');
    print('createRequestProfile Server Response: ${response.body}');

    if (response.statusCode == 200) {
      print('createRequestProfile Server Response: ${response.statusCode}');
    } else {
      print('createRequestProfile Server Error');
    }
  } catch (error) {
    print('createRequestProfile Server Error : $error');
  }
}

Future<ApiResponse> getRoutes(BuildContext context) async {
  const url = 'https://dev.mamasteps.dev/api/v1/routes/getRoutes';
  final AccessToken = await storage.read(key: ACCESS_TOKEN_KEY);

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': 'Bearer $AccessToken',
      },
    );

    print('getRoutes Server Response: ${response.statusCode}');
    print('getRoutes Server Response: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final ApiResponse apiResponse = ApiResponse.fromJson(jsonResponse);
      return apiResponse;
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const GoogleLogin(),
        ),
        (route) => false,
      );
      return Future.error('getRoutes server error');
    }
  } catch (error) {
    return Future.error(error);
  }
}

Future<ApiResponse> computeRoutes(BuildContext context) async {
  const url = 'https://dev.mamasteps.dev/api/v1/routes/computeRoutes';
  final AccessToken = await storage.read(key: 'access_token');

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': 'Bearer $AccessToken',
      },
    );

    print('computeRoutes Server Response: ${response.statusCode}');
    print('computeRoutes Server Response: ${response.body}');

    if (response.statusCode == 200) {
      print('success');
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      final ApiResponse apiResponse = ApiResponse.fromJson(jsonResponse);
      return apiResponse;
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const GoogleLogin(),
        ),
        (route) => false,
      );
      return Future.error('computeRoutes server error');
    }
  } catch (error) {
    return Future.error(error);
  }
}

// Future<ApiResponse> makeRequest() async {
// // 더미테이터로 저장된 json 파일을 읽어와서 디코딩 하고 ApiResponse로 변환
//   try {
//     String jsonString = await rootBundle.loadString('asset/image/test.json');
//     final jsonResponse = jsonDecode(jsonString);
//     final ApiResponse apiResponse = ApiResponse.fromJson(jsonResponse);
//     return apiResponse;
//   } catch (error) {
//     print(error);
//     return Future.error(error);
//   }
// }

Future SaveRoute(data) async {
  const url = 'https://dev.mamasteps.dev/api/v1/routes/saveRoute';
  final AccessToken = await storage.read(key: ACCESS_TOKEN_KEY);
  Map<String, dynamic> jsonData = data.toJson();
  final jsonString = jsonEncode(jsonData);
  print(jsonString);
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $AccessToken',
      },
      body: jsonString,
    );

    print('SaveRoute Server Response: ${response.statusCode}');
    print('SaveRoute Server Response: ${response.body}');

    if (response.statusCode == 200) {
      print('SaveRoute Server Response: ${response.statusCode}');
    } else {
      print('SaveRoute Server Error');
    }
  } catch (error) {
    print('SaveRoute Server Error');
  }
}

Future<getRequestResponse> getRequestProfile(BuildContext context) async {
  const url = 'https://dev.mamasteps.dev/api/v1/routes/getRequestProfile';
  final AccessToken = await storage.read(key: 'access_token');

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': 'Bearer $AccessToken',
      },
    );

    print('getRequestProfile Server Response: ${response.statusCode}');
    print('getRequestProfile Server Response: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final getRequestResponse apiResponse =
          getRequestResponse.fromJson(jsonResponse);
      return apiResponse;
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const GoogleLogin(),
        ),
        (route) => false,
      );
      return Future.error('getRequestProfile server error');
    }
  } catch (error) {
    return Future.error(error);
  }
}

Future<void> optimizeSpeed(double distanceMeters, int completeTimeSeconds) async {
  const url = 'https://dev.mamasteps.dev/api/v1/optimize/optimize-speed';
  final AccessToken = await storage.read(key: 'access_token');

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $AccessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'distanceMeters': distanceMeters,
        'completeTimeSeconds': completeTimeSeconds,
      }),
    );

    print('optimize-speed Server Response: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('optimize-speed Server Response: ${response.statusCode}');
    } else {
      print('optimize-speed Server Error');
    }
  } catch (error) {
    print('optimize-speed Server Error : $error');
  }
}

Future<void> feedbackTime(int feedback) async {
  const url = 'https://dev.mamasteps.dev/api/v1/optimize/feedback-time';
  final AccessToken = await storage.read(key: 'access_token');

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $AccessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'feedback': feedback,
      }),
    );

    print('feedback-time Server Response: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('feedback-time Server Response: ${response.statusCode}');
    } else {
      print('feedback-time Server Error');
    }
  } catch (error) {
    print('feedback-time Server Error : $error');
  }
}
