import 'package:flutter/material.dart';
import 'package:gghf_test_client/gghf/subscription.dart';
import 'package:gghf_test_client/gghf/api_client.dart';
import 'add_subscription.dart';

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

  @override
  void initState() {
    _refreshSubs();
    super.initState();
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
        Text(value, style: theme.title)
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
                      _cardRow(context, 'AppId', '${sub.appid}'),
                      _cardRow(context, 'Region', '${sub.region}'),
                    ],
                  ),
                ),
              );
            },
          ),
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
    );
    await _api.subscribe(subscription);
    setState(() {
      _subscriptions.add(subscription);
    });
  }

  Future<Null> _refreshSubs() {
    return _api.fetchSubscriptions('1234').then((subs) {
      setState(() {
        _subscriptions = subs;
      });
    });
  }
}
