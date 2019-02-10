import 'package:flutter/material.dart';
import 'package:gghf_test_client/gghf/subscription.dart';
import 'package:gghf_test_client/gghf/api_client.dart';
import 'add_subscription.dart';
import 'instance_id.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GGHF Test Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'GGHF Test Client'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Subscription> _subscriptions = List();
  final _api = ApiClient();
  final _messaging = FirebaseMessaging();
  var endpoint = 'localhost:5000';
  final endpointController = TextEditingController();
  SharedPreferences prefs;

  @override
  void dispose() {
    endpointController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((p) {
      prefs = p;
      setState(() {
        endpointController.text =
            prefs.getString('endpoint') ?? 'localhost:5000';
        ApiClient.baseUrl = endpointController.text;
        _refreshSubs();
      });
    });
    initMessaging();
    super.initState();
  }

  void initMessaging() {
    _messaging.getToken().then((token) {
      showDialog(context: context, builder: (BuildContext context) {
        return Container(
          alignment: Alignment.center,
          child: Card(
            child: Text('Firebase FCM Token - $token'),
          ),
        );
      });
    });

    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        showDialog(context: context, builder: (BuildContext context) {
          return Container(
            alignment: Alignment.center,
            child: Card(
              child: Text('on message $message'),
            ),
          );
        });
      },
      onResume: (Map<String, dynamic> message) async {
        showDialog(context: context, builder: (BuildContext context) {
          return Container(
            alignment: Alignment.center,
            child: Card(
              child: Text('on resume $message'),
            ),
          );
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        showDialog(context: context, builder: (BuildContext context) {
          return Container(
            alignment: Alignment.center,
            child: Card(
              child: Text('on launch $message'),
            ),
          );
        });
      },
    );
  }

  Widget _cardRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        Text(
          label,
          style: theme.title,
        ),
        SizedBox(
          width: 8,
        ),
        Text(value, style: theme.title),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(hintText: 'Endpoint'),
              controller: endpointController,
              onChanged: (text) {
                ApiClient.baseUrl = text;
                prefs.setString('endpoint', text);
              },
            ),
            SizedBox(
              height: 8,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshSubs,
                child: ListView.builder(
                  itemCount: _subscriptions.length,
                  itemBuilder: (BuildContext context, int index) {
                    final sub = _subscriptions[index];
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: <Widget>[
                            _cardRow(context, 'Platform', '${sub.platform}'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                _cardRow(context, 'AppId', '${sub.appid}'),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      _subscriptions.removeAt(index);
                                    });
                                    _api.removeSubscription(sub);
                                    _messaging.unsubscribeFromTopic(sub.topic);
                                  },
                                ),
                              ],
                            ),
                            _cardRow(context, 'Region', '${sub.region}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSubscription,
        tooltip: 'Subscribe',
        child: Icon(Icons.add),
      ),
    );
  }

  void _addSubscription() async {
    final subscription = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddSubscription()),
    ) as Subscription;
    await _api.subscribe(subscription);
    setState(() {
      _subscriptions.add(subscription);
      _messaging.subscribeToTopic(subscription.topic);
    });
  }

  Future<Null> _refreshSubs() {
    return instanceId().then((id) {
      return _api.fetchSubscriptions(id).then((subs) {
        setState(() {
          _subscriptions = subs;
        });
      });
    });
  }
}
