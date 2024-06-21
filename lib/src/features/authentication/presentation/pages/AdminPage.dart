import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (kIsWeb)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/create_template');
                },
                child: Text('Create Template'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/saved_template');
              },
              child: Text('Saved Templates'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/company_detiles');
              },
              child: Text('Company detiles'),
            ),
          ],
        ),
      ),
    );
  }
}
