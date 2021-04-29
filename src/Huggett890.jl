module Huggett890

using DocStringExtensions, Lazy, Roots
using UtilityFunctions890

export init_test_demographics, validate_demographics
export init_test_endowments, validate_endowments
export init_test_capital_grid, validate_capital_grid, make_k_grid
export init_test_budget, validate_budget, income, kprime, consumption,
    retired_income, retired_consumption, retired_kprime
export Model, init_test_model, validate_model
export RetiredSolution, init_test_retired_solution
export WorkerSolution, init_test_worker_solution
export Solution, init_solution, init_test_solution

include("types.jl");
include("demographics.jl");
include("endowments.jl");
include("capital_grid.jl");
include("budget.jl");
include("model.jl");
include("solution.jl");
include("helpers.jl");

"""
	$(SIGNATURES)

Runs everything in sequence
"""
function run_all()
    m = init_test_model();
    sol = solve_model(m);
    sim = simulate_model(m, sol);
end


end
