module UnixTimesStructTypesExt

using Dates
using StructTypes
using UnixTimes

StructTypes.StructType(::Type{UnixTime}) = StructTypes.CustomStruct()
StructTypes.lower(x::UnixTime) = Dates.value(x)
StructTypes.lowertype(::Type{UnixTime}) = Int64
StructTypes.construct(::Type{UnixTime}, x::Int64) =
    UnixTime(Dates.UTInstant(Dates.Nanosecond(x)))

end
