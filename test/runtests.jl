using SPSInterface
using SPSBase
using Compat

@static if VERSION >= v"0.7-"
    using Test
else
    using Base.Test
end

# write your own tests here
@testset "SPSInterface" begin
    @testset "importFile" begin
        # contents of testFile1 are hard-coded into this file
        testFile1 = joinpath(@__DIR__, "testSchedule1.dat")
        osched1, employeeList1 = importFile(testFile1)

        @test first(osched1[1]) == (9.0, 17.5) # M 9-17:30
        @test first(osched1[2]) == (9.0, 17.0) # T 9-17
        @test first(osched1[4]) == (9.0, 19.0) # R 9-19

        emp1 = employeeList1[1]
        @test isapprox(emp1.maxTime, 10) # MaxHours 10
        @test isempty(avail(emp1, 2)) && isempty(avail(emp1, :day4))

        emp2 = employeeList1[2]
        @test isapprox(emp2.maxTime, 2)
        @test isempty(avail(emp2, :day2)) && isempty(avail(emp2, :day4)) && isempty(avail(emp2, :day5))
        @test length(avail(emp2, :day1)) == 1 && first(avail(emp2, :day1)) == (9.0, 10.0)
        @test isapprox(first(avail(emp2, :day3))[2], 24+14//60)

        emp3 = employeeList1[3]
        @test isapprox(emp3.maxTime, 3)
        @test !isempty(avail(emp3, :day4))
        @test length(avail(emp3, :day4)) == 1 && first(avail(emp3, :day4)) == (10.0, 13.0)

        testFileS = joinpath(@__DIR__, "testScheduleSimple.dat")
        oschedS, employeeListS = importFile(testFileS)

        @test length(employeeListS) == 2
        @test all(isempty(last(t)) for t in oschedS)
    end
    @testset "exportFile" begin
        testFileS = joinpath(@__DIR__, "testScheduleSimple.dat")
        oschedS, employeeListS = importFile(testFileS)

        testFileSCompare = joinpath(@__DIR__, "testScheduleSimple.dat-compare")
        testFileSExpected = joinpath(@__DIR__, "testScheduleSimple.dat-expected")
        exportFile(testFileSCompare, employeeListS)

        @test read(testFileSCompare, String) == read(testFileSExpected, String)

        rm(testFileSCompare, force=true)
        # sched1BSL1 = SPSBase.BitScheduleList(employeeList1, 1//2)
        
        # @test length(sched1BSL1.vec) == length(sched1BSL1.times) >= 22

        # sched1BSL2 = SPSBase.BitScheduleList(employeeList1, 1//4)

        # @test length(sched1BSL2.vec) == length(sched1BSL2.times) >= 44

        # testFile1Compare2 = joinpath(@__DIR__, "testScheduleSimple.dat-compare2")
        # exportFile(testFile1Compare2, sched1BSL2)
    end
end