mutable struct ValueSearch{T} <: Search{T}
    inner::AlignedSearch{T}

    function ValueSearch(target::TargetProcess, value::T) where {T}
        new{T}(AlignedSearch{T}(target, ==(value)))
    end
end

function refine_offsets!(search::ValueSearch{T}, value) where {T}
    refine_offsets!(search.inner, ==(value))
    search
end

process(search::ValueSearch{T}) where {T} = process(search.inner)
candidates(search::ValueSearch{T}) where {T} = candidates(search.inner)