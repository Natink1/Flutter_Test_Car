# NHK Car Rental Mobile

Flutter mobile app that consumes the Laravel backend API in `backend/`.

What it includes

- Login and customer registration
- Browse approved cars from `GET /api/cars`
- View car details and reviews from `GET /api/cars/{id}` and `GET /api/cars/{id}/reviews`
- Create bookings with `POST /api/bookings`
- Cancel bookings from `PATCH /api/bookings/{id}/cancel`
- Add reviews with `POST /api/cars/{id}/reviews`

Run it

```bash
cd mobile
flutter pub get
flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

Notes

- The app uses `http://10.0.2.2:8000/api` by default, which is the usual Android emulator address for a local Laravel server.
- If you run on iOS simulator or a physical device, pass a different `API_BASE_URL` value.
- Start the Laravel backend before opening the app.

# mobile

A new Flutter project.
# Flutter_Test_Car
