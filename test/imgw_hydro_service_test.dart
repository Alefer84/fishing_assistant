import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

import 'package:fishing_assistant/services/imgw_hydro_service.dart';

const _kroscienkoJson = '''
[{"id_stacji":"149200160","stacja":"Krościenko","rzeka":"Dunajec",
"stan_wody":"191","stan_wody_data_pomiaru":"2026-06-15 07:50:00",
"temperatura_wody":"11.6","przeplyw":"29.8",
"przeplyw_data":"2026-06-15 08:10:00"}]
''';

const _golkowiceNoTempJson = '''
[{"id_stacji":"149200190","stacja":"Gołkowice","rzeka":"Dunajec",
"stan_wody":"161","stan_wody_data_pomiaru":"2026-06-15 08:00:00",
"temperatura_wody":null,"przeplyw":"33"}]
''';

const _jsonHeaders = {'content-type': 'application/json; charset=utf-8'};

void main() {
  test('parses a live IMGW reading with units and timestamp', () async {
    final service = ImgwHydroService(
      client: MockClient((req) async {
        expect(req.url.path, contains('149200160'));
        return http.Response(_kroscienkoJson, 200, headers: _jsonHeaders);
      }),
    );
    final station = ImgwHydroService.stationById('149200160');

    final reading = await service.fetchStation(station);

    expect(reading.isLive, isTrue);
    expect(reading.stationName, 'Krościenko');
    expect(reading.levelMeters, 191);
    expect(reading.levelUnit, 'cm');
    expect(reading.flowCfs, 29.8);
    expect(reading.flowUnit, 'm³/s');
    expect(reading.temperatureC, 11.6);
    expect(reading.recordedAt, DateTime(2026, 6, 15, 7, 50));
    expect(reading.normalFlowCfs, station.normalFlowCms);
  });

  test('handles a missing water temperature', () async {
    final service = ImgwHydroService(
      client: MockClient(
        (_) async =>
            http.Response(_golkowiceNoTempJson, 200, headers: _jsonHeaders),
      ),
    );

    final reading = await service.fetchStation(
      ImgwHydroService.stationById('149200190'),
    );

    expect(reading.temperatureC, isNull);
    expect(reading.flowCfs, 33);
  });

  test('throws on non-200 response', () async {
    final service = ImgwHydroService(
      client: MockClient((_) async => http.Response('error', 500)),
    );

    expect(
      () => service.fetchStation(ImgwHydroService.dunajecStations.first),
      throwsA(isA<ImgwException>()),
    );
  });
}
