module UnixTimesTimeZonesExt

using Dates
using TimeZones
using UnixTimes

UnixTimes.UnixTime(x::ZonedDateTime) = UnixTime(DateTime(x, UTC))
TimeZones.ZonedDateTime(x::UnixTime, tz::TimeZone) =
    ZonedDateTime(DateTime(x), tz; from_utc = true)

end
