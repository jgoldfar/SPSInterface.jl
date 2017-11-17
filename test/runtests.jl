using SPSInterface
using Base.Test

# write your own tests here
@testset "SPSInterface" begin
    @testset "importFile" begin
        testFile1 = joinpath(@__DIR__, "testSchedule1.dat")
        osched1, employeeList1 = importFile(testFile1)
        @test employeeList1 isa Vector{Employee}
    end
    @testset "exportFile" begin

    end
end