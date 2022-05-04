mutable struct FuzzySearch{T} <: Search{T}
    inner::AlignedSearch{T}
    tolerance::T

    function FuzzySearch(target::TargetProcess, value::T, tolerance::T=one(T)) where {T}
        new{T}(AlignedSearch{T}(target, x -> isapprox(value, atol=tolerance)), tolerance)
    end
end

function refine_offsets!(search::FuzzySearch{T}, value::T) where {T}
    refine_offsets!(search.inner, x -> isapprox(value, atol=search.tolerance))
    search
end

process(search::FuzzySearch{T}) where {T} = process(search.inner)
candidates(search::FuzzySearch{T}) where {T} = candidates(search.inner)