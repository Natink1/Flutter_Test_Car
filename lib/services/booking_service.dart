import '../models/booking.dart';
import 'api_client.dart';

class BookingService {
  final ApiClient _api;

  BookingService(this._api);

  Future<List<BookingItem>> list() async {
    final data = await _api.get('/bookings', auth: true);
    if (data is List) {
      return data
          .map((e) => BookingItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  Future<BookingItem> create({
    required String carId,
    required String startDate,
    required String endDate,
  }) async {
    final data = await _api.post(
      '/bookings',
      auth: true,
      body: {'car_id': carId, 'start_date': startDate, 'end_date': endDate},
    );
    return BookingItem.fromJson(data as Map<String, dynamic>);
  }

  Future<void> cancel(String id) async {
    await _api.patch('/bookings/$id/cancel', auth: true);
  }
}
