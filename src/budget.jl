function init_test_budget(lastWorkAge)
    ageEfficiencyV = collect(LinRange(1.0, 3.0, lastWorkAge));
    ageEfficiencyV[20 : lastWorkAge] .= 2.0;
    wage = 2.0;
    intRate = 1.05;
    taxRate = 0.4;
    retireTransfer = 3.9;
    cMin = 1e-3;
    b = Budget(ageEfficiencyV, wage, intRate, taxRate, retireTransfer, cMin);
    @assert validate_budget(b);
    return b
end

function validate_budget(b :: Budget)
    isValid = validate_age_efficiencies(b.ageEfficiencyV)  &&  
        (wage(b) > 0.0)  &&  (b.intRate > 0.8)  &&  (b.intRate < 1.2)  &&
        (b.taxRate >= 0.0)  &&  (b.taxRate < 0.9);
    return isValid
end

function validate_age_efficiencies(ageEfficiencyV :: Vector{Float64})
    isValid = all(ageEfficiencyV .> 0.0);
    return isValid
end


## -------  Helpers

c_min(b :: Budget) = b.cMin;
# betar(b :: Budget) = b.discFactor * b.intRate;
wage(b :: Budget) = b.wage;
workspan(b) = length(b.ageEfficiencyV);
isretired(b :: Budget, t :: Integer) = t > workspan(b);

## ---------  Work phase

function earnings(b :: Budget, t :: Integer, efficiency)
    if isretired(b, t)
        earn = 0.0;
    else
        earn = wage(b) .* (1.0 - b.taxRate) .* efficiency .* b.ageEfficiencyV[t];
    end
    return earn
end

function retire_transfer(b :: Budget, t :: Integer)
    if isretired(b, t)
        transfer = b.retireTransfer;
    else
        transfer = 0.0;
    end
    return transfer
end

capital_income(b :: Budget, k) = b.intRate .* k;

income(b :: Budget, t :: Integer, k, efficiency) = 
    earnings(b, t, efficiency) .+
    retire_transfer(b, t) .+ 
    capital_income(b, k);

kprime(b :: Budget, t :: Integer, k, c, efficiency) = 
    income(b, t, k, efficiency) .- c;

consumption(b :: Budget, t :: Integer, k, kPrime, efficiency) = 
    income(b, t, k, efficiency) .- kPrime;

# Max kPrime consistent with c > c_min
kprime_max(b :: Budget, t :: Integer, k, efficiency) = 
    kprime(b, t, k, c_min(b), efficiency);

# ## ----------  Retirement
# # No efficiency state

# retired_income(b :: Budget, k) = b.retireTransfer .+ b.intRate .* k;
# retired_kprime(b :: Budget, k, c) = retired_income(b, k) .- c;
# retired_consumption(b :: Budget, k, kPrime) = retired_income(b, k) .- kPrime;

# ---------------