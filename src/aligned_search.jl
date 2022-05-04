struct AlignedSearch{T} <: Search{T}
    process::TargetProcess
    candidates::Vector{UInt}
end

function AlignedSearch{T}(target::TargetProcess, matcher::Function) where {T}
    search = AlignedSearch{T}(target, UInt[])

    update_rw_maps!(search.process)
    pid = search.process.pid
    ptrace_attach(pid)
    open("/proc/$pid/mem") do mem
        for m in search.process.rw_maps
            seek(mem, m[1])
            all_data = zeros(T, (m[2] - m[1]) ÷ sizeof(T))
            read!(mem, all_data)

            indices = findall(matcher, all_data) .|> x -> ((x - 1) * sizeof(T) + m[1])
            append!(search.candidates, indices)
        end
    end
    ptrace_detach(pid)

    search
end

function refine_offsets!(search::AlignedSearch{T}, matcher::Function) where {T}
    ptrace_attach(search.process.pid)
    open("/proc/$(search.process.pid)/mem") do mem
        filter!(search.candidates) do off
            seek(mem, off)
            read(mem, T) |> matcher
        end
    end
    ptrace_detach(search.process.pid)
    search
end

process(search::AlignedSearch{T}) where {T} = search.process
candidates(search::AlignedSearch{T}) where {T} = search.candidates