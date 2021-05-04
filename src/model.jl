# Model

function init_model()
    demog = init_demographics();
    endow = init_test_endowments(demog.lastWorkAge);
    kGrid = init_test_capital_grid();
    budget = init_test_budget(demog.lastWorkAge);
    util = UtilityCRRA(2.0);
    discFactor = 0.97;
    m = Model(demog, endow, kGrid, budget, util, discFactor);
    @assert validate_model(m);
    return m
end

function validate_model(m :: Model)
    isValid = validate_demographics(m.demog) &&
        validate_endowments(m.endow) &&
        validate_capital_grid(m.kGrid) &&
        validate_budget(m.budget);
    return isValid
end


## ----------  Helpers

n_efficiencies(m :: Model, t :: Integer) = 
    isretired(m, t)  ?  1  :  n_efficiencies(m.endow);
betar(m :: Model) = m.discFactor * m.budget.intRate;
euler_dev(m :: Model, ctV) = UtilityFunctions890.euler_dev(m.util, ctV, betar(m));

function kprime_range(m :: Model, t :: Integer, k, eff)
    kPrimeMin = kprime_min(m.kGrid, t);
    kPrimeMax = min(kprime_max(m.budget, t, k, eff), kprime_max(m.kGrid, t));
    return kPrimeMin, kPrimeMax
end


# A little trick -- the same as writing
# `lifespan(m :: Model) = lifespan(m.demog)` etc.
Lazy.@forward Model.demog (
    lifespan, workspan, isretired
);

Lazy.@forward Model.kGrid (
    make_k_grid, k_min, k_max, kgrid_min, kgrid_max
);

Lazy.@forward Model.budget (
    consumption, wage
);


# -------------