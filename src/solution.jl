## ----------  Retired 

# RetiredSolution() = RetiredSolution(nothing, nothing);

# function init_test_retired_solution()
#     kPrimeFct(x) = 0.5 * x;
#     cFct(x) = 0.3 * x;
#     return RetiredSolution(kPrimeFct, cFct)
# end

# kprime_fct(sol :: RetiredSolution; eIdx = 0) = sol.kPrimeFct;
# cons_fct(sol :: RetiredSolution; eIdx = 0) = sol.cFct;
# kprime(sol :: RetiredSolution, k) = kprime_fct(sol)(k);
# consumption(sol :: RetiredSolution, k) = cons_fct(sol)(k);


## ------------  Worker

init_worker_solution(n :: Integer) = 
    WorkerSolution(Vector{Any}(undef, n), Vector{Any}(undef, n));
# WorkerSolution() = WorkerSolution(nothing, nothing);

# n is the number of efficiency states
# n = 1 in retirement
function init_test_worker_solution(n :: Integer = 4)
    kPrimeFctV = [x -> (0.25 + 0.05 * j) * x  for j = 1 : n];
    cFctV = [x -> (0.3 + 0.1 * j) * x  for j = 1 : n];
    return WorkerSolution(kPrimeFctV, cFctV)
end

kprime_fct(sol :: WorkerSolution, eIdx) = sol.kPrimeFctV[eIdx];
cons_fct(sol :: WorkerSolution, eIdx) = sol.cFctV[eIdx];
kprime(sol :: WorkerSolution, k, eIdx) = kprime_fct(sol, eIdx)(k);
consumption(sol :: WorkerSolution, k, eIdx) = cons_fct(sol, eIdx)(k);
set_kprime_fct!(sol :: WorkerSolution, eIdx, kpFct) = sol.kPrimeFctV[eIdx] = kpFct;
set_cons_fct!(sol :: WorkerSolution, eIdx, kpFct) = sol.consFctV[eIdx] = kpFct;


## ------------  Complete

function init_solution(Twork :: Integer, T :: Integer, n :: Integer)
    workV = [init_worker_solution(n)  for t = 1 : T];
    retireV = [init_worker_solution(1) for t = (Twork+1) : T];
    return Solution(Twork, vcat(workV, retireV))
end

function init_test_solution(Twork :: Integer, T :: Integer)
    workV = [init_test_worker_solution(4)  for t = 1 : Twork];
    retireV = [init_test_worker_solution(1) for t = (Twork+1) : T];
    return Solution(Twork, vcat(workV, retireV))
end



## -----------  Helpers

workspan(sol :: Solution) = sol.workSpan;
isretired(sol :: Solution, t :: Integer) = (t > workspan(sol));
# retire_idx(sol :: Solution, t :: Integer) = t - workspan(sol);

function get_solution(sol :: Solution, t :: Integer)
    solOut = sol.solV[t];
end

kprime(sol :: Solution, t :: Integer, k, eIdx) =
    kprime_fct(sol, t, eIdx)(k);
consumption(sol :: Solution, t :: Integer, k, eIdx) =
    cons_fct(sol, t, eIdx)(k);

kprime_fct(sol :: Solution, t :: Integer, eIdx) = 
    kprime_fct(get_solution(sol, t), eIdx);
cons_fct(sol :: Solution, t :: Integer, eIdx) = 
    cons_fct(get_solution(sol, t), eIdx);

function set_solution!(sol :: Solution, t :: Integer, wkSol :: WorkerSolution)
    sol.solV[t] = wkSol;
end

# ---------------