function init_test_capital_grid()
    kGrid = CapitalGrid(-2.0, 50.0, 300);
    @assert validate_capital_grid(kGrid);
    return kGrid
end

function validate_capital_grid(kGrid :: CapitalGrid)
    isValid = (kGrid.kMax > kGrid.kMin);
    return isValid
end

function validate_capital_grid(kGridV :: AbstractVector{T}) where T
    isValid = all(diff(kGridV) .> 0.0);
    return isValid
end

k_min(kGrid :: CapitalGrid, t) = kGrid.kMin;
k_max(kGrid :: CapitalGrid, t) = kGrid.kMax;
kprime_min(kGrid :: CapitalGrid, t) = k_min(kGrid, t+1);
kprime_max(kGrid :: CapitalGrid, t) = k_max(kGrid, t+1);
make_k_grid(kGrid :: CapitalGrid, t) = LinRange(k_min(kGrid, t), k_max(kGrid, t), kGrid.nk);


# ------------