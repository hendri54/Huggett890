function demographics_test()
    d = init_test_demographics();
    @test validate_demographics(d)
end

@testset "Demographics" begin
    demographics_test();
end

# -------------