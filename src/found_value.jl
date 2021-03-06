struct FoundValue{T}
    process::TargetProcess
    offset::UInt

    FoundValue(search::Search{T}, index::Int=1) where {T} =
        new{T}(search.process, candidates(search)[index])

    FoundValue{T}(process::TargetProcess, offset) where {T} =
        new{T}(process, offset)
end

function Base.setindex!(handle::FoundValue{T}, value::Any) where {T}
    open("/proc/$(handle.process.pid)/mem", "r+") do mem
        seek(mem, handle.offset)
        write(mem, convert(T, value))
    end
    value
end

function Base.getindex(handle::FoundValue{T}) where {T}
    open("/proc/$(handle.process.pid)/mem", "r") do mem
        seek(mem, handle.offset)
        read(mem, T)
    end
end