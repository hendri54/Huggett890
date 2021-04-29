function retired_sol_test()
    @testset "Retired solution" begin
        sol = init_test_retired_solution();
        k = 2.3;
        kp = kprime(sol, k);
        @test kp isa Float64
        c = consumption(sol, k);
        @test c isa Float64
        @test c > 0.0
    end
end

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
        end
    end
end

function solution_test()
    @testset "Solution" begin
        Twork = 4;
        T = 7;
        sol = init_solution(Twork, T);
        @test sol isa Solution

        sol = init_test_solution(Twork, T);
        @test sol isa Solution
    end
end

@testset "Solution" begin
    retired_sol_test();
    solution_test();
end

# --------------