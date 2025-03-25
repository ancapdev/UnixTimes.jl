module UnixTimesMakieExt

using UnixTimes
using Makie
using Observables
using Dates

struct UnixTimeConversion <: Makie.AbstractDimConversion
    custom_epoch::Observable{Union{Nothing, UnixTime}}
    function UnixTimeConversion(custom_epoch = nothing)
        new(Observable{Union{Nothing, UnixTime}}(custom_epoch; ignore_equal_values=true))
    end
end

function number_to_unixtime(conversion::UnixTimeConversion, i)
    Nanosecond(round(Int64, Float64(i))) + something(conversion.custom_epoch[], UNIX_EPOCH)
end

Makie.needs_tick_update_observable(conversion::UnixTimeConversion) = nothing

Makie.MakieCore.should_dim_convert(::Type{UnixTime}) = true

Makie.create_dim_conversion(::Type{UnixTime}) = UnixTimeConversion()

function Makie.convert_dim_value(conversion::UnixTimeConversion, value::UnixTime)
    Dates.value(value - something(conversion.custom_epoch[], UNIX_EPOCH))
end
function Makie.convert_dim_value(conversion::UnixTimeConversion, values::AbstractArray{UnixTime})
    Dates.value.(values .- something(conversion.custom_epoch[], UNIX_EPOCH))
end

function Makie.convert_dim_observable(conversion::UnixTimeConversion, values::Observable, deregister)
    if conversion.custom_epoch[] === nothing
        conversion.custom_epoch[] = last(values[])
    end

    result = map(values, conversion.custom_epoch) do vs, ep
        Dates.value.(vs .- something(ep, UNIX_EPOCH))
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
