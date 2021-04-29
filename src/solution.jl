## ----------  Retired 

RetiredSolution() = RetiredSolution(nothing, nothing);

function init_test_retired_solution()
    kPrimeFct(x) = 0.5 * x;
    cFct(x) = 0.3 * x;
    return RetiredSolution(kPrimeFct, cFct)
end

kprime(sol :: RetiredSolution, k) = sol.kPrimeFct(k);
consumption(sol :: RetiredSolution, k) = sol.cFct(k);


## ------------  Worker

WorkerSolution() = WorkerSolution(nothing, nothing);

function init_test_worker_solution(n :: Integer = 4)
    kPrimeFctV = [x -> 0.5 * x  for j = 1 : n];
    cFctV = [x -> 0.3 * x  for j = 1 : n];
    return WorkerSolution(kPrimeFctV, cFctV)
end

kprime(sol :: WorkerSolution, k, eIdx) = sol.kPrimeFctV[eIdx](k);
consumption(sol :: WorkerSolution, k, eIdx) = sol.cFctV[eIdx](k);


## ------------  Complete

function init_solution(Twork :: Integer, T :: Integer)
    workV = [WorkerSolution()  for t = 1 : Twork];
    retireV = [RetiredSolution() for t = (Twork+1) : T];
    return Solution(workV, retireV)
end

function init_test_solution(Twork :: Integer, T :: Integer)
    workV = [init_test_worker_solution()  for t = 1 : Twork];
    retireV = [init_test_retired_solution() for t = (Twork+1) : T];
    return Solution(workV, retireV)
end



## -----------  Helpers

workspan(sol :: Solution) = length(sol.workV);
isretired(sol :: Solution, t :: Integer) = (t > workspan(sol));

function set_solution!(sol :: Solution, t :: Integer, kPrimeFct)
    if isretired(sol, t)
        sol.retireV[t] = kPrimeFct;
    else
        sol.workV[t] = kPrimeFct;
    end
end

# ---------------