import WidgetKit
import SwiftUI

private let appGroupId = "group.com.nada.nadaZikrakanm"

// MARK: - Color Hex Initializer

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255.0,
            green: Double((hex >> 08) & 0xff) / 255.0,
            blue: Double((hex >> 00) & 0xff) / 255.0,
            opacity: alpha
        )
    }
}

// MARK: - Theme Color Palettes (Synchronized with Flutter AppPalettes)

struct ThemeColors {
    let background: LinearGradient
    let cardBackground: Color
    let cardBorder: Color
    let primary: Color      // Gold / Accent color
    let secondary: Color    // Light / Cream text color
    let muted: Color        // Faint / Muted subtext
    let cellActiveBg: Color
    let isLight: Bool

    static func forTheme(_ key: String?) -> ThemeColors {
        switch key {
        case "obsidian":
            return ThemeColors(
                background: LinearGradient(
                    colors: [Color(hex: 0x0A0D10), Color(hex: 0x12171C), Color(hex: 0x1B222A)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: Color(hex: 0xFFD700).opacity(0.12),
                cardBorder: Color(hex: 0xFFD700).opacity(0.35),
                primary: Color(hex: 0xFFFFD700),
                secondary: Color(hex: 0xFAF9F6),
                muted: Color(hex: 0x9CA5B0),
                cellActiveBg: Color(hex: 0xFFFFD700).opacity(0.18),
                isLight: false
            )
        case "sunrise": // Golden Dawn (Daylight Amber & Cream)
            return ThemeColors(
                background: LinearGradient(
                    colors: [Color(hex: 0xF5EFE4), Color(hex: 0xECE2CF), Color(hex: 0xDFD2BA)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: Color(hex: 0x9A5B0B).opacity(0.12),
                cardBorder: Color(hex: 0x9A5B0B).opacity(0.30),
                primary: Color(hex: 0x9A5B0B),
                secondary: Color(hex: 0x1C140A), // Deep high-contrast text for daylight
                muted: Color(hex: 0x64513C),
                cellActiveBg: Color(hex: 0x9A5B0B).opacity(0.16),
                isLight: true
            )
        case "forest":
            return ThemeColors(
                background: LinearGradient(
                    colors: [Color(hex: 0x081812), Color(hex: 0x102A20), Color(hex: 0x16382C)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: Color(hex: 0x52B788).opacity(0.14),
                cardBorder: Color(hex: 0x52B788).opacity(0.35),
                primary: Color(hex: 0xD4AF37),
                secondary: Color(hex: 0xF2F7EF),
                muted: Color(hex: 0x8FA89B),
                cellActiveBg: Color(hex: 0xD4AF37).opacity(0.18),
                isLight: false
            )
        case "dusk":
            return ThemeColors(
                background: LinearGradient(
                    colors: [Color(hex: 0x120C1D), Color(hex: 0x1B122C), Color(hex: 0x261A3E)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: Color(hex: 0xC084FC).opacity(0.14),
                cardBorder: Color(hex: 0xC084FC).opacity(0.35),
                primary: Color(hex: 0xF6C86D),
                secondary: Color(hex: 0xF8F3FE),
                muted: Color(hex: 0xA592C0),
                cellActiveBg: Color(hex: 0xF6C86D).opacity(0.18),
                isLight: false
            )
        case "ocean":
            return ThemeColors(
                background: LinearGradient(
                    colors: [Color(hex: 0x07111D), Color(hex: 0x0E1F34), Color(hex: 0x142B47)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: Color(hex: 0x38BDF8).opacity(0.14),
                cardBorder: Color(hex: 0x38BDF8).opacity(0.35),
                primary: Color(hex: 0x38BDF8),
                secondary: Color(hex: 0xF0F7FF),
                muted: Color(hex: 0x7FAACF),
                cellActiveBg: Color(hex: 0x38BDF8).opacity(0.18),
                isLight: false
            )
        case "rose":
            return ThemeColors(
                background: LinearGradient(
                    colors: [Color(hex: 0x180A12), Color(hex: 0x28101E), Color(hex: 0x36162A)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: Color(hex: 0xFB7185).opacity(0.14),
                cardBorder: Color(hex: 0xFB7185).opacity(0.35),
                primary: Color(hex: 0xF6A97A),
                secondary: Color(hex: 0xFFF0F5),
                muted: Color(hex: 0xBA8F9F),
                cellActiveBg: Color(hex: 0xF6A97A).opacity(0.18),
                isLight: false
            )
        case "oled":
            return ThemeColors(
                background: LinearGradient(
                    colors: [Color(hex: 0x000000), Color(hex: 0x070707), Color(hex: 0x0F0F0F)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: Color(hex: 0xFFD700).opacity(0.10),
                cardBorder: Color(hex: 0xFFD700).opacity(0.35),
                primary: Color(hex: 0xFFFFD700),
                secondary: Color(hex: 0xFFFFFF),
                muted: Color(hex: 0xA0A0A0),
                cellActiveBg: Color(hex: 0xFFFFD700).opacity(0.18),
                isLight: false
            )
        default: // "nuri" / Kurdish Emerald Classic
            return ThemeColors(
                background: LinearGradient(
                    colors: [Color(hex: 0x07140E), Color(hex: 0x0D2A1C), Color(hex: 0x143826)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: Color(hex: 0x4DAE8C).opacity(0.14),
                cardBorder: Color(hex: 0x4DAE8C).opacity(0.35),
                primary: Color(hex: 0xD4AF37),
                secondary: Color(hex: 0xF7F2E7),
                muted: Color(hex: 0x98B8A4),
                cellActiveBg: Color(hex: 0xD4AF37).opacity(0.18),
                isLight: false
            )
        }
    }
}

// MARK: - Prayer Data Model

struct PrayerEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let hijriDate: String

    // Next upcoming prayer
    let nextPrayerName: String
    let nextPrayerTime: String
    let nextPrayerTimestamp: Double
    let nextPrayerId: String

    // All 6 prayer times
    let fajr: String
    let sunrise: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String

    let isKurdish: Bool
    let isArabic: Bool
    let themeKey: String

    // MARK: - Live Countdown (always accurate — computed fresh at every SwiftUI render)
    var nextPrayerDate: Date? {
        guard nextPrayerTimestamp > 0 else { return nil }
        return Date(timeIntervalSince1970: nextPrayerTimestamp)
    }

    var liveRemainingText: String {
        guard nextPrayerTimestamp > 0 else { return "" }
        let target = Date(timeIntervalSince1970: nextPrayerTimestamp)
        let diff = target.timeIntervalSince(Date())
        if diff <= 0 {
            return isKurdish ? "کاتی بانگە" : (isArabic ? "حان وقت الأذان" : "Prayer Time")
        }
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        if hours > 0 {
            return isKurdish
                ? "\(hours) کاتژمێر و \(minutes) خولەک ماوە"
                : (isArabic ? "باقي \(hours) ساعة و \(minutes) دقيقة" : "in \(hours)h \(minutes)m")
        } else {
            return isKurdish
                ? "\(minutes) خولەک ماوە"
                : (isArabic ? "باقي \(minutes) دقيقة" : "in \(minutes) mins")
        }
    }
}

// MARK: - Helpers

private struct PrayerSlot: Identifiable {
    let id: String
    let nameKu: String
    let nameAr: String
    let nameEn: String
    let iconName: String
    let time: String
    var isNext: Bool = false
}

// MARK: - Native Offline Prayer Calculator & Hijri Helper
// Used as high-precision offline fallback whenever App Group data is unavailable (e.g. Sideloading, SideStore, AltStore, fresh install)

struct NativePrayerTimes {
    let fajr: Date
    let sunrise: Date
    let dhuhr: Date
    let asr: Date
    let maghrib: Date
    let isha: Date
}

enum IslamicDateHelper {
    private static let kurdishMonths = [
        "موحەڕەم", "سەفەر", "ڕەبیعی یەکەم", "ڕەبیعی دووەم",
        "جومادای یەکەم", "جومادای دووەم", "ڕەجەب", "شەعبان",
        "ڕەمەزان", "شەووال", "زولقەعدە", "زولحەججە"
    ]
    private static let arabicMonths = [
        "محرم", "صفر", "ربيع الأول", "ربيع الثاني",
        "جمادى الأولى", "جمادى الآخرة", "رجب", "شعبان",
        "رمضان", "شوال", "ذو القعدة", "ذو الحجة"
    ]

    static func format(date: Date, isKurdish: Bool, isArabic: Bool) -> String {
        let cal = Calendar(identifier: .islamicUmmAlQura)
        let day = cal.component(.day, from: date)
        let month = cal.component(.month, from: date)
        let year = cal.component(.year, from: date)

        let monthName: String
        if month >= 1 && month <= 12 {
            monthName = isKurdish ? kurdishMonths[month - 1] : (isArabic ? arabicMonths[month - 1] : arabicMonths[month - 1])
        } else {
            monthName = ""
        }
        return "\(day) \(monthName) \(year)"
    }
}

enum NativePrayerCalculator {
    /// Authentic Kurdistan Regional Government Ministry of Endowments (Awqaf) Calibrated Standard
    static func calculate(
        date: Date,
        latitude: Double = 36.1911,   // Erbil / Kurdistan Regional Capital Standard
        longitude: Double = 44.0092,
        utcOffsetHours: Double = 3.0
    ) -> NativePrayerTimes {
        let cal = Calendar(identifier: .gregorian)
        let dayOfYear = cal.ordinality(of: .day, in: .year, for: date) ?? 1

        let gamma = (2.0 * Double.pi / 365.0) * Double(dayOfYear - 1)

        let eqOfTime = 229.18 * (
            0.000075 +
            0.001868 * cos(gamma) -
            0.032077 * sin(gamma) -
            0.014615 * cos(2.0 * gamma) -
            0.040849 * sin(2.0 * gamma)
        )

        let declination = 0.006918 -
            0.399912 * cos(gamma) +
            0.070257 * sin(gamma) -
            0.006758 * cos(2.0 * gamma) +
            0.000907 * sin(2.0 * gamma) -
            0.002697 * cos(3.0 * gamma) +
            0.00148 * sin(3.0 * gamma)

        // Solar noon in minutes from local midnight UTC+3
        let solarNoonMinutes = 720.0 - (4.0 * longitude) - eqOfTime + (utcOffsetHours * 60.0)

        func hourAngle(zenithDegrees: Double) -> Double {
            let latRad = latitude * Double.pi / 180.0
            let zenRad = zenithDegrees * Double.pi / 180.0
            let cosH = (cos(zenRad) - (sin(latRad) * sin(declination))) / (cos(latRad) * cos(declination))
            if cosH > 1.0 || cosH < -1.0 { return Double.nan }
            return acos(cosH) * 180.0 / Double.pi
        }

        func asrHourAngle(shadowFactor: Double = 1.0) -> Double {
            let latRad = latitude * Double.pi / 180.0
            let delta = abs(latRad - declination)
            let cotAlt = shadowFactor + tan(delta)
            let altRad = atan(1.0 / cotAlt)
            let cosH = (sin(altRad) - (sin(latRad) * sin(declination))) / (cos(latRad) * cos(declination))
            let clamped = max(-1.0, min(1.0, cosH))
            return acos(clamped) * 180.0 / Double.pi
        }

        let sunriseZenith = 90.833
        let sunriseHA = hourAngle(zenithDegrees: sunriseZenith)
        let astroSunriseMinutes = solarNoonMinutes - (sunriseHA * 4.0)
        let astroSunsetMinutes  = solarNoonMinutes + (sunriseHA * 4.0)

        // Kurdistan Ministry of Endowments (Awqaf) Standard:
        // - Dhuhr: Solar noon + 6 min zawal margin
        // - Sunrise: Astro sunrise + 6 min terrain margin
        // - Fajr: 19.5° Awqaf depression angle with Kurdistan mountain elevation correction
        // - Maghrib: Astro sunset + 4 min dusk twilight
        // - Isha: Maghrib + 75 min (Kurdistan Awqaf fixed twilight standard)
        let dhuhrMinutes = solarNoonMinutes + 6.0
        let sunriseMinutes = astroSunriseMinutes + 6.0

        let fajrHA = hourAngle(zenithDegrees: 90.0 + 19.5)
        let rawFajrMinutes = fajrHA.isNaN ? (astroSunriseMinutes - 86.0) : (solarNoonMinutes - (fajrHA * 4.0))
        let fajrMinutes = rawFajrMinutes + 13.0

        let asrHA = asrHourAngle(shadowFactor: 1.0)
        let asrMinutes = solarNoonMinutes + (asrHA * 4.0) - 2.0

        let maghribMinutes = astroSunsetMinutes + 4.0
        let ishaMinutes = maghribMinutes + 75.0

        func minutesToDate(_ mins: Double) -> Date {
            let startOfDay = cal.startOfDay(for: date)
            return startOfDay.addingTimeInterval(mins * 60.0)
        }

        return NativePrayerTimes(
            fajr: minutesToDate(fajrMinutes),
            sunrise: minutesToDate(sunriseMinutes),
            dhuhr: minutesToDate(dhuhrMinutes),
            asr: minutesToDate(asrMinutes),
            maghrib: minutesToDate(maghribMinutes),
            isha: minutesToDate(ishaMinutes)
        )
    }

    static func formatCleanTime(_ date: Date) -> String {
        let cal = Calendar.current
        let hour24 = cal.component(.hour, from: date)
        let minute = cal.component(.minute, from: date)
        let hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12
        return String(format: "%02d:%02d", hour12, minute)
    }

    static func formatFullTime(_ date: Date) -> String {
        let cal = Calendar.current
        let hour24 = cal.component(.hour, from: date)
        let minute = cal.component(.minute, from: date)
        let hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12
        let period = hour24 >= 12 ? "PM" : "AM"
        return String(format: "%02d:%02d %@", hour12, minute, period)
    }
}

// MARK: - Timeline Provider

struct PrayerTimelineProvider: TimelineProvider {

    private func readString(_ prefs: [UserDefaults?], keys: [String]) -> String? {
        for pref in prefs {
            guard let p = pref else { continue }
            for key in keys {
                if let value = p.string(forKey: key)?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !value.isEmpty, value != "--:--" {
                    return value
                }
            }
        }
        return nil
    }

    private func readDouble(_ prefs: [UserDefaults?], keys: [String]) -> Double? {
        for pref in prefs {
            guard let p = pref else { continue }
            for key in keys {
                let val = p.double(forKey: key)
                if val > 0 { return val }
                if let str = p.string(forKey: key)?.trimmingCharacters(in: .whitespacesAndNewlines),
                   let d = Double(str), d > 0 {
                    return d
                }
            }
        }
        return nil
    }

    private func parseTimeToDate(_ timeStr: String?, for baseDate: Date, isPMDefault: Bool = false, timeZone: TimeZone? = nil) -> Date? {
        guard let raw = timeStr?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty, raw != "--:--" else {
            return nil
        }
        var cal = Calendar.current
        if let tz = timeZone {
            cal.timeZone = tz
        }
        let parts = raw.components(separatedBy: " ")
        let timePart = parts.first ?? raw
        let periodPart = parts.count > 1 ? parts[1].uppercased() : nil
        let comps = timePart.components(separatedBy: ":")
        guard comps.count >= 2, let h = Int(comps[0]), let m = Int(comps[1]) else { return nil }

        var hour24 = h
        if let period = periodPart {
            if period == "PM" && hour24 < 12 { hour24 += 12 }
            if period == "AM" && hour24 == 12 { hour24 = 0 }
        } else if isPMDefault && hour24 < 12 {
            hour24 += 12
        }

        var dateComps = cal.dateComponents([.year, .month, .day], from: baseDate)
        dateComps.hour = hour24
        dateComps.minute = m
        dateComps.second = 0
        return cal.date(from: dateComps)
    }

    func placeholder(in context: Context) -> PrayerEntry {
        fetchCurrentEntry(for: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> ()) {
        completion(fetchCurrentEntry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> ()) {
        let now = Date()
        let currentEntry = fetchCurrentEntry(for: now)

        let appGroupPrefs = UserDefaults(suiteName: appGroupId)
        let standardPrefs = UserDefaults.standard
        let allPrefs = [appGroupPrefs, standardPrefs]

        let cityTzId = readString(allPrefs, keys: ["city_timezone_id"])
        let cityUtcOffset = readDouble(allPrefs, keys: ["city_utc_offset"])
        let cityTimeZone: TimeZone? = (cityTzId != nil ? TimeZone(identifier: cityTzId!) : nil) ?? (cityUtcOffset != nil ? TimeZone(secondsFromGMT: Int(cityUtcOffset! * 3600)) : nil)

        // Build exact transition dates for today using timestamps or parsed full times
        let fajrTimestamp    = readDouble(allPrefs, keys: ["fajr_timestamp", "fajr_timestamp_str"]) ?? 0
        let sunriseTimestamp = readDouble(allPrefs, keys: ["sunrise_timestamp", "sunrise_timestamp_str"]) ?? 0
        let dhuhrTimestamp   = readDouble(allPrefs, keys: ["dhuhr_timestamp", "dhuhr_timestamp_str"]) ?? 0
        let asrTimestamp     = readDouble(allPrefs, keys: ["asr_timestamp", "asr_timestamp_str"]) ?? 0
        let maghribTimestamp = readDouble(allPrefs, keys: ["maghrib_timestamp", "maghrib_timestamp_str"]) ?? 0
        let ishaTimestamp    = readDouble(allPrefs, keys: ["isha_timestamp", "isha_timestamp_str"]) ?? 0

        var transitionDates: [Date] = []
        if fajrTimestamp > 0 && ishaTimestamp > 0 {
            transitionDates = [
                Date(timeIntervalSince1970: fajrTimestamp),
                Date(timeIntervalSince1970: sunriseTimestamp),
                Date(timeIntervalSince1970: dhuhrTimestamp),
                Date(timeIntervalSince1970: asrTimestamp),
                Date(timeIntervalSince1970: maghribTimestamp),
                Date(timeIntervalSince1970: ishaTimestamp)
            ]
        } else if let pFajr = parseTimeToDate(readString(allPrefs, keys: ["fajr_full_time", "fajr_time"]), for: now, isPMDefault: false, timeZone: cityTimeZone),
                  let pSunrise = parseTimeToDate(readString(allPrefs, keys: ["sunrise_full_time", "sunrise_time"]), for: now, isPMDefault: false, timeZone: cityTimeZone),
                  let pDhuhr = parseTimeToDate(readString(allPrefs, keys: ["dhuhr_full_time", "dhuhr_time"]), for: now, isPMDefault: false, timeZone: cityTimeZone),
                  let pAsr = parseTimeToDate(readString(allPrefs, keys: ["asr_full_time", "asr_time"]), for: now, isPMDefault: true, timeZone: cityTimeZone),
                  let pMaghrib = parseTimeToDate(readString(allPrefs, keys: ["maghrib_full_time", "maghrib_time"]), for: now, isPMDefault: true, timeZone: cityTimeZone),
                  let pIsha = parseTimeToDate(readString(allPrefs, keys: ["isha_full_time", "isha_time"]), for: now, isPMDefault: true, timeZone: cityTimeZone) {
            transitionDates = [pFajr, pSunrise, pDhuhr, pAsr, pMaghrib, pIsha]
        } else {
            let lat = readDouble(allPrefs, keys: ["city_lat", "city_lat_str"]) ?? 36.1911
            let lng = readDouble(allPrefs, keys: ["city_lng", "city_lng_str"]) ?? 44.0092
            let calculated = NativePrayerCalculator.calculate(
                date: now,
                latitude: lat > 0 ? lat : 36.1911,
                longitude: lng > 0 ? lng : 44.0092
            )
            transitionDates = [
                calculated.fajr,
                calculated.sunrise,
                calculated.dhuhr,
                calculated.asr,
                calculated.maghrib,
                calculated.isha
            ]
        }

        // Only transitions in the future today (+1 second past azan so card immediately updates)
        let futureTransitionDates = transitionDates
            .filter { $0 > now }
            .map { $0.addingTimeInterval(1) }
            .sorted()

        // Build dynamic entries for each transition point
        var entries: [PrayerEntry] = [currentEntry]
        for tDate in futureTransitionDates.prefix(6) {
            entries.append(fetchCurrentEntry(for: tDate))
        }

        let nextPolicyDate = futureTransitionDates.first ?? now.addingTimeInterval(900)
        let timeline = Timeline(entries: entries, policy: .after(nextPolicyDate))
        completion(timeline)
    }

    private func fetchCurrentEntry(for targetDate: Date = Date()) -> PrayerEntry {
        let appGroupPrefs = UserDefaults(suiteName: appGroupId)
        let standardPrefs = UserDefaults.standard
        let allPrefs = [appGroupPrefs, standardPrefs]

        let lang = readString(allPrefs, keys: ["lang"]) ?? "ku"
        let isKurdish = lang == "ku" || lang == "kmr"
        let isArabic  = lang == "ar"

        let sharedFajr    = readString(allPrefs, keys: ["fajr_time"])
        let sharedSunrise = readString(allPrefs, keys: ["sunrise_time"])
        let sharedDhuhr   = readString(allPrefs, keys: ["dhuhr_time"])
        let sharedAsr     = readString(allPrefs, keys: ["asr_time"])
        let sharedMaghrib = readString(allPrefs, keys: ["maghrib_time"])
        let sharedIsha    = readString(allPrefs, keys: ["isha_time"])

        let fajrTimestamp    = readDouble(allPrefs, keys: ["fajr_timestamp", "fajr_timestamp_str"]) ?? 0
        let sunriseTimestamp = readDouble(allPrefs, keys: ["sunrise_timestamp", "sunrise_timestamp_str"]) ?? 0
        let dhuhrTimestamp   = readDouble(allPrefs, keys: ["dhuhr_timestamp", "dhuhr_timestamp_str"]) ?? 0
        let asrTimestamp     = readDouble(allPrefs, keys: ["asr_timestamp", "asr_timestamp_str"]) ?? 0
        let maghribTimestamp = readDouble(allPrefs, keys: ["maghrib_timestamp", "maghrib_timestamp_str"]) ?? 0
        let ishaTimestamp    = readDouble(allPrefs, keys: ["isha_timestamp", "isha_timestamp_str"]) ?? 0

        let cityTzId = readString(allPrefs, keys: ["city_timezone_id"])
        let cityUtcOffset = readDouble(allPrefs, keys: ["city_utc_offset"])
        let cityTimeZone: TimeZone? = (cityTzId != nil ? TimeZone(identifier: cityTzId!) : nil) ?? (cityUtcOffset != nil ? TimeZone(secondsFromGMT: Int(cityUtcOffset! * 3600)) : nil)

        let hasTimestamps = fajrTimestamp > 0 && sunriseTimestamp > 0 && dhuhrTimestamp > 0 &&
                            asrTimestamp > 0 && maghribTimestamp > 0 && ishaTimestamp > 0

        let fajrDate: Date
        let sunriseDate: Date
        let dhuhrDate: Date
        let asrDate: Date
        let maghribDate: Date
        let ishaDate: Date

        let fajrStr: String
        let sunriseStr: String
        let dhuhrStr: String
        let asrStr: String
        let maghribStr: String
        let ishaStr: String

        if hasTimestamps {
            fajrDate    = Date(timeIntervalSince1970: fajrTimestamp)
            sunriseDate = Date(timeIntervalSince1970: sunriseTimestamp)
            dhuhrDate   = Date(timeIntervalSince1970: dhuhrTimestamp)
            asrDate     = Date(timeIntervalSince1970: asrTimestamp)
            maghribDate = Date(timeIntervalSince1970: maghribTimestamp)
            ishaDate    = Date(timeIntervalSince1970: ishaTimestamp)

            fajrStr    = sharedFajr ?? NativePrayerCalculator.formatCleanTime(fajrDate)
            sunriseStr = sharedSunrise ?? NativePrayerCalculator.formatCleanTime(sunriseDate)
            dhuhrStr   = sharedDhuhr ?? NativePrayerCalculator.formatCleanTime(dhuhrDate)
            asrStr     = sharedAsr ?? NativePrayerCalculator.formatCleanTime(asrDate)
            maghribStr = sharedMaghrib ?? NativePrayerCalculator.formatCleanTime(maghribDate)
            ishaStr    = sharedIsha ?? NativePrayerCalculator.formatCleanTime(ishaDate)
        } else if let pFajr = parseTimeToDate(readString(allPrefs, keys: ["fajr_full_time", "fajr_time"]), for: targetDate, isPMDefault: false, timeZone: cityTimeZone),
                  let pSunrise = parseTimeToDate(readString(allPrefs, keys: ["sunrise_full_time", "sunrise_time"]), for: targetDate, isPMDefault: false, timeZone: cityTimeZone),
                  let pDhuhr = parseTimeToDate(readString(allPrefs, keys: ["dhuhr_full_time", "dhuhr_time"]), for: targetDate, isPMDefault: false, timeZone: cityTimeZone),
                  let pAsr = parseTimeToDate(readString(allPrefs, keys: ["asr_full_time", "asr_time"]), for: targetDate, isPMDefault: true, timeZone: cityTimeZone),
                  let pMaghrib = parseTimeToDate(readString(allPrefs, keys: ["maghrib_full_time", "maghrib_time"]), for: targetDate, isPMDefault: true, timeZone: cityTimeZone),
                  let pIsha = parseTimeToDate(readString(allPrefs, keys: ["isha_full_time", "isha_time"]), for: targetDate, isPMDefault: true, timeZone: cityTimeZone) {
            fajrDate    = pFajr
            sunriseDate = pSunrise
            dhuhrDate   = pDhuhr
            asrDate     = pAsr
            maghribDate = pMaghrib
            ishaDate    = pIsha

            fajrStr    = sharedFajr ?? NativePrayerCalculator.formatCleanTime(fajrDate)
            sunriseStr = sharedSunrise ?? NativePrayerCalculator.formatCleanTime(sunriseDate)
            dhuhrStr   = sharedDhuhr ?? NativePrayerCalculator.formatCleanTime(dhuhrDate)
            asrStr     = sharedAsr ?? NativePrayerCalculator.formatCleanTime(asrDate)
            maghribStr = sharedMaghrib ?? NativePrayerCalculator.formatCleanTime(maghribDate)
            ishaStr    = sharedIsha ?? NativePrayerCalculator.formatCleanTime(ishaDate)
        } else {
            let lat = readDouble(allPrefs, keys: ["city_lat", "city_lat_str"]) ?? 36.1911
            let lng = readDouble(allPrefs, keys: ["city_lng", "city_lng_str"]) ?? 44.0092
            let calculated = NativePrayerCalculator.calculate(
                date: targetDate,
                latitude: lat > 0 ? lat : 36.1911,
                longitude: lng > 0 ? lng : 44.0092
            )
            fajrDate    = calculated.fajr
            sunriseDate = calculated.sunrise
            dhuhrDate   = calculated.dhuhr
            asrDate     = calculated.asr
            maghribDate = calculated.maghrib
            ishaDate    = calculated.isha

            fajrStr    = sharedFajr ?? NativePrayerCalculator.formatCleanTime(fajrDate)
            sunriseStr = sharedSunrise ?? NativePrayerCalculator.formatCleanTime(sunriseDate)
            dhuhrStr   = sharedDhuhr ?? NativePrayerCalculator.formatCleanTime(dhuhrDate)
            asrStr     = sharedAsr ?? NativePrayerCalculator.formatCleanTime(asrDate)
            maghribStr = sharedMaghrib ?? NativePrayerCalculator.formatCleanTime(maghribDate)
            ishaStr    = sharedIsha ?? NativePrayerCalculator.formatCleanTime(ishaDate)
        }

        // Determine which prayer is next relative to targetDate
        let nextId: String
        let nextName: String
        let nextFullTime: String
        let nextTimestamp: Double

        if targetDate < fajrDate {
            nextId = "fajr"
            nextName = isKurdish ? "بانگی بەیانی" : (isArabic ? "صلاة الفجر" : "Fajr")
            nextFullTime = readString(allPrefs, keys: ["fajr_full_time"]) ?? NativePrayerCalculator.formatFullTime(fajrDate)
            nextTimestamp = fajrDate.timeIntervalSince1970
        } else if targetDate < sunriseDate {
            nextId = "sunrise"
            nextName = isKurdish ? "هەڵاتنی خۆر" : (isArabic ? "الشروق" : "Sunrise")
            nextFullTime = readString(allPrefs, keys: ["sunrise_full_time"]) ?? NativePrayerCalculator.formatFullTime(sunriseDate)
            nextTimestamp = sunriseDate.timeIntervalSince1970
        } else if targetDate < dhuhrDate {
            nextId = "dhuhr"
            nextName = isKurdish ? "بانگی نیوەڕۆ" : (isArabic ? "صلاة الظهر" : "Dhuhr")
            nextFullTime = readString(allPrefs, keys: ["dhuhr_full_time"]) ?? NativePrayerCalculator.formatFullTime(dhuhrDate)
            nextTimestamp = dhuhrDate.timeIntervalSince1970
        } else if targetDate < asrDate {
            nextId = "asr"
            nextName = isKurdish ? "بانگی عەسر" : (isArabic ? "صلاة العصر" : "Asr")
            nextFullTime = readString(allPrefs, keys: ["asr_full_time"]) ?? NativePrayerCalculator.formatFullTime(asrDate)
            nextTimestamp = asrDate.timeIntervalSince1970
        } else if targetDate < maghribDate {
            nextId = "maghrib"
            nextName = isKurdish ? "بانگی شێوان" : (isArabic ? "صلاة المغرب" : "Maghrib")
            nextFullTime = readString(allPrefs, keys: ["maghrib_full_time"]) ?? NativePrayerCalculator.formatFullTime(maghribDate)
            nextTimestamp = maghribDate.timeIntervalSince1970
        } else if targetDate < ishaDate {
            nextId = "isha"
            nextName = isKurdish ? "بانگی خەوتنان" : (isArabic ? "صلاة العشاء" : "Isha")
            nextFullTime = readString(allPrefs, keys: ["isha_full_time"]) ?? NativePrayerCalculator.formatFullTime(ishaDate)
            nextTimestamp = ishaDate.timeIntervalSince1970
        } else {
            // All prayers passed for today — next prayer is tomorrow's Fajr
            let tomorrowFajrDate = fajrDate.addingTimeInterval(86400)
            nextId = "fajr"
            nextName = isKurdish ? "بانگی بەیانی" : (isArabic ? "صلاة الفجر" : "Fajr")
            nextFullTime = readString(allPrefs, keys: ["fajr_full_time"]) ?? NativePrayerCalculator.formatFullTime(tomorrowFajrDate)
            nextTimestamp = tomorrowFajrDate.timeIntervalSince1970
        }

        let defaultCity = isKurdish ? "هەولێر" : (isArabic ? "أربيل" : "Erbil")
        let cityName = readString(allPrefs, keys: ["city_name", "city_name_ku", "city_name_ar", "city_name_en"]) ?? defaultCity
        let hijriDate = readString(allPrefs, keys: ["hijri_date"]) ?? IslamicDateHelper.format(date: targetDate, isKurdish: isKurdish, isArabic: isArabic)
        let themeKey = readString(allPrefs, keys: ["theme_key"]) ?? "nuri"

        return PrayerEntry(
            date: targetDate,
            cityName: cityName,
            hijriDate: hijriDate,
            nextPrayerName: nextName,
            nextPrayerTime: nextFullTime,
            nextPrayerTimestamp: nextTimestamp,
            nextPrayerId: nextId,
            fajr: fajrStr,
            sunrise: sunriseStr,
            dhuhr: dhuhrStr,
            asr: asrStr,
            maghrib: maghribStr,
            isha: ishaStr,
            isKurdish: isKurdish,
            isArabic: isArabic,
            themeKey: themeKey
        )
    }
}

// MARK: - Shared Views

private struct PrayerCard: View {
    let name: String
    let time: String
    let iconName: String
    let isNext: Bool
    let textColor: Color
    let activeColor: Color
    let activeBg: Color
    let inactiveBg: Color
    let activeBorder: Color

    private var cleanTime: String {
        let parts = time.components(separatedBy: " ")
        return parts.first ?? time
    }

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: iconName)
                .font(.system(size: 13, weight: isNext ? .bold : .medium))
                .foregroundColor(isNext ? activeColor : textColor.opacity(0.85))
                .frame(height: 14)

            Text(name)
                .font(.system(size: 9.5, weight: isNext ? .bold : .medium))
                .foregroundColor(isNext ? activeColor : textColor.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(cleanTime)
                .font(.system(size: 11, weight: isNext ? .bold : .semibold, design: .monospaced))
                .foregroundColor(isNext ? activeColor : textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 4)
        .padding(.horizontal, 2)
        .background(isNext ? activeBg : inactiveBg)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(isNext ? activeBorder : Color.clear, lineWidth: isNext ? 1.5 : 0)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Widget Entry View

struct PrayerTimesWidgetEntryView: View {
    var entry: PrayerTimelineProvider.Entry
    @Environment(\.widgetFamily) var family

    private var theme: ThemeColors {
        ThemeColors.forTheme(entry.themeKey)
    }

    private func prayerSlots() -> [PrayerSlot] {
        [
            PrayerSlot(id: "fajr",    nameKu: "بەیانی",     nameAr: "الفجر",   nameEn: "Fajr",    iconName: "sun.horizon.fill",     time: entry.fajr,    isNext: entry.nextPrayerId == "fajr"),
            PrayerSlot(id: "sunrise", nameKu: "خۆرهەڵاتن",  nameAr: "الشروق",  nameEn: "Sunrise", iconName: "sun.and.horizon.fill", time: entry.sunrise, isNext: entry.nextPrayerId == "sunrise"),
            PrayerSlot(id: "dhuhr",   nameKu: "نیوەڕۆ",     nameAr: "الظهر",   nameEn: "Dhuhr",   iconName: "sun.max.fill",         time: entry.dhuhr,   isNext: entry.nextPrayerId == "dhuhr"),
            PrayerSlot(id: "asr",     nameKu: "عەسر",       nameAr: "العصر",   nameEn: "Asr",     iconName: "sun.haze.fill",        time: entry.asr,     isNext: entry.nextPrayerId == "asr"),
            PrayerSlot(id: "maghrib", nameKu: "شێوان",      nameAr: "المغرب",  nameEn: "Maghrib", iconName: "sunset.fill",          time: entry.maghrib, isNext: entry.nextPrayerId == "maghrib"),
            PrayerSlot(id: "isha",    nameKu: "خەوتنان",    nameAr: "العشاء",  nameEn: "Isha",    iconName: "moon.stars.fill",      time: entry.isha,    isNext: entry.nextPrayerId == "isha"),
        ]
    }

    private func upcomingThreeSlots() -> [PrayerSlot] {
        let slots = prayerSlots()
        if let nextIndex = slots.firstIndex(where: { $0.isNext }) {
            var result: [PrayerSlot] = []
            for i in 0..<3 {
                result.append(slots[(nextIndex + i) % slots.count])
            }
            return result
        }
        return Array(slots.prefix(3))
    }

    private func prayerName(_ slot: PrayerSlot) -> String {
        if entry.isKurdish { return slot.nameKu }
        if entry.isArabic  { return slot.nameAr }
        return slot.nameEn
    }

    private var appTitle: String {
        (entry.isKurdish || entry.isArabic) ? "نەدا" : "Nada"
    }

    private var remainingLabel: String {
        if entry.isKurdish { return "کاتی ماوە" }
        if entry.isArabic  { return "الوقت المتبقي" }
        return "Time Left"
    }

    private var cleanNextPrayerName: String {
        var name = entry.nextPrayerName
        if name.starts(with: "بانگی ") {
            name = String(name.dropFirst(6))
        } else if name.starts(with: "صلاة ") {
            name = String(name.dropFirst(5))
        }
        return name
    }

    private func cleanTime(_ timeStr: String) -> String {
        let parts = timeStr.components(separatedBy: " ")
        return parts.first ?? timeStr
    }

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallWidget.widgetBackground(theme.background)
            case .systemMedium:
                mediumWidget.widgetBackground(theme.background)
            case .systemLarge:
                largeWidget.widgetBackground(theme.background)
            default:
                if #available(iOSApplicationExtension 16.0, *) {
                    switch family {
                    case .accessoryRectangular:
                        lockScreenRectangular.widgetBackground(Color.clear)
                    case .accessoryInline:
                        lockScreenInline.widgetBackground(Color.clear)
                    case .accessoryCircular:
                        lockScreenCircular.widgetBackground(Color.clear)
                    default:
                        smallWidget.widgetBackground(theme.background)
                    }
                } else {
                    smallWidget.widgetBackground(theme.background)
                }
            }
        }
        .widgetURL(URL(string: "nadazikr://open/prayer_times?homeWidget"))
    }

    // MARK: - Small Widget (Balanced, Compact, No Dead Space)
    var smallWidget: some View {
        VStack(spacing: 4) {
            // Top Header: City & Pin + App Title
            HStack(alignment: .center) {
                HStack(spacing: 3.5) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(theme.primary)
                    Text(entry.cityName)
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(theme.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Text(appTitle)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(theme.primary)
            }

            // Hero Card: Next Prayer
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    if let nextSlot = prayerSlots().first(where: { $0.isNext }) {
                        Image(systemName: nextSlot.iconName)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(theme.primary)
                    }
                    Text(cleanNextPrayerName)
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(theme.primary)
                        .lineLimit(1)
                }

                Text(cleanTime(entry.nextPrayerTime))
                    .font(.system(size: 21, weight: .heavy, design: .rounded))
                    .foregroundColor(theme.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                // Countdown Pill
                HStack(spacing: 3) {
                    if let target = entry.nextPrayerDate, target > Date() {
                        Text(target, style: .timer)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(theme.primary)
                            .lineLimit(1)
                    } else {
                        Text(entry.liveRemainingText.isEmpty ? (entry.isKurdish ? "کاتی بانگە" : (entry.isArabic ? "حان الآن" : "Now")) : entry.liveRemainingText)
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundColor(theme.primary)
                            .lineLimit(1)
                    }
                    Text("⌛")
                        .font(.system(size: 9))
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 2.5)
                .background(theme.cardBackground)
                .overlay(Capsule().stroke(theme.cardBorder, lineWidth: 0.8))
                .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 3)
            .background(theme.cellActiveBg.opacity(0.5))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(theme.cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            // Mini 3-Prayer bar at bottom (Fills remaining space without blank gap)
            HStack(spacing: 3) {
                let slots = upcomingThreeSlots()
                ForEach(slots) { slot in
                    VStack(spacing: 1) {
                        Text(prayerName(slot))
                            .font(.system(size: 8, weight: slot.isNext ? .bold : .medium))
                            .foregroundColor(slot.isNext ? theme.primary : theme.secondary.opacity(0.8))
                            .lineLimit(1)
                        Text(cleanTime(slot.time))
                            .font(.system(size: 8.5, weight: slot.isNext ? .bold : .regular, design: .monospaced))
                            .foregroundColor(slot.isNext ? theme.primary : theme.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 2.5)
                    .background(slot.isNext ? theme.cellActiveBg : theme.cardBackground.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
            }
        }
        .padding(9)
        .environment(\.layoutDirection, (entry.isKurdish || entry.isArabic) ? .rightToLeft : .leftToRight)
    }

    // MARK: - Medium Widget (Header, Next Prayer Hero & 6-Prayer Schedule – Identical to Screenshot)
    var mediumWidget: some View {
        VStack(spacing: 6) {
            // Header (Top Line)
            HStack(alignment: .center) {
                // Right (in RTL): City + Pin
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12.5))
                        .foregroundColor(theme.primary)
                    Text(entry.cityName)
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundColor(theme.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                // Left (in RTL): "کاتی ماوە"
                Text(remainingLabel)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(theme.muted)
                    .lineLimit(1)
            }

            // Subheader (Hero Line)
            HStack(alignment: .center, spacing: 6) {
                // Right (in RTL): Next prayer title + name + time badge
                HStack(spacing: 4) {
                    Text(entry.isKurdish ? "بانگی داهاتوو:" : (entry.isArabic ? "الصلاة القادمة:" : "Next:"))
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundColor(theme.secondary.opacity(0.85))
                        .lineLimit(1)

                    Text(cleanNextPrayerName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(theme.primary)
                        .lineLimit(1)

                    HStack(spacing: 3) {
                        Text(cleanTime(entry.nextPrayerTime))
                            .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                            .foregroundColor(theme.primary)
                            .lineLimit(1)
                        Image(systemName: "clock.fill")
                            .font(.system(size: 8.5))
                            .foregroundColor(theme.primary)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(theme.cardBackground)
                    .overlay(Capsule().stroke(theme.cardBorder, lineWidth: 0.8))
                    .clipShape(Capsule())
                }

                Spacer(minLength: 4)

                // Left (in RTL): Countdown Pill
                HStack(spacing: 3) {
                    if let target = entry.nextPrayerDate, target > Date() {
                        Text(target, style: .timer)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(theme.primary)
                            .lineLimit(1)
                    } else {
                        Text(entry.liveRemainingText.isEmpty ? (entry.isKurdish ? "کاتی بانگە" : (entry.isArabic ? "حان الآن" : "Now")) : entry.liveRemainingText)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(theme.primary)
                            .lineLimit(1)
                    }
                    Text("⌛")
                        .font(.system(size: 9))
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 2.5)
                .background(Color(hex: 0x071D18).opacity(0.85))
                .overlay(Capsule().stroke(theme.cardBorder, lineWidth: 0.9))
                .clipShape(Capsule())
            }

            // Bottom Line: 6 Prayer Cards filling all remaining space
            HStack(spacing: 4) {
                let slots = prayerSlots()
                ForEach(slots) { slot in
                    PrayerCard(
                        name: prayerName(slot),
                        time: slot.time,
                        iconName: slot.iconName,
                        isNext: slot.isNext,
                        textColor: theme.secondary,
                        activeColor: theme.primary,
                        activeBg: theme.cellActiveBg,
                        inactiveBg: theme.cardBackground.opacity(0.35),
                        activeBorder: theme.primary
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(10)
        .environment(\.layoutDirection, (entry.isKurdish || entry.isArabic) ? .rightToLeft : .leftToRight)
    }

    // MARK: - Large Widget (Spacious, Fully Balanced, Zero Empty Gaps)
    var largeWidget: some View {
        VStack(spacing: 8) {
            // Top Header: City & Pin + Hijri Date + App Title
            HStack(alignment: .center) {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 13.5))
                        .foregroundColor(theme.primary)
                    Text(entry.cityName)
                        .font(.system(size: 13.5, weight: .bold))
                        .foregroundColor(theme.secondary)
                        .lineLimit(1)
                }
                Spacer()
                if !entry.hijriDate.isEmpty {
                    Text(entry.hijriDate)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(theme.muted)
                }
            }

            // Hero Next Prayer Banner
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Text(entry.isKurdish ? "بانگی داهاتوو:" : (entry.isArabic ? "الصلاة القادمة:" : "Next Prayer:"))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(theme.secondary.opacity(0.85))
                        Text(cleanNextPrayerName)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(theme.primary)
                    }

                    // Countdown Pill
                    HStack(spacing: 4) {
                        if let target = entry.nextPrayerDate, target > Date() {
                            Text(target, style: .timer)
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(theme.primary)
                        } else {
                            Text(entry.liveRemainingText.isEmpty ? "Now" : entry.liveRemainingText)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(theme.primary)
                        }
                        Text("⌛")
                            .font(.system(size: 10))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .background(theme.cellActiveBg)
                    .overlay(Capsule().stroke(theme.cardBorder, lineWidth: 1))
                    .clipShape(Capsule())
                }

                Spacer()

                Text(cleanTime(entry.nextPrayerTime))
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(theme.primary)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            .padding(11)
            .background(theme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(theme.cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            // 6 Prayers filling remaining height evenly
            let slots = prayerSlots()
            VStack(spacing: 5) {
                ForEach(slots) { slot in
                    HStack(spacing: 10) {
                        Image(systemName: slot.iconName)
                            .font(.system(size: 13, weight: slot.isNext ? .bold : .medium))
                            .foregroundColor(slot.isNext ? theme.primary : theme.secondary.opacity(0.85))
                            .frame(width: 18)

                        Text(prayerName(slot))
                            .font(.system(size: 12.5, weight: slot.isNext ? .bold : .medium))
                            .foregroundColor(slot.isNext ? theme.primary : theme.secondary)
                            .lineLimit(1)

                        Spacer()

                        Text(cleanTime(slot.time))
                            .font(.system(size: 12.5, weight: slot.isNext ? .bold : .semibold, design: .monospaced))
                            .foregroundColor(slot.isNext ? theme.primary : theme.secondary)
                            .lineLimit(1)

                        if slot.isNext {
                            Circle()
                                .fill(theme.primary)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.horizontal, 11)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(slot.isNext ? theme.cellActiveBg : theme.cardBackground.opacity(0.35))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(slot.isNext ? theme.cardBorder : Color.clear, lineWidth: slot.isNext ? 1 : 0)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(13)
        .environment(\.layoutDirection, (entry.isKurdish || entry.isArabic) ? .rightToLeft : .leftToRight)
    }

    private func shortPrayerName(_ slot: PrayerSlot) -> String {
        switch slot.id {
        case "fajr":
            return entry.isKurdish ? "بەیانی" : (entry.isArabic ? "فجر" : "Fajr")
        case "sunrise":
            return entry.isKurdish ? "خۆر" : (entry.isArabic ? "شروق" : "Sun")
        case "dhuhr":
            return entry.isKurdish ? "نیوەڕۆ" : (entry.isArabic ? "ظهر" : "Dhuhr")
        case "asr":
            return entry.isKurdish ? "عەسر" : (entry.isArabic ? "عصر" : "Asr")
        case "maghrib":
            return entry.isKurdish ? "شێوان" : (entry.isArabic ? "مغرب" : "Magh")
        case "isha":
            return entry.isKurdish ? "خەوتنان" : (entry.isArabic ? "عشاء" : "Isha")
        default:
            return prayerName(slot)
        }
    }

    // MARK: - Lock Screen Widgets (iOS 16+, No Emojis)

    @available(iOSApplicationExtension 16.0, *)
    var lockScreenRectangular: some View {
        VStack(alignment: .leading, spacing: 3) {
            // Header Row: Next Prayer Name + Time + City Indicator + Live Countdown Timer
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 3) {
                    if let nextSlot = prayerSlots().first(where: { $0.isNext }) {
                        Image(systemName: nextSlot.iconName)
                            .font(.system(size: 10, weight: .bold))
                    }
                    Text(cleanNextPrayerName)
                        .font(.system(size: 11, weight: .bold))
                        .lineLimit(1)
                    Text(cleanTime(entry.nextPrayerTime))
                        .font(.system(size: 12.5, weight: .heavy, design: .rounded))
                        .lineLimit(1)
                    if !entry.cityName.isEmpty {
                        Text("• \(entry.cityName)")
                            .font(.system(size: 8.5, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                if let target = entry.nextPrayerDate, target > Date() {
                    Text(target, style: .timer)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .lineLimit(1)
                } else if !entry.liveRemainingText.isEmpty {
                    Text(entry.liveRemainingText)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            // Subtle divider
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(height: 0.5)

            // Bottom Grid: All 6 Prayer Times (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha)
            HStack(spacing: 1.5) {
                let slots = prayerSlots()
                ForEach(slots) { slot in
                    VStack(spacing: 1) {
                        Text(shortPrayerName(slot))
                            .font(.system(size: 7.5, weight: slot.isNext ? .bold : .medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(cleanTime(slot.time))
                            .font(.system(size: 8.5, weight: slot.isNext ? .heavy : .regular, design: .monospaced))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 1.5)
                    .background(slot.isNext ? Color.white.opacity(0.22) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 3.5, style: .continuous))
                }
            }
        }
        .environment(\.layoutDirection, (entry.isKurdish || entry.isArabic) ? .rightToLeft : .leftToRight)
    }

    @available(iOSApplicationExtension 16.0, *)
    var lockScreenInline: some View {
        Text("\(entry.nextPrayerName): \(entry.nextPrayerTime)")
    }

    @available(iOSApplicationExtension 16.0, *)
    var lockScreenCircular: some View {
        VStack(spacing: 1) {
            Text(entry.nextPrayerName)
                .font(.system(size: 10, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(entry.nextPrayerTime.components(separatedBy: " ").first ?? entry.nextPrayerTime)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

// MARK: - iOS 17+ Container Background & Margin Support

extension View {
    @ViewBuilder
    func widgetBackground<V: View>(_ backgroundView: V) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            background(backgroundView)
        }
    }
}

extension WidgetConfiguration {
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}

// MARK: - Widget Entry Point

@main
struct PrayerTimesWidget: Widget {
    let kind: String = "PrayerTimesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerTimelineProvider()) { entry in
            PrayerTimesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("نەدا • کاتەکانی بانگ")
        .description("شەونمی ئارامی بۆ دڵەکان — پیشاندانی کاتەکانی بانگ و یادی خوا")
        .supportedFamilies(supportedFamiliesList)
        .contentMarginsDisabledIfAvailable()
    }

    private var supportedFamiliesList: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [
                .systemSmall, .systemMedium, .systemLarge,
                .accessoryRectangular, .accessoryInline, .accessoryCircular
            ]
        } else {
            return [.systemSmall, .systemMedium, .systemLarge]
        }
    }
}
