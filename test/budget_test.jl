function budget_test(retired :: Bool)
    lastWorkAge = 30;
    b = init_test_budget(lastWorkAge);
    @test validate_budget(b);

    if retired
        t = lastWorkAge + 1;
        efficiency = 0.0;
    else
        t = lastWorkAge;
        efficiency = [0.9, 2.1];
    end

    k = [1.2, 2.4];
   
    y = income(b, t, k, efficiency);
    @test size(y) == size(k)

    kp = kprime(b, t, k, 0.0, efficiency);
    @test isapprox(y, kp)
    
    c = 0.6;
    kp = kprime(b, t, k, c, efficiency);
    @test size(kp) == size(k)

    c2 = consumption(b, t, k, kp, efficiency);
    @test size(c2) == size(k)
    @test all(isapprox.(c, c2))
end

# function retired_test()
#     b = init_test_budget();
#     k = [1.2, 2.4];
    
#     y = retired_income(b, k);
#     @test size(y) == size(k)

#     kp = retired_kprime(b, k, 0.0);
#     @test isapprox(y, kp)
    
#     c = 0.6;
#     kp = retired_kprime(b, k, c);
#     @test size(kp) == size(k)

#     c2 = retired_consumption(b, k, kp);
#     @test size(c2) == size(k)
#     @test all(isapprox.(c, c2))
# end


@testset "Budget" begin
    for retired in [true, false]
        budget_test(retired);
    end
    # retired_test();
end

# -----------