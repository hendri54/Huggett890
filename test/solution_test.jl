using Huggett890, Test

hg = Huggett890;

# function retired_sol_test()
#     @testset "Retired solution" begin
#         sol = init_test_retired_solution();
#         k = 2.3;
#         kp = kprime(sol, k);
#         @test kp isa Float64
#         c = consumption(sol, k);
#         @test c isa Float64
#         @test c > 0.0
#     end
# end

function worker_sol_test()
    @testset "Worker solution" begin
        n = 4;
        sol = init_test_worker_solution(n);
        k = 2.3;
        for eIdx = 1 : n
            kp = kprime(sol, k, eIdx);
            @test kp isa Float64
            c = consumption(sol, k, eIdx);
            @test c isa Float64
            @test c > 0.0

            kpFct = hg.kprime_fct(sol, eIdx);
            kp2 = kpFct(k);
            @test isapprox(kp2, kp)
            cFct = hg.cons_fct(sol, eIdx);
            c2 = cFct(k);
            @test isapprox(c2, c)
        end
    end
end

function solution_test()
    @testset "Solution" begin
        Twork = 4;
        T = 7;
        n = 4;
        k = 3.0;
        sol = init_solution(Twork, T, n);
        @test sol isa Solution

        sol = init_test_solution(Twork, T);
        @test sol isa Solution

        for t = 1 : T
            if hg.isretired(sol, t)
                eIdx = 1;
            else
                eIdx = 3;
            end
            wkSol = hg.get_solution(sol, t);
            kp = hg.kprime(wkSol, k, eIdx);
            kp2 = hg.kprime(sol, t, k, eIdx);
            @test isapprox(kp, kp2)
            c = hg.consumption(wkSol, k, eIdx);
            c2 = consumption(sol, t, k, eIdx);
            @test isapprox(c, c2)
        end
    end
end

function set_solution_test()
    @testset "Set solution" begin
        Twork = 4;
        T = 7;
        n = 4;
        sol = init_solution(Twork, T, n);

        t = 3;
        eIdx = 2;
        wkSol = hg.init_test_worker_solution(n);
        hg.set_solution!(sol, t, wkSol);

        k = 3.4;
        kp = hg.kprime(sol, t, k, eIdx);
        kp2 = hg.kprime(wkSol, k, eIdx);
        @test isapprox(kp, kp2)
    end
end

@testset "Solution" begin
    # retired_sol_test();
    worker_sol_test();
    solution_test();
    set_solution_test();
end

# --------------