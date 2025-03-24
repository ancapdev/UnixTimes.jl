module UnixTimesMakieExt

using UnixTimes
using Makie
using MakieCore
using PlotUtils
using Dates

struct UnixTimeConversion <: Makie.AbstractDimConversion end

Makie.needs_tick_update_observable(conversion::UnixTimeConversion) = nothing

MakieCore.should_dim_convert(::Type{UnixTime}) = true

Makie.create_dim_conversion(::Type{UnixTime}) = UnixTimeConversion()

Makie.convert_dim_value(conversion::UnixTimeConversion, value::UnixTime) = Dates.value(value)
Makie.convert_dim_value(conversion::UnixTimeConversion, values::AbstractArray) = Dates.value.(values)

function Makie.convert_dim_observable(conversion::UnixTimeConversion, values::Observable, deregister)
    result = map(values) do vs
        Dates.value.(vs)
    end
    append!(deregister, result.inputs)
    result
end

function Makie.get_ticks(conversion::UnixTimeConversion, ticks, scale, formatter, vmin, vmax)
    # TODO: proper ticks for UnixTime
    # Main.@infiltrate
    # conversion, dates = PlotUtils.optimize_datetime_ticks(vmin, vmax; k_min=2, k_max=3)
    tickvalues = Makie.get_tickvalues(formatter, scale, vmin, vmax)
    dates = number_to_unixtime.(round.(Int64, tickvalues))
    Main.@infiltrate
    tickvalues, string.(dates)
end

number_to_unixtime(i) = UnixTime(Dates.UTInstant{Nanosecond}(Nanosecond(round(Int64, Float64(i)))))  # TODO: what type is i?

end
