function init_test_budget()
    wage = 2.0;
    intRate = 1.05;
    taxRate = 0.4;
    retireTransfer = 0.9;
    cMin = 1e-3;
    b = Budget(wage, intRate, taxRate, retireTransfer, cMin);
    @assert validate_budget(b);
    return b
end

function validate_budget(b :: Budget)
    isValid = (wage(b) > 0.0)  &&  (b.intRate > 0.8)  &&  (b.intRate < 1.2)  &&
        (b.taxRate >= 0.0)  &&  (b.taxRate < 0.9);
    return isValid
end


## -------  Helpers

c_min(b :: Budget) = b.cMin;
betar(b :: Budget) = b.discFactor * b.intRate;
wage(b :: Budget) = b.wage;

income(b :: Budget, k, efficiency) = 
    wage(b) .* (1.0 - b.taxRate) .* efficiency .+ b.intRate .* k;

kprime(b :: Budget, k, c, efficiency) = income(b, k, efficiency) .- c;

consumption(b :: Budget, k, kPrime, efficiency) = income(b, k, efficiency) .- kPrime;



# ---------------