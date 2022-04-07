import 'client.dart';
import 'models/api_auth.dart';

abstract class Break {
  static const _endpoint =
      'DeliveryMediumApp/deliverymedium/fmlm/mobile/mark/break';

  static Future<void> setBreak(ApiAuth auth, bool status) async {
    final request = ApiRequest(
      _endpoint,
      apiAuth: auth,
      body: '{isOnBreakFl: $status}',
    );

    final client = ApiClient();
    final response = await client.put(request);

    response.throwOnError();
  }
}
