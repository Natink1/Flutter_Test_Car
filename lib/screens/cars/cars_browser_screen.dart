import 'package:flutter/material.dart';
import '../../models/car.dart';
import '../../services/car_service.dart';

class CarsBrowserScreen extends StatefulWidget {
  const CarsBrowserScreen({
    super.key,
    required this.carService,
    required this.onOpenCar,
    this.showFeaturedHeader = false,
  });

  final CarService carService;
  final ValueChanged<String> onOpenCar;
  final bool showFeaturedHeader;

  @override
  State<CarsBrowserScreen> createState() => _CarsBrowserScreenState();
}

class _CarsBrowserScreenState extends State<CarsBrowserScreen> {
  final _searchController = TextEditingController();
  final _brandController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  String _transmission = '';
  String _fuelType = '';
  String _seats = '';
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int? _nextPage;
  List<Car> _cars = [];
  List<Car> _featured = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _brandController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = _loading
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        : _error != null
        ? Center(child: Text(_error!))
        : _buildList(context);

    return RefreshIndicator(onRefresh: _refresh, child: content);
  }

  Widget _buildList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (widget.showFeaturedHeader) ...[
          Text(
            'Drive with confidence',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse approved cars from the backend API.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 18),
        ],
        _FilterCard(
          searchController: _searchController,
          brandController: _brandController,
          minPriceController: _minPriceController,
          maxPriceController: _maxPriceController,
          transmission: _transmission,
          fuelType: _fuelType,
          seats: _seats,
          onTransmissionChanged: (value) =>
              setState(() => _transmission = value ?? ''),
          onFuelTypeChanged: (value) => setState(() => _fuelType = value ?? ''),
          onSeatsChanged: (value) => setState(() => _seats = value ?? ''),
          onSearch: _refresh,
          onClear: _clearFilters,
        ),
        if (_featured.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Featured',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _featured.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final car = _featured[index];
                return SizedBox(
                  width: 280,
                  child: _CarCard(
                    car: car,
                    onTap: () => widget.onOpenCar(car.id),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cars',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              '${_cars.length} found',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_cars.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No cars found')),
          )
        else
          ..._cars.map(
            (car) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CarCard(car: car, onTap: () => widget.onOpenCar(car.id)),
            ),
          ),
        if (_nextPage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton(
              onPressed: _loadingMore ? null : _loadMore,
              child: _loadingMore
                  ? const CircularProgressIndicator()
                  : const Text('Load more'),
            ),
          ),
      ],
    );
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _error = null;
      _cars = [];
    });
    try {
      final results = await Future.wait([
        widget.carService.featured(),
        widget.carService.list(filters: _filters(), page: 1),
      ]);
      setState(() {
        _featured = results[0] as List<Car>;
        final page = results[1] as CarsPage;
        _cars = page.items;
        _nextPage = page.nextPage;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    await _loadInitial();
  }

  Future<void> _loadMore() async {
    if (_nextPage == null) return;
    setState(() => _loadingMore = true);
    try {
      final page = await widget.carService.list(
        filters: _filters(),
        page: _nextPage!,
      );
      setState(() {
        _cars = [..._cars, ...page.items];
        _nextPage = page.nextPage;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _clearFilters() async {
    _searchController.clear();
    _brandController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    setState(() {
      _transmission = '';
      _fuelType = '';
      _seats = '';
    });
    await _loadInitial();
  }

  Map<String, dynamic> _filters() {
    return {
      'q': _searchController.text.trim(),
      'brand': _brandController.text.trim(),
      'min_price': _minPriceController.text.trim(),
      'max_price': _maxPriceController.text.trim(),
      'transmission': _transmission,
      'fuel_type': _fuelType,
      'seats': _seats,
    };
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.searchController,
    required this.brandController,
    required this.minPriceController,
    required this.maxPriceController,
    required this.transmission,
    required this.fuelType,
    required this.seats,
    required this.onTransmissionChanged,
    required this.onFuelTypeChanged,
    required this.onSeatsChanged,
    required this.onSearch,
    required this.onClear,
  });

  final TextEditingController searchController;
  final TextEditingController brandController;
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final String transmission;
  final String fuelType;
  final String seats;
  final ValueChanged<String?> onTransmissionChanged;
  final ValueChanged<String?> onFuelTypeChanged;
  final ValueChanged<String?> onSeatsChanged;
  final VoidCallback onSearch;
  final VoidCallback onClear;

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
              'Search & filters',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: searchController,
              decoration: const InputDecoration(labelText: 'Keyword'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: brandController,
              decoration: const InputDecoration(labelText: 'Brand'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minPriceController,
                    decoration: const InputDecoration(labelText: 'Min price'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: maxPriceController,
                    decoration: const InputDecoration(labelText: 'Max price'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: transmission.isEmpty ? null : transmission,
                    decoration: const InputDecoration(
                      labelText: 'Transmission',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'automatic',
                        child: Text('Automatic'),
                      ),
                      DropdownMenuItem(value: 'manual', child: Text('Manual')),
                    ],
                    onChanged: onTransmissionChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: fuelType.isEmpty ? null : fuelType,
                    decoration: const InputDecoration(labelText: 'Fuel'),
                    items: const [
                      DropdownMenuItem(value: 'petrol', child: Text('Petrol')),
                      DropdownMenuItem(value: 'diesel', child: Text('Diesel')),
                      DropdownMenuItem(
                        value: 'electric',
                        child: Text('Electric'),
                      ),
                      DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                    ],
                    onChanged: onFuelTypeChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: seats.isEmpty ? null : seats,
              decoration: const InputDecoration(labelText: 'Min seats'),
              items: const [
                DropdownMenuItem(value: '1', child: Text('1+')),
                DropdownMenuItem(value: '2', child: Text('2+')),
                DropdownMenuItem(value: '3', child: Text('3+')),
                DropdownMenuItem(value: '4', child: Text('4+')),
                DropdownMenuItem(value: '5', child: Text('5+')),
                DropdownMenuItem(value: '6', child: Text('6+')),
                DropdownMenuItem(value: '7', child: Text('7+')),
                DropdownMenuItem(value: '8', child: Text('8+')),
              ],
              onChanged: onSeatsChanged,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(onPressed: onSearch, child: const Text('Search')),
                OutlinedButton(onPressed: onClear, child: const Text('Clear')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CarCard extends StatelessWidget {
  const _CarCard({required this.car, required this.onTap});

  final Car car;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: car.image == null || car.image!.isEmpty
                  ? Container(
                      color: Colors.black12,
                      child: const Icon(Icons.directions_car, size: 48),
                    )
                  : Image.network(car.image!, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${car.brand} ${car.model}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${car.year} • ${car.transmission} • ${car.fuelType}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${car.pricePerDay.toStringAsFixed(2)} / day',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
