using Huggett890, Test

function euler_test()
    @testset "Euler" begin
        m = init_model();
        t = 2;  # test other ages +++++
        k = 5.0;
        eIdx = 3;
        kPrimeTomorrow = init_test_worker_solution(eIdx + 1);

        kPrime = Huggett890.solve_one_point(m, t, k, eIdx, kPrimeTomorrow);
        dev = Huggett890.euler_dev_one_point(m, t, k, eIdx, kPrime, kPrimeTomorrow);
        @test kPrime >= Huggett890.kprime_min(m.kGrid, t);
        @test kPrime <= Huggett890.kprime_max(m.kGrid, t);
        @test abs(dev) < 1e-4
        # dev2 = Huggett890.euler_dev_one_point2(m, t, k, kPrime, kPrimeTomorrow);
        # @test abs(dev2) < 1e-4

        # Euler needs more direct test +++++
    end
end

function solve_worker_test()
    @testset "Solve worker" begin
        m = init_model();

        # Just a syntax test. Need to solve t and t+1 for substantive testing.
        t = 3; # test other ages +++++
        k = 5.0;
        eIdx = 2;
        nEff = 4;
        kPrimeTomorrow = init_test_worker_solution(nEff);
        sol = Huggett890.solve_one_period(m, kPrimeTomorrow, t);

        Huggett890.solve_worker(m);
        # +++++  @test Huggett890.check_retired_solution(m, sol)
    end
end

function solve_period_test()
    @testset "One period" begin
        m = init_model();
        t = 2;
        k = 5.0;
        nEff = 4;
        eIdx = 2;
        kPrimeTomorrow = init_test_worker_solution(nEff);
        kPrimeFct, cFct = hg.solve_one_efficiency(m, t, eIdx, kPrimeTomorrow);
        kPrime = kPrimeFct(k);
        eMu = hg.e_uprime_c(m, t, eIdx, kPrime, kPrimeTomorrow);
        c = cFct(k);
        muC = hg.marg_utility(m.util, c);
        dev2 = muC / eMu - hg.betar(m);
        # Surprisingly imprecise +++
        @test abs(dev2) < 1e-2

        eff = hg.efficiency(m.endow, eIdx);
        kPrimeMin, kPrimeMax = hg.kprime_range(m, t, k, eff);
        @test kPrimeMax > kPrimeMin
        kPrime2 = hg.solve_one_point(m, t, k, eIdx, kPrimeTomorrow);
        @test isapprox(kPrime2, kPrime)
    end
end


function solve_test()
    @testset "Solve" begin
        m = init_model();
        sol = solve_worker(m);
        @test sol isa Solution
    end
end

@testset "Worker" begin
    euler_test();
    solve_period_test();
    solve_worker_test();
    solve_test();
end

# -----------