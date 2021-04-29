# Demographics

function init_test_demographics()
    d = Demographics(60, 45, 1.0);
    @assert validate_demographics(d);
    return d
end

function validate_demographics(d :: Demographics)
    isValid = (d.lifeSpan > d.lastWorkAge);
    return isValid
end

## ---------  Helpers

lifespan(d :: Demographics) = d.lifeSpan;
workspan(d :: Demographics) = d.lastWorkAge;
isretired(d :: Demographics, t :: Integer) = (t > workspan(d));

# ------------