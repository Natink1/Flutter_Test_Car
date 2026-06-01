import '../models/car.dart';
import '../models/review.dart';
import 'api_client.dart';

class CarsPage {
  final List<Car> items;
  final int? nextPage;

  CarsPage({required this.items, required this.nextPage});
}

class CarService {
  final ApiClient _api;

  CarService(this._api);

  Future<CarsPage> list({Map<String, dynamic>? filters, int page = 1}) async {
    final query = <String, dynamic>{...?filters, 'page': page};
    final data = await _api.get('/cars', query: query);
    if (data is Map<String, dynamic> && data['data'] is List) {
      final items = (data['data'] as List)
          .map((e) => Car.fromJson(e as Map<String, dynamic>))
          .toList();
      return CarsPage(
        items: items,
        nextPage: data['next_page_url'] == null ? null : page + 1,
      );
    }
    if (data is List) {
      return CarsPage(
        items: data
            .map((e) => Car.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextPage: null,
      );
    }
    return CarsPage(items: const [], nextPage: null);
  }

  Future<List<Car>> featured() async {
    final data = await _api.get('/cars', query: {'featured': 1});
    if (data is List) {
      return data.map((e) => Car.fromJson(e as Map<String, dynamic>)).toList();
    }
    return const [];
  }

  Future<Car> getById(String id) async {
    final data = await _api.get('/cars/$id');
    return Car.fromJson(data as Map<String, dynamic>);
  }

  Future<List<ReviewItem>> getReviews(String id) async {
    final data = await _api.get('/cars/$id/reviews');
    if (data is List) {
      return data
          .map((e) => ReviewItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  Future<ReviewItem> createReview(
    String id, {
    required int rating,
    String? comment,
  }) async {
    final data = await _api.post(
      '/cars/$id/reviews',
      body: {'rating': rating, 'comment': comment ?? ''},
      auth: true,
    );
    return ReviewItem.fromJson(data as Map<String, dynamic>);
  }
}
