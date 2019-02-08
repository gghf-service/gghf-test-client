import 'package:flutter/material.dart';
import 'package:gghf_test_client/gghf/subscription.dart';
import 'instance_id.dart';

class AddSubscription extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddSubscriptionState();
}

class _AddSubscriptionState extends State<AddSubscription> {
  final platform = TextEditingController();
  final appid = TextEditingController();
  final region = TextEditingController();

  @override
  void dispose() {
    platform.dispose();
    appid.dispose();
    region.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Subscription Info'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                hintText: 'Platform',
              ),
              controller: platform,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'App Id',
              ),
              controller: appid,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Region',
              ),
              controller: region,
            ),
            RaisedButton(
              onPressed: () async {
                final id = await instanceId();
                final sub = Subscription(
                  device: id,
                  platform: platform.text,
                  appid: appid.text,
                  region: region.text,
                );
                Navigator.pop(context, sub);
              },
              child: Text('Subscribe'),
            )
          ],
        ),
      ),
    );
  }
}
