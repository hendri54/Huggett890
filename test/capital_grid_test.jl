function capital_grid_test()
    kGrid = init_test_capital_grid();
    @test validate_capital_grid(kGrid);

    t = 5;
    kGridV = make_k_grid(kGrid, t);
    @test validate_capital_grid(kGridV);
end

@testset "Capital grid" begin
    capital_grid_test();
end

# ------------