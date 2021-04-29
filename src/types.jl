mutable struct Demographics
    lifeSpan :: Int
    lastWorkAge :: Int
    totalMass :: Float64
end

mutable struct Endowments
    ageEfficiencyV :: Vector{Float64}
    effGridV :: Vector{Float64}
    # Probability of each grid point at birth
    effProbV :: Vector{Float64}
    # Transition matrix: prob(j' | j)
    trMatrix :: Matrix{Float64}
end

mutable struct CapitalGrid
    kMin :: Float64
    kMax :: Float64
    nk :: Int
end

mutable struct Budget
    wage :: Float64
    intRate :: Float64
    taxRate :: Float64
    retireTransfer :: Float64
    cMin :: Float64
end

mutable struct Model
    demog :: Demographics
    endow :: Endowments
    kGrid :: CapitalGrid
    budget :: Budget
    util :: AbstractUtility
    # Raw parameters
    discFactor :: Float64
end

# Solution for one period
# Stores policy functions
# kPrime as a function of [k, efficiency].
mutable struct PeriodSolution
    kPrimeFct
end

mutable struct Solution
    solV :: Vector{PeriodSolution}
end


# -------------