

## ----------  Work 

function solve_work!(m :: Model, sol :: Solution)
    for t = workspan(m) : -1 : 1
        solve_work_period!(m, sol, t);
    end
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

# function interpolate_kprime(kGridV :: AbstractVector{F}, kPrimeV :: AbstractVector{F}) where F
#     interp = LinearInterpolation(kGridV, kPrimeV);
#     return interp
# end


# -----------------