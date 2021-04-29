using Huggett890
using Test

@testset "Huggett890.jl" begin
    include("demographics_test.jl");
    include("endowments_test.jl");
    include("capital_grid_test.jl");
    include("budget_test.jl");
    include("model_test.jl");
end
