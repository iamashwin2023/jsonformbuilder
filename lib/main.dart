import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jsontoformbuilder/src/features/authentication/presentation/pages/AdminPage.dart';
import 'package:jsontoformbuilder/src/features/authentication/presentation/pages/LoginPage.dart';
import 'package:jsontoformbuilder/src/features/authentication/presentation/pages/UserPage.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/pages/available_templates.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/pages/company_detiles.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/pages/create_template_screen.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/pages/saved_template_screen.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/pages/templates_with_data.dart';
import 'package:jsontoformbuilder/src/features/form_template/presentation/providers/data_source_provider.dart';
import 'package:provider/provider.dart';
import 'src/features/form_template/presentation/pages/preview_create_template_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataSourceProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Form App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/admin': (context) => AdminPage(),
        '/create_template': (context) => CreateTemplateScreen(),
        '/saved_template': (context) => SavedTemplateScreen(),
        '/company_detiles': (context) => CompanyDetiles(),
        '/user': (context) => UserPage(),
        '/AvailableTemplates': (context) => AvailableTemplatesScreen(),
        '/templatesWithData': (context) => TemplatesWithData(),
      },
    );
  }
}
