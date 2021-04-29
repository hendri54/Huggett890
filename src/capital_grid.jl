function init_test_capital_grid()
    kGrid = CapitalGrid(-2.0, 9.5, 30);
    @assert validate_capital_grid(kGrid);
    return kGrid
end

function validate_capital_grid(kGrid :: CapitalGrid)
    isValid = (kGrid.kMax > kGrid.kMin);
    return isValid
end

# ------------