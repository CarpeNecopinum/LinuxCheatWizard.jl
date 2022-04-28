mutable struct FuzzySearch{T} <: Search{T}
    process::TargetProcess
    candidates::Vector{UInt}
    tolerance::T

    function FuzzySearch(target::TargetProcess, value::T, tolerance::T=one(T)) where {T}
        find_initial_offsets!(new{T}(target, [], tolerance), value)
    end
end

function find_initial_offsets!(search::FuzzySearch{T}, value::T) where {T}
    update_rw_maps!(search.process)
    pid = search.process.pid
    ptrace_attach(pid)
    open("/proc/$pid/mem") do mem
        for m in search.process.rw_maps
            seek(mem, m[1])
            all_data = zeros(typeof(value), (m[2] - m[1]) ÷ sizeof(value))
            read!(mem, all_data)

            indices = findall(x -> isapprox(x, value, atol=search.tolerance), all_data) .|> x -> ((x - 1) * sizeof(value) + m[1])
            append!(search.candidates, indices)
        end
    end
    ptrace_detach(pid)
    search
end

function refine_offsets!(search::FuzzySearch{T}, value::T) where {T}
    ptrace_attach(search.process.pid)
    open("/proc/$(search.process.pid)/mem") do mem
        filter!(search.candidates) do off
            seek(mem, off)
            here = read(mem, typeof(value))
            isapprox(here, value, atol=search.tolerance)
        end
    end
    ptrace_detach(search.process.pid)
    search
end