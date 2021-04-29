function solve_model(m :: Model)
    sol = Solution(workspan(m), lifespan(m));
    solve_last_period!(m, sol);
    for t = (lifespan(m) - 1) : -1 : 1
        if isretired(m, t)
            solve_retirement_period!(m, sol, t);
        else
            solve_work_period!(m, sol, t);
        end
    end
    return sol
end

function solve_last_period!(m :: Model, sol :: Solution)
    set_solution!(sol, lifespan(m), solve_last_period(m));
end

# This is copied almost verbatim from our previous model (without shocks).
# Returns functions `k' = G(k, T)` and `c = H(k, T)`.
function solve_last_period(m :: Model)
    T = lifespan(m);
    kGridV = make_k_grid(m, T);
    kPrimeFct = interpolate_kprime(kGridV, zeros(length(kGridV)));
    cV = consumption(m, T, kGridV, 0.0);
    cFct = interpolate_kprime(kGridV, cV);
    return RetiredSolution(kPrimeFct, cFct)
end


function solve_retirement_period!(m :: Model, sol :: Solution, t :: Integer)
    set_solution!(sol, t, solve_retirement_period())
end

# stub +++++
function solve_retirement_period()
    kPrimeFct = nothing;
    cFct = nothing;
    return RetiredSolution(kPrimeFct, cFct)
end


function solve_work_period!(m :: Model, sol :: Solution, t :: Integer)
    set_solution!(sol, t, solve_work_period())
end

# stub +++++
function solve_work_period()
    kPrimeFct = nothing;
    cFct = nothing;
    return WorkSolution(kPrimeFct, cFct)
end

function interpolate_kprime(kGridV :: AbstractVector{F}, kPrimeV :: AbstractVector{F}) where F
    interp = LinearInterpolation(kGridV, kPrimeV);
    return interp
end


# -----------------