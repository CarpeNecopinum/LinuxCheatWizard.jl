
module CheatWizard

abstract type Search{T} end

include("./target_process.jl")
include("./value_search.jl")
include("./fuzzy_search.jl")
include("./found_value.jl")

export TargetProcess
export ValueSearch
export FuzzySearch
export refine_offsets!
export FoundValue
end