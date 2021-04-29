function capital_grid_test()
    kGrid = init_test_capital_grid();
    @test validate_capital_grid(kGrid);
end

@testset "Capital grid" begin
    capital_grid_test();
end

# ------------