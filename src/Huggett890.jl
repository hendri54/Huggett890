module Huggett890

using DocStringExtensions, Infiltrator, Interpolations, Lazy, Roots
using UtilityFunctions890

export init_demographics, validate_demographics
export init_test_endowments, validate_endowments
export init_test_capital_grid, validate_capital_grid, make_k_grid
export init_test_budget, validate_budget, income, kprime, consumption
export Model, init_model, validate_model, solve_worker, euler_dev
export WorkerSolution, init_test_worker_solution
export Solution, init_solution, init_test_solution

# The objects
include("types.jl");
include("demographics.jl");
include("endowments.jl");
include("capital_grid.jl");
include("budget.jl");
include("model.jl");
include("solution.jl");
# Solving the model
# include("solve.jl");
include("solve_worker.jl");
include("helpers.jl");

"""
	$(SIGNATURES)

Runs everything in sequence
"""
function run_all()
    m = init_model();
    sol = solve_worker(m);
    save_solution(sol);
    sim = simulate_model(m, sol);
    show_results(m, sol, sim);
end

# stub +++
function save_solution(sol) end

# stub +++
function simulate_model(m, sol) end

# stub +++
function show_results(m, sol, sim) end

end # module
