import 'package:aioesphomeapi/aioesphomeapi.dart';

class ESPHomeAPI {
  static final ESPHomeAPI _instance = ESPHomeAPI._internal();
  factory ESPHomeAPI() => _instance;
  ESPHomeAPI._internal();

  final String host = "192.168.0.102";
  final int port = 6053;
  APIClient? _client;

  Future<void> connect() async {
    _client = APIClient(host, port, null);
    await _client?.connect(login: true);
  }

  Future<void> disconnect() async {
    await _client?.disconnect();
  }

  Future<void> dispenseFood() async {
    try {
      final entities = await _client?.listEntitiesServices();
      if (entities == null) throw Exception('No entities found');

      final services = entities.last;
      final stepperService = services.firstWhere(
        (service) => service.name == "stepper_control",
        orElse: () => throw Exception('Stepper service not found'),
      );

      await _client?.executeService(
        service: stepperService,
        data: {"target": 1500},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> activateBuzzer(int duration) async {
    try {
      final entities = await _client?.listEntitiesServices();
      if (entities == null) throw Exception('No entities found');

      final services = entities.last;
      final buzzerService = services.firstWhere(
        (service) => service.name == "start_buzzer",
        orElse: () => throw Exception('Buzzer service not found'),
      );

      await _client?.executeService(
        service: buzzerService,
        data: {"delay_time": duration},
      );
    } catch (e) {
      rethrow;
    }
  }
}
