module UnixTimes

using Dates

export UnixTime
export unix_now
export UNIX_EPOCH


struct UnixTime <: Dates.AbstractDateTime
    instant::Dates.UTInstant{Nanosecond}
end

function UnixTime(
    y::Integer,
    m::Integer = 1,
    d::Integer = 1,
    h::Integer = 0,
    mi::Integer = 0,
    s::Integer = 0,
    ms::Integer = 0,
    us::Integer = 0,
    ns::Integer = 0)
    convert(UnixTime, DateTime(y, m, d, h, mi, s, ms)) + Nanosecond(us * 1000 + ns)
end

const UNIX_EPOCH = UnixTime(Dates.UTInstant(Nanosecond(0)))

Dates.days(x::UnixTime) = Dates.days(convert(DateTime, x))
Dates.hour(x::UnixTime) = mod(fld(Dates.value(x), 3600_000_000_000), 24)
Dates.minute(x::UnixTime) = mod(fld(Dates.value(x), 60_000_000_000), 60)
Dates.second(x::UnixTime) = mod(fld(Dates.value(x), 1_000_000_000), 60)
Dates.millisecond(x::UnixTime) = mod(fld(Dates.value(x), 1_000_000), 1000)
Dates.microsecond(x::UnixTime) = mod(fld(Dates.value(x), 1_000), 1000)
Dates.nanosecond(x::UnixTime) = mod(Dates.value(x), 1_000)

Base.:+(x::UnixTime, p::Period) =
    UnixTime(Dates.UTInstant(x.instant.periods + Nanosecond(Dates.tons(p))))

Base.:-(x::UnixTime, p::Period) = x + (-p)

function Base.:+(x::UnixTime, p::Union{Month, Year})
    trunc_ns = mod(Dates.value(x), 1_000_000)
    convert(UnixTime, convert(DateTime, x) + p) + Nanosecond(trunc_ns)
end

function Dates.DateTime(x::UnixTime)
    instant_ms = Dates.UNIXEPOCH + div(x.instant.periods.value, 1_000_000)
    DateTime(Dates.UTM(instant_ms))
end

Dates.Date(x::UnixTime) = Date(DateTime(x))
Dates.Time(x::UnixTime) = Time(Nanosecond(Dates.value(x)))

Base.convert(::Type{DateTime}, x::UnixTime) = DateTime(x)

function UnixTime(x::DateTime)
    instant_ns = (Dates.value(x) - Dates.UNIXEPOCH) * 1_000_000
    UnixTime(Dates.UTInstant(Nanosecond(instant_ns)))
end

UnixTime(x::Date) = UnixTime(DateTime(x))
UnixTime(x::Date, y::Time) =
    UnixTime(year(x), month(x), day(x), hour(y), minute(y), second(y), millisecond(y), microsecond(y), nanosecond(y))

Base.convert(::Type{UnixTime}, x::DateTime) = UnixTime(x)

function Base.show(io::IO, x::UnixTime)
    xdt = convert(DateTime, x)
    print(io, Dates.format(xdt, dateformat"yyyy-mm-ddTHH:MM:SS.sss"))
    v = x.instant.periods.value
    d = 100_000
    for i in 1:6
        print(io, div(v, d) % 10 + '0')
        d = div(d, 10)
    end
    nothing
end

function Base.floor(x::UnixTime, p::Union{DatePeriod, TimePeriod})
    convert(UnixTime, floor(convert(DateTime, x), p))
end

Dates.guess(a::UnixTime, b::UnixTime, c) = guess(DateTime(a), DateTime(b), c)

Dates.default_format(::Type{UnixTime}) = nothing
Dates.format(x::UnixTime, fmt::Nothing) = string(x)

if Sys.islinux()
    struct LinuxTimespec
        seconds::Clong
        nanoseconds::Cuint
    end
    @inline function unix_now()
        ts = Ref{LinuxTimespec}()
        ccall(:clock_gettime, Cint, (Cint, Ref{LinuxTimespec}), 0, ts)
        x = ts[]
        UnixTime(Dates.UTInstant(Nanosecond(x.seconds * 1_000_000_000 + x.nanoseconds)))
    end
else
    @inline function unix_now()
        tv = Libc.TimeVal()
        UnixTime(Dates.UTInstant(Nanosecond(tv.sec * 1_000_000_000 + tv.usec * 1_000)))
    end
end

end
