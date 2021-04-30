function model_test()
    m = init_model();
    @test validate_model(m);
end

@testset "Model" begin
    model_test();
end

# ------------