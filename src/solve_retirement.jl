function solve_retirement!(m :: Model, sol :: Solution)
    solve_last_period!(m, sol);
    for t = (lifespan(m) - 1) : -1 : (workspan(m) + 1)
        solve_retirement_period!(m, sol, t);
    end
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
    @assert isretired(m, t)
    kPrimeTomorrow = kprime_fct(sol, t+1);
    newSol = solve_retirement_period(m, kPrimeTomorrow, t);
    set_solution!(sol, t, newSol);
end

# test this +++++
# The key input here is `kPrimeTomorrow = k'' = G(k', t+1)`.
# This is tomorrow's policy function.
function solve_retirement_period(m :: Model, kPrimeTomorrow, t :: Integer)
    kGridV = make_k_grid(m, t);
    kPrimeV = zeros(length(kGridV));
    for (ik, k) in enumerate(kGridV)
        kPrimeV[ik] = solve_one_retirement_point(m, t, k, kPrimeTomorrow);
    end
    kPrimeFct = interpolate_kprime(kGridV, kPrimeV);
    cV = consumption(m.budget, t, kGridV, kPrimeV);
    cFct = interpolate_kprime(kGridV, cV);
    return RetiredSolution(kPrimeFct, cFct)
end


# Solve for one point, keeping in mind that the capital grid defines bounds for k'.
# Therefore, we may have corner solutions.
function solve_one_retirement_point(m :: Model, t, k, kPrimeTomorrow)
    kPrimeMin = kprime_min(m.kGrid, t);
    kPrimeMax = min(kprime_max(m.budget, t, k), kprime_max(m.kGrid, t));
    @assert kPrimeMax > kPrimeMin

    # Define a closure that can be passed to root finding
    e_dev(kPrime) = euler_dev_one_point(m, t, k, kPrime, kPrimeTomorrow);

    # Try corners
    eDev0 = e_dev(kPrimeMin);
    if eDev0 <= 0.0
        kPrime = kPrimeMin;
    else
        eDevMax = e_dev(kPrimeMax);
        if eDevMax >= 0.0
            kPrime = kPrimeMax
        else
            # Now we know the solution is interior
            kPrime = find_zero(e_dev, (kPrimeMin, kPrimeMax, Bisection()));
        end
    end
    @assert kPrimeMin <= kPrime <= kprime_max(m.kGrid, t)
    return kPrime
end

# Euler equation deviation.
# `dev > 0` means that `kPrime` implies a `c` today that is too high.
# We use the form `c - U'^{-1}(βR U'(c'))`.
function euler_dev_one_point(m :: Model, t, k, kPrime, kPrimeTomorrow)
    cPrime = consumption(m.budget, t+1, kPrime, kPrimeTomorrow(kPrime));
    # βR U'(c')
    betaRUprime = betar(m) * marg_utility(m.util, cPrime);
    cToday = consumption(m.budget, t, k, kPrime);
    dev = cToday - inv_marg_utility(m.util, betaRUprime);
    return dev
end

# Alternative Euler equation deviation.
# Easier to understand, but more non-linear.
function euler_dev_one_point2(m :: Model, t, k, kPrime, kPrimeTomorrow)
    c = consumption(m.budget, t, k, kPrime);
    kPrimePrime = kPrimeTomorrow(kPrime);
    cPrime = consumption(m.budget, t+1, kPrime, kPrimePrime);
    # This returns a `Vector` of length 1
    eDev = euler_dev(m, [c, cPrime]);
    # But we want to return a scalar. That's what `only` does.
    return only(eDev)
end


function interpolate_kprime(kGridV :: AbstractVector{F}, kPrimeV :: AbstractVector{F}) where F
    interp = LinearInterpolation(kGridV, kPrimeV);
    return interp
end


function check_retired_solution(m :: Model, sol :: Solution)
    bcValid = true;
    eulerValid = true;

    for t = (workspan(m) + 1) : (lifespan(m) - 1)
        kGridV = make_k_grid(m, t);
        kp_fct = kprime_fct(sol, t);
        c_fct = cons_fct(sol, t);
        wage_t = wage(m);
        for (ik, k) in enumerate(kGridV)
            kPrime = kp_fct(k);
            c = consumption(m.budget, t, k, kPrime);
            bcValid = bcValid && isapprox(c, c_fct(k), atol = 1e-4);

            if kprime_min(m.kGrid, t) < kPrime < kprime_max(m.kGrid, t)
                # Interior point
                kpp_fct = kprime_fct(sol, t+1);
                kPrimePrime = kpp_fct(kPrime);
                cPrime = consumption(m.budget, t+1, kPrime, kPrimePrime);
                eDev = only(euler_dev(m, [c, cPrime]));
                eulerValid = eulerValid && abs(eDev < 1e-4);
            end
        end
    end

    if !bcValid
        @warn "Budget constraint violated"
    end
    if !eulerValid
        @warn "Euler equation violated"
    end

    return bcValid  &&  eulerValid
end


# ------------