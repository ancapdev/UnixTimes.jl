module UnixTimesMakieExt

using UnixTimes
using Makie
using Observables
using Dates

struct UnixTimeConversion <: Makie.AbstractDimConversion
    custom_epoch::Observable{UnixTime}
    function UnixTimeConversion(custom_epoch = UNIX_EPOCH)
        new(Observable{UnixTime}(custom_epoch; ignore_equal_values=true))
    end
end

function number_to_unixtime(conversion::UnixTimeConversion, i)
    Nanosecond(round(Int64, Float64(i))) + conversion.custom_epoch[]
end
function unixtime_to_number(conversion::UnixTimeConversion, value::UnixTime)
    Dates.value(value - conversion.custom_epoch[])
end

Makie.expand_dimensions(::PointBased, y::AbstractVector{<:UnixTime}) = (keys(y), y)

Makie.needs_tick_update_observable(conversion::UnixTimeConversion) = conversion.custom_epoch

Makie.should_dim_convert(::Type{UnixTime}) = true

Makie.create_dim_conversion(::Type{UnixTime}) = UnixTimeConversion()

function Makie.convert_dim_value(conversion::UnixTimeConversion, value::UnixTime)
    unixtime_to_number(conversion, value)
end
function Makie.convert_dim_value(conversion::UnixTimeConversion, values::AbstractArray{UnixTime})
    unixtime_to_number.(tuple(conversion), values)
end
function Makie.convert_dim_value(conversion::UnixTimeConversion, attr, values, prev_values)
    unixtime_to_number.(tuple(conversion), values)
end

function Makie.convert_dim_observable(conversion::UnixTimeConversion, values::Observable, deregister)
    result = map(values, conversion.custom_epoch) do vs, ep
        Dates.value.(vs .- ep)
    end
    append!(deregister, result.inputs)
    result
end

function Makie.get_ticks(conversion::UnixTimeConversion, ticks, scale, formatter, vmin, vmax)
    tickvalues = Makie.get_tickvalues(formatter, scale, vmin, vmax)
    dates = number_to_unixtime.(Ref(conversion), tickvalues)
    tickvalues, string.(dates)
end

end
