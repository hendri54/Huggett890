# Endowments

function init_test_endowments(lastWorkAge :: Int)
    n = 3;
    effGridV = collect(LinRange(1.0, 3.0, n));
    effProbV = collect(LinRange(1.0, 0.5, n));
    effProbV ./= sum(effProbV);

    trMatrix = zeros(n, n);
    for j = 1 : n
        prV = collect(LinRange(0.5 + j, 0.5, n));
        trMatrix[:, j] .= prV ./ sum(prV);
    end

    endow = Endowments(effGridV, effProbV, trMatrix);
    return endow
end

function validate_endowments(e :: Endowments)
    isValid = validate_efficiency_grid(e.effGridV)  &&
        validate_transition_matrix(e.trMatrix);
    return isValid
end

function validate_efficiency_grid(gridV :: Vector{Float64})
    isValid = all(gridV .> 0.0)  &&  all(diff(gridV) .> 0.0);
    return isValid
end

function validate_transition_matrix(trMatrix :: Matrix{Float64})
    isValid = all(trMatrix .>= 0.0)  &&  all(trMatrix .<= 1.0);
    n, m = size(trMatrix);
    isValid = isValid  &&  (n == m);
    for j = 1 : n
        isValid = isValid  &&  isapprox(sum(trMatrix[:, j]), 1.0);
    end
    return isValid
end


## -----------  Access

n_efficiencies(e :: Endowments) = length(e.effGridV);

# Probability of e' | e
prob_eprime(e :: Endowments, eIdx) = e.trMatrix[:, eIdx];

efficiency(e :: Endowments, eIdx) = e.effGridV[eIdx];

# -----------------