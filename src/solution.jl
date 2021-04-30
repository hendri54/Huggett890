## ----------  Retired 

RetiredSolution() = RetiredSolution(nothing, nothing);

function init_test_retired_solution()
    kPrimeFct(x) = 0.5 * x;
    cFct(x) = 0.3 * x;
    return RetiredSolution(kPrimeFct, cFct)
end

kprime_fct(sol :: RetiredSolution; eIdx = 0) = sol.kPrimeFct;
cons_fct(sol :: RetiredSolution; eIdx = 0) = sol.cFct;
kprime(sol :: RetiredSolution, k) = kprime_fct(sol)(k);
consumption(sol :: RetiredSolution, k) = cons_fct(sol)(k);


## ------------  Worker

WorkerSolution() = WorkerSolution(nothing, nothing);

function init_test_worker_solution(n :: Integer = 4)
    kPrimeFctV = [x -> 0.5 * x  for j = 1 : n];
    cFctV = [x -> 0.3 * x  for j = 1 : n];
    return WorkerSolution(kPrimeFctV, cFctV)
end

# test this +++++
kprime_fct(sol :: WorkerSolution; eIdx = 0) = sol.kPrimeFctV[eIdx];
cons_fct(sol :: WorkerSolution; eIdx = 0) = sol.cFctV[eIdx];
kprime(sol :: WorkerSolution, k; eIdx = 0) = kprime_fct(sol; eIdx = eIdx)(k);
consumption(sol :: WorkerSolution, k; eIdx = 0) = cons_fct(sol; eIdx = eIdx)(k);


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
retire_idx(sol :: Solution, t :: Integer) = t - workspan(sol);

# test this +++++
function get_solution(sol :: Solution, t :: Integer; eIdx = 0)
    if isretired(sol, t)
        @assert eIdx == 0
        solOut = sol.retireV[retire_idx(sol, t)];
    else
        @assert eIdx > 0
        solOut = sol.workV[t];
    end
    return solOut 
end

kprime(sol :: Solution, t :: Integer, k; eIdx = 0) =
    kprime_fct(sol, t; eIdx = eIdx)(k);
consumption(sol :: Solution, t :: Integer, k; eIdx = 0) =
    cons_fct(sol, t; eIdx = eIdx)(k);

# test this +++++
kprime_fct(sol :: Solution, t :: Integer; eIdx = 0) = 
    kprime_fct(get_solution(sol, t); eIdx = eIdx);
cons_fct(sol :: Solution, t :: Integer; eIdx = 0) = 
    cons_fct(get_solution(sol, t); eIdx = eIdx);

# test this +++++
# may have to take eIdx input
function set_solution!(sol :: Solution, t :: Integer, kPrimeFct)
    if isretired(sol, t)
        sol.retireV[retire_idx(sol, t)] = kPrimeFct;
    else
        sol.workV[t] = kPrimeFct;
    end
end

# ---------------