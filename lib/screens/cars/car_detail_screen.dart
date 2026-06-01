import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/car.dart';
import '../../models/review.dart';
import '../../services/api_exception.dart';
import '../../services/booking_service.dart';
import '../../services/car_service.dart';
import '../../state/session_controller.dart';

class CarDetailScreen extends StatefulWidget {
  const CarDetailScreen({
    super.key,
    required this.carId,
    required this.carService,
    required this.bookingService,
    required this.sessionController,
  });

  final String carId;
  final CarService carService;
  final BookingService bookingService;
  final SessionController sessionController;

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  Car? _car;
  List<ReviewItem> _reviews = [];
  bool _loading = true;
  bool _bookingLoading = false;
  bool _reviewLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;
  int _rating = 5;
  final _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_car == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Car not found')),
      );
    }

    final car = _car!;
    final gallery = car.images.isNotEmpty
        ? car.images
        : (car.image == null ? <String>[] : [car.image!]);
    final canBook =
        widget.sessionController.isAuthenticated &&
        widget.sessionController.user?.role != 'admin';

    return Scaffold(
      appBar: AppBar(title: Text('${car.brand} ${car.model}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (gallery.isNotEmpty)
            SizedBox(
              height: 220,
              child: PageView.builder(
                itemCount: gallery.length,
                itemBuilder: (_, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(gallery[index], fit: BoxFit.cover),
                ),
              ),
            )
          else
            Container(
              height: 220,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.directions_car, size: 56),
            ),
          const SizedBox(height: 16),
          Text(
            '${car.brand} ${car.model}',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            '${car.year} • ${car.transmission} • ${car.fuelType} • ${car.seats} seats',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Text(
            '\$${car.pricePerDay.toStringAsFixed(2)} / day',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _InfoCard(car: car),
          const SizedBox(height: 16),
          if (canBook)
            _BookingCard(
              onPickStart: _pickStart,
              onPickEnd: _pickEnd,
              startDate: _startDate,
              endDate: _endDate,
              loading: _bookingLoading,
              onBook: _book,
              pricePerDay: car.pricePerDay,
            )
          else
            _authPrompt(context),
          const SizedBox(height: 16),
          _ReviewComposer(
            authenticated: widget.sessionController.isAuthenticated,
            rating: _rating,
            controller: _reviewController,
            loading: _reviewLoading,
            onRatingChanged: (v) => setState(() => _rating = v),
            onSubmit: _submitReview,
          ),
          const SizedBox(height: 16),
          Text(
            'Reviews',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (_reviews.isEmpty)
            const Text('No reviews yet.')
          else
            ..._reviews.map(
              (review) => Card(
                elevation: 0,
                child: ListTile(
                  title: Text(review.userName),
                  subtitle: Text(
                    review.comment?.isNotEmpty == true
                        ? review.comment!
                        : 'No comment',
                  ),
                  trailing: Text('${review.rating}★'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        widget.carService.getById(widget.carId),
        widget.carService.getReviews(widget.carId),
      ]);
      setState(() {
        _car = results[0] as Car;
        _reviews = results[1] as List<ReviewItem>;
      });
    } catch (_) {
      setState(() => _car = null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _endDate ??
          (_startDate ?? DateTime.now().add(const Duration(days: 2))),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _book() async {
    if (_startDate == null || _endDate == null) {
      _toast('Pick both dates');
      return;
    }
    if (!_endDate!.isAfter(_startDate!) &&
        !_endDate!.isAtSameMomentAs(_startDate!)) {
      _toast('End date must be after start date');
      return;
    }
    setState(() => _bookingLoading = true);
    try {
      await widget.bookingService.create(
        carId: widget.carId,
        startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
        endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking created')));
      }
    } on ApiException catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast('Booking failed');
    } finally {
      if (mounted) setState(() => _bookingLoading = false);
    }
  }

  Future<void> _submitReview() async {
    if (!widget.sessionController.isAuthenticated) {
      _toast('Login first');
      return;
    }
    setState(() => _reviewLoading = true);
    try {
      await widget.carService.createReview(
        widget.carId,
        rating: _rating,
        comment: _reviewController.text.trim(),
      );
      _reviewController.clear();
      final reviews = await widget.carService.getReviews(widget.carId);
      setState(() => _reviews = reviews);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Review added')));
      }
    } on ApiException catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast('Review failed');
    } finally {
      if (mounted) setState(() => _reviewLoading = false);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _authPrompt(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text('Login to book this car.'),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text('Owner: ${car.owner?.name ?? 'Unknown'}'),
            Text('Status: ${car.status}'),
            Text(
              'Rating: ${car.averageRating.toStringAsFixed(1)} (${car.reviewsCount} reviews)',
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.onPickStart,
    required this.onPickEnd,
    required this.startDate,
    required this.endDate,
    required this.loading,
    required this.onBook,
    required this.pricePerDay,
  });

  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool loading;
  final VoidCallback onBook;
  final double pricePerDay;

  @override
  Widget build(BuildContext context) {
    final days = (startDate != null && endDate != null)
        ? endDate!.difference(startDate!).inDays + 1
        : 0;
    final total = days > 0 ? days * pricePerDay : 0;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book this car',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPickStart,
                    child: Text(
                      startDate == null
                          ? 'Pick start date'
                          : DateFormat('yyyy-MM-dd').format(startDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPickEnd,
                    child: Text(
                      endDate == null
                          ? 'Pick end date'
                          : DateFormat('yyyy-MM-dd').format(endDate!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Days: $days'),
            Text('Total: \$${total.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: loading ? null : onBook,
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Request booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewComposer extends StatelessWidget {
  const _ReviewComposer({
    required this.authenticated,
    required this.rating,
    required this.controller,
    required this.loading,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  final bool authenticated;
  final int rating;
  final TextEditingController controller;
  final bool loading;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Write a review',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (!authenticated)
              const Text('Login to add a review.')
            else ...[
              Row(
                children: List.generate(5, (index) {
                  final selected = index < rating;
                  return IconButton(
                    onPressed: () => onRatingChanged(index + 1),
                    icon: Icon(
                      selected ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  );
                }),
              ),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Comment',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: loading ? null : onSubmit,
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit review'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
