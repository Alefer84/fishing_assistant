import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fishing_assistant/providers/app_state.dart';
import 'package:fishing_assistant/screens/home_screen.dart';
import 'package:fishing_assistant/services/weather_service.dart';

const _weatherJson = '''
{"current":{"temperature_2m":14.2,"precipitation":0.0,
"weather_code":3,"wind_speed_10m":9.0}}
''';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home renders all dashboard sections', (tester) async {
    // Tall surface so the lazy ListView builds every section.
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockClient = MockClient(
      (req) async => http.Response(_weatherJson, 200),
    );
    final state = AppState(weatherService: WeatherService(client: mockClient));
    await state.init(autoRefresh: false);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fishing Score'), findsOneWidget);
    expect(find.text('Water Conditions'), findsOneWidget);
    expect(find.text('Weather'), findsOneWidget);
    expect(find.text('Moon'), findsOneWidget);
    expect(find.text("Today's Hatch"), findsOneWidget);
    expect(find.text('Recommended Flies'), findsOneWidget);
  });
}
