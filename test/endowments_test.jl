function endowments_test()
    e = init_test_endowments(40);
    @test validate_endowments(e);
end

@testset "Endowments" begin
    endowments_test();
end

# ---------------