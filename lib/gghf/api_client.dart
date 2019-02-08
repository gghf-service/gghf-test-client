import 'package:http/http.dart' as http;
import 'subscription.dart';
import 'dart:convert';

class ApiClient {
  static String baseUrl = 'localhost:5000';
  static final String _subscriptionResource = baseUrl + '/subscriber';
  final client = http.Client();

  Future<List<Subscription>> fetchSubscriptions(String deviceId) async {
    final response = await client.get(_subscriptionResource + '/' + deviceId);
    final json = jsonDecode(response.body) as List;
    return json.map((f) => Subscription.fromJson(f)).toList();
  }

  void subscribe(Subscription subscription) async {
    final body = jsonEncode([subscription.toJson()]);
    await client.post(
      _subscriptionResource,
      body: body,
      headers: {'Content-type': 'application/json'},
    );
  }

  Future<http.StreamedResponse> removeSubscription(Subscription subscription) async {
    final body = jsonEncode([subscription.toJson()]);
    final request = http.Request('DELETE', Uri.parse(_subscriptionResource));
    request.body = body;
    request.headers['Content-type'] = 'application/json';
    return await client.send(request);
  }
}
