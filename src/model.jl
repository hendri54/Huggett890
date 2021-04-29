# Model

function init_test_model()
    demog = init_test_demographics();
    endow = init_test_endowments(demog.lastWorkAge);
    kGrid = init_test_capital_grid();
    budget = init_test_budget();
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

euler_dev(m :: Model, ctV) = UtilityFunctions890.euler_dev(m.u, ctV, betar(m));

Lazy.@forward Model demog (
    lifespan
);

# make_k_grid(m :: Model, t) = LinRange(0.0, m.kMax, m.nk);
# kprime_max(m :: Model, t) = m.kMax;
# # Max kPrime consistent with c > c_min
# kprime_max(m :: Model, t, k) = budget_kprime(wage(m, t), m.R, k, c_min(m));
# kprime_min(m :: Model, t) = 0.0;



# -------------