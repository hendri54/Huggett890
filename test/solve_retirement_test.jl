using Huggett890, Test

function euler_test()
    @testset "Euler" begin
        m = init_model();
        t = Huggett890.workspan(m) + 1;
        k = 5.0;
        kPrimeTomorrow(kPrime) = 0.5 .* kPrime;

        kPrime = Huggett890.solve_one_retirement_point(m, t, k, kPrimeTomorrow);
        dev = Huggett890.euler_dev_one_point(m, t, k, kPrime, kPrimeTomorrow);
        @test kPrime >= Huggett890.kprime_min(m.kGrid, t);
        @test kPrime <= Huggett890.kprime_max(m.kGrid, t);
        @test abs(dev) < 1e-4
        dev2 = Huggett890.euler_dev_one_point2(m, t, k, kPrime, kPrimeTomorrow);
        @test abs(dev2) < 1e-4
    end
end

function solve_retirement_test()
    @testset "Solve retirement" begin
        m = init_model();

        # Just a syntax test. Need to solve t and t+1 for substantive testing.
        t = Huggett890.workspan(m) + 1;
        k = 5.0;
        kPrimeTomorrow(kPrime) = 0.5 .* kPrime;
        sol = Huggett890.solve_retirement_period(m, kPrimeTomorrow, t);

        sol = init_solution(Huggett890.workspan(m), Huggett890.lifespan(m));
        Huggett890.solve_retirement!(m, sol);
        @test Huggett890.check_retired_solution(m, sol)
    end
end

function solve_test()
    @testset "Solve" begin
        m = init_model();
        kPrime_tV = solve_model(m);
    end
end

@testset "Retirement" begin
    euler_test();
    solve_retirement_test();
    # +++++ solve_test();
end

# -----------