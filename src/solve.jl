function solve_model(m :: Model)
    sol = Solution(lifespan(m));
    for t = lifespan(m) : -1 : 1
        solve_one_period!(m, sol, t);
    end
    return sol
end

# -----------------