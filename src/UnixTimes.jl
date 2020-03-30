module UnixTimes

using Dates

export UnixTime
export unix_now

struct UnixTime
    instant::Dates.UTInstant{Nanosecond}
end

function Base.convert(::Type{DateTime}, x::UnixTime)
    instant_ms = Dates.UNIXEPOCH + div(x.instant.periods.value, 1_000_000)
    DateTime(Dates.UTM(instant_ms))
end

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

function unix_now()
    tv = Libc.TimeVal()
    UnixTime(Dates.UTInstant(Nanosecond(tv.sec * 1_000_000_000 + tv.usec * 1_000)))
end

end
