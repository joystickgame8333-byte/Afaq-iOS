import CoreLocation
import Observation

@MainActor @Observable
final class PrayerLocationService: NSObject {
    private(set) var message = ""
    private(set) var resolving = false
    private(set) var permissionDenied = false
    @ObservationIgnored private let manager = CLLocationManager()
    @ObservationIgnored private let schedule: PrayerScheduleStore

    init(schedule: PrayerScheduleStore) {
        self.schedule = schedule
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func request() {
        schedule.enableAutomatic()
        permissionDenied = false
        switch manager.authorizationStatus {
        case .notDetermined:
            message = "بانتظار السماح بالموقع"
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            guard !resolving else { return }
            resolving = true
            message = "جارٍ تحديد أقرب مدينة"
            manager.requestLocation()
        case .denied, .restricted:
            permissionDenied = true
            message = "صلاحية الموقع غير متاحة؛ اختر المدينة يدويًا أو اسمح بالموقع من إعدادات الآيفون."
        @unknown default:
            message = "تعذر تحديد الموقع؛ اختر المدينة يدويًا."
        }
    }

    func select(_ city: PrayerCity) {
        schedule.select(city)
        resolving = false
        message = ""
        permissionDenied = false
    }
}

extension PrayerLocationService: @preconcurrency CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard schedule.automatic else { return }
        request()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        resolving = false
        guard schedule.automatic else { return }
        guard let location = locations.filter({ $0.horizontalAccuracy >= 0 && $0.horizontalAccuracy <= 10_000 && abs($0.timestamp.timeIntervalSinceNow) < 600 }).last else {
            message = "تعذر الحصول على موقع حديث؛ المدينة الحالية لم تتغيّر."
            return
        }
        let city = PrayerCities.nearest(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let distance = location.distance(from: CLLocation(latitude: city.latitude, longitude: city.longitude))
        guard distance <= 80_000 else {
            message = "موقعك خارج نطاق المدن المدعومة؛ اختر مدينة يدويًا. المدينة الحالية لم تتغيّر."
            return
        }
        schedule.select(city, automatic: true)
        message = "تم تحديد أقرب مدينة: " + city.name
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resolving = false
        guard schedule.automatic else { return }
        message = "تعذر تحديد الموقع؛ نستخدم المدينة المحفوظة: " + schedule.city.name
    }
}
