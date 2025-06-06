using UnixTimes
using Dates
using TimeZones
using Test

@testset "UnixTime" begin

@testset "accessors" begin
    x = UnixTime(2020, 1, 2, 3, 4, 5, 6, 7, 8)
    @test year(x) == 2020
    @test month(x) == 1
    @test week(x) == 1
    @test day(x) == 2
    @test hour(x) == 3
    @test minute(x) == 4
    @test second(x) == 5
    @test millisecond(x) == 6
    @test microsecond(x) == 7
    @test nanosecond(x) == 8
    @test yearmonth(x) == (2020, 1)
    @test yearmonthday(x) == (2020, 1, 2)
    @test Dates.value(x) == 1577934245006007008
end

@testset "queries" begin
    x = UnixTime(2020, 1, 2, 3, 4, 5, 6, 7, 8)
    @test dayname(x) == "Thursday"
    @test dayabbr(x) == "Thu"
    @test dayofweek(x) == 4
    @test dayofmonth(x) == 2
    @test dayofweekofmonth(x) == 1
    @test daysofweekinmonth(x) == 5
    @test monthname(x) == "January"
    @test monthabbr(x) == "Jan"
    @test daysinmonth(x) == 31
    @test isleapyear(x)
    @test dayofyear(x) == 2
    @test daysinyear(x) == 366
    @test quarterofyear(x) == 1
end

@testset "conversion" begin
    @test convert(DateTime, UnixTime(2020, 1, 2, 3, 4, 5, 6, 7, 8)) == DateTime(2020, 1, 2, 3, 4, 5, 6)
    @test convert(UnixTime, DateTime(2020, 1, 2, 3, 4, 5, 6)) == UnixTime(2020, 1, 2, 3, 4, 5, 6)
end

@testset "io" begin
    x = UnixTime(2020, 1, 2, 3, 4, 5, 6, 7, 8)
    @test string(x) == "2020-01-02T03:04:05.006007008"
    @test UnixTime(string(x)) == x
    @test_throws ArgumentError UnixTime("2025-01-28T15:49:36.5901397023")
    @test_throws ArgumentError UnixTime("2025-01-28T15:49:36.59013970")
    @test_throws ArgumentError UnixTime(repeat("a", 29))
end

@testset "arithmetic" begin
    @test UnixTime(2020) + Year(1) == UnixTime(2021)
    @test UnixTime(2020) + Month(1) == UnixTime(2020, 2, 1)
    @test UnixTime(2020) + Week(1) == UnixTime(2020, 1, 8)
    @test UnixTime(2020) + Day(1) == UnixTime(2020, 1, 2)
    @test UnixTime(2020) + Hour(1) == UnixTime(2020, 1, 1, 1)
    @test UnixTime(2020) + Minute(1) == UnixTime(2020, 1, 1, 0, 1)
    @test UnixTime(2020) + Second(1) == UnixTime(2020, 1, 1, 0, 0, 1)
    @test UnixTime(2020) + Millisecond(1) == UnixTime(2020, 1, 1, 0, 0, 0, 1)
    @test UnixTime(2020) + Microsecond(1) == UnixTime(2020, 1, 1, 0, 0, 0, 0, 1)
    @test UnixTime(2020) + Nanosecond(1) == UnixTime(2020, 1, 1, 0, 0, 0, 0, 0, 1)
    @test UnixTime(2020, 1, 1, 10) - UnixTime(2020, 1, 1, 9) == Nanosecond(60 * 60 * 1_000_000_000)
end

@testset "rounding" begin
    @test floor(UnixTime(2020, 1, 1, 9, 9, 9), Day(1)) == UnixTime(2020, 1, 1)
    @test floor(UnixTime(2020, 1, 1, 9, 9, 9), Hour(1)) == UnixTime(2020, 1, 1, 9)
    @test floor(UnixTime(2020, 1, 1, 9, 9, 9), Minute(1)) == UnixTime(2020, 1, 1, 9, 9)
    @test floor(UnixTime(2020, 1, 1, 9, 9, 9), Second(5)) == UnixTime(2020, 1, 1, 9, 9, 5)
end

@testset "now" begin
    @test unix_now() isa UnixTime
    t1 = unix_now()
    sleep(Millisecond(100))
    t2 = unix_now()
    @test t2 > t1
end

@testset "conversion" begin
    @test UnixTime(DateTime(2020, 1, 2, 3)) == UnixTime(2020, 1, 2, 3)
    @test DateTime(UnixTime(2020, 1, 2, 3)) == DateTime(2020, 1, 2, 3)
    @test Date(UnixTime(2020, 1, 2, 3)) == Date(2020, 1, 2)
    @test Time(UnixTime(2020, 1, 2, 3, 4, 5, 6, 7, 8)) == Time(3, 4, 5, 6, 7, 8)
    @test UnixTime(Date(2020, 1, 2)) == UnixTime(2020, 1, 2)
    @test UnixTime(Date(2020, 1, 2), Time(3, 4, 5, 6, 7, 8)) == UnixTime(2020, 1, 2, 3, 4, 5, 6, 7, 8)
    @test convert(UnixTime, DateTime(2020, 1, 2, 3)) == UnixTime(2020, 1, 2, 3)
    @test convert(DateTime, UnixTime(2020, 1, 2, 3)) == DateTime(2020, 1, 2, 3)
    @test UnixTime(ZonedDateTime(2020, 1, 2, 3, tz"UTC-4")) == UnixTime(2020, 1, 2, 7)
    @test ZonedDateTime(UnixTime(2020, 1, 2, 7), tz"UTC-4") == ZonedDateTime(2020, 1, 2, 3, tz"UTC-4")
end

@testset "collect" begin
    t1 = UnixTime(2024,7,18,10,0,0)
    t2 = UnixTime(2024,7,18,10,0,10)
    p = Millisecond(100)
    @test collect(t1:p:t2) isa Vector
end

end
