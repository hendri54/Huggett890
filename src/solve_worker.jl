function solve_worker(m :: Model)
    sol = init_solution(workspan(m), lifespan(m), n_efficiencies(m, 1));
    solve_last_period!(m, sol);
    for t = (lifespan(m) - 1) : -1 : (workspan(m) + 1)
        solve_one_period!(m, sol, t);
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
    # kPrime and efficiency are 0
    cV = consumption(m, T, kGridV, 0.0, 0.0);
    cFct = interpolate_kprime(kGridV, cV);
    return WorkerSolution([kPrimeFct], [cFct])
end


function solve_one_period!(m :: Model, sol :: Solution, t :: Integer)
    newSol = solve_one_period(m, get_solution(sol, t+1), t);
    set_solution!(sol, t, newSol);
end

# test this +++++
# The key input here is `kPrimeTomorrow = k'' = G(k', e', t+1)`.
# This is tomorrow's policy function.
function solve_one_period(m :: Model, kPrimeTomorrow :: WorkerSolution, t :: Integer)
    ne = n_efficiencies(m, t);
    kPrimeFctV = Vector{Any}(undef, ne);
    cFctV = Vector{Any}(undef, ne);
    for eIdx = 1 : ne
        kPrimeFctV[eIdx], cFctV[eIdx] = 
            solve_one_efficiency(m, t, eIdx, kPrimeTomorrow);
    end
    return WorkerSolution(kPrimeFctV, cFctV)
end


function solve_one_efficiency(m :: Model, t, eIdx, kPrimeTomorrow :: WorkerSolution)
    kGridV = make_k_grid(m, t);
    kPrimeV = zeros(length(kGridV));
    for (ik, k) in enumerate(kGridV)
        kPrimeV[ik] = solve_one_point(m, t, k, eIdx, kPrimeTomorrow);
    end
    kPrimeFct = interpolate_kprime(kGridV, kPrimeV);
    eff = efficiency(m.endow, eIdx);
    cV = consumption(m.budget, t, kGridV, kPrimeV, eff);
    cFct = interpolate_kprime(kGridV, cV);
    return kPrimeFct, cFct
end


# Solve for one point, keeping in mind that the capital grid defines bounds for k'.
# Therefore, we may have corner solutions.
function solve_one_point(m :: Model, t, k, eIdx, kPrimeTomorrow)
    eff = efficiency(m.endow, eIdx);
    kPrimeMin, kPrimeMax = kprime_range(m, t, k, eff);
    @assert (kPrimeMax > kPrimeMin)  "No feasible kPrime for k = $k: $kPrimeMin, $kPrimeMax"

    # Define a closure that can be passed to root finding
    e_dev(kPrime) = euler_dev_one_point(m, t, k, eIdx, kPrime, kPrimeTomorrow);

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
            kPrime = find_zero(e_dev, (kPrimeMin, kPrimeMax), Bisection());
        end
    end
    @assert kPrimeMin <= kPrime <= kprime_max(m.kGrid, t)
    return kPrime
end

# Euler equation deviation.
# `dev > 0` means that `kPrime` implies a `c` today that is too high.
# We use the form `c - U'^{-1}(βR U'(c'))`.
function euler_dev_one_point(m :: Model, t :: Integer, k, eIdx :: Integer, 
    kPrime, kPrimeTomorrow)

    cPrimeV, prob_ePrimeV = cprime_distribution(m, t, eIdx, 
        kPrime, kPrimeTomorrow);
    # if isretired(m, t+1)
    #     prob_ePrimeV = [1.0];
    # else
    #     prob_ePrimeV = prob_eprime(m.endow, eIdx);
    # end
    ePrimeV = 1 : length(prob_ePrimeV);
    rhs = 0.0;
    # for ePrimeIdx in ePrimeV
        # effPrime = efficiency(m.endow, eIdx);
        # kPrimePrime = kprime(kPrimeTomorrow, kPrime, ePrimeIdx);
        # cPrime = consumption(m.budget, t+1, kPrime, 
        #     kPrimePrime; efficiency = effPrime);
    for (j, cPrime) in enumerate(cPrimeV)
        # βR U'(c')
        betaRUprime = betar(m) * marg_utility(m.util, cPrime);
        rhs += prob_ePrimeV[j] * inv_marg_utility(m.util, betaRUprime);
    end

    eff = efficiency(m.endow, eIdx);
    cToday = consumption(m.budget, t, k, kPrime, eff);
    dev = cToday - rhs;
    return dev
end


function cprime_distribution(m :: Model, t :: Integer, eIdx :: Integer, 
    kPrime, kPrimeTomorrow :: WorkerSolution)

    if isretired(m, t+1)
        prob_ePrimeV = [1.0];
    else
        prob_ePrimeV = prob_eprime(m.endow, eIdx);
    end
    ePrimeV = 1 : length(prob_ePrimeV);
    cPrimeV = zeros(length(ePrimeV));
    for ePrimeIdx in ePrimeV
        effPrime = efficiency(m.endow, eIdx);
        kPrimePrime = kprime(kPrimeTomorrow, kPrime, ePrimeIdx);
        cPrimeV[ePrimeIdx] = consumption(m.budget, t+1, kPrime, 
            kPrimePrime, effPrime);
    end
    return cPrimeV, prob_ePrimeV
end


# E(u'(c'))
function e_uprime_c(m :: Model, t :: Integer, eIdx :: Integer, 
    kPrime, kPrimeTomorrow :: WorkerSolution)

    cPrimeV, prob_ePrimeV = cprime_distribution(m, t, eIdx, 
        kPrime, kPrimeTomorrow);
    # R U'(c')
    muV = [marg_utility(m.util, cPrime) for cPrime in cPrimeV];
    eMu = sum(muV .* prob_ePrimeV)
    return eMu
end


function interpolate_kprime(kGridV :: AbstractVector{F}, kPrimeV :: AbstractVector{F}) where F
    interp = LinearInterpolation(kGridV, kPrimeV);
    return interp
end

# update for eIdx +++++++++
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
            c = consumption(m.budget, t, k, kPrime, eff);
            bcValid = bcValid && isapprox(c, c_fct(k), atol = 1e-4);

            if kprime_min(m.kGrid, t) < kPrime < kprime_max(m.kGrid, t)
                # Interior point
                kpp_fct = kprime_fct(sol, t+1);
                kPrimePrime = kpp_fct(kPrime);
                cPrime = consumption(m.budget, t+1, kPrime, kPrimePrime, effPrime);
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