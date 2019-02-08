import 'package:http/http.dart' as http;
import 'subscription.dart';
import 'dart:convert';

class ApiClient {
  static final String _baseUrl = 'http://127.0.0.1:5000/';
  static final String _subscriptionResource = _baseUrl + 'subscriber';
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

  void removeSubscription(Subscription subscription) async {
    final request = http.Request('DELETE', Uri.parse(_subscriptionResource));
    request.bodyFields = subscription.toJson();
    await client.send(request);
  }
}
