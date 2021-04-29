function init_test_capital_grid()
    kGrid = CapitalGrid(-2.0, 9.5, 30);
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
make_k_grid(kGrid :: CapitalGrid, t) = LinRange(k_min(kGrid, t), k_max(kGrid, t), kGrid.nk);


# ------------