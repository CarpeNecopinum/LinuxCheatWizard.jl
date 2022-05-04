
module CheatWizard

abstract type Search{T} end

include("./target_process.jl")
include("./ptrace_util.jl")
include("./aligned_search.jl")
include("./value_search.jl")
include("./fuzzy_search.jl")
include("./found_value.jl")

export TargetProcess
export ValueSearch
export FuzzySearch
export AlignedSearch
export refine_offsets!
export FoundValue

function Base.show(io::IO, ::MIME"text/plain", search::Search{T}) where {T}
    println(io, "$(length(candidates(search))) candidates left")
end

end