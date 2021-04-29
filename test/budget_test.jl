function budget_test()
    b = init_test_budget();
    @test validate_budget(b);

    k = [1.2, 2.4];
    efficiency = [0.9, 2.1];
    
    y = income(b, k, efficiency);
    @test size(y) == size(k)

    kp = kprime(b, k, 0.0, efficiency);
    @test isapprox(y, kp)
    
    c = 0.6;
    kp = kprime(b, k, c, efficiency);
    @test size(kp) == size(k)

    c2 = consumption(b, k, kp, efficiency);
    @test size(c2) == size(k)
    @test all(isapprox.(c, c2))
end

function retired_test()
    b = init_test_budget();
    k = [1.2, 2.4];
    
    y = retired_income(b, k);
    @test size(y) == size(k)

    kp = retired_kprime(b, k, 0.0);
    @test isapprox(y, kp)
    
    c = 0.6;
    kp = retired_kprime(b, k, c);
    @test size(kp) == size(k)

    c2 = retired_consumption(b, k, kp);
    @test size(c2) == size(k)
    @test all(isapprox.(c, c2))
end


@testset "Budget" begin
    budget_test();
    retired_test();
end

# -----------