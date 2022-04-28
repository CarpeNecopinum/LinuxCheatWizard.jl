mutable struct ValueSearch{T} <: Search{T}
    process::TargetProcess
    candidates::Vector{UInt}

    function ValueSearch(target::TargetProcess, value::T) where {T}
        find_initial_offsets!(new{T}(target, []), value)
    end
end


function ptrace_attach(pid)
    nullptr = Ptr{Cvoid}()
    res = ccall(:ptrace, Clong, (Clong, Clong, Ptr{Cvoid}, Ptr{Cvoid}), 16, pid, nullptr, nullptr)
    if res < 0
        err = Base.Libc.strerror()
        @show err
    end
end

function ptrace_detach(pid)
    nullptr = Ptr{Cvoid}()
    res = ccall(:ptrace, Clong, (Clong, Clong, Ptr{Cvoid}, Ptr{Cvoid}), 17, pid, nullptr, nullptr)
    if res < 0
        err = Base.Libc.strerror()
        @show err
    end
end

function find_initial_offsets!(search::ValueSearch{T}, value::T) where {T}
    update_rw_maps!(search.process)
    pid = search.process.pid
    ptrace_attach(pid)
    open("/proc/$pid/mem") do mem
        for m in search.process.rw_maps
            seek(mem, m[1])
            all_data = zeros(typeof(value), (m[2] - m[1]) ÷ sizeof(value))
            read!(mem, all_data)

            indices = findall(x -> x == value, all_data) .|> x -> ((x - 1) * sizeof(value) + m[1])
            append!(search.candidates, indices)
        end
    end
    ptrace_detach(pid)
    search
end

function refine_offsets!(search::ValueSearch{T}, value::T) where {T}
    ptrace_attach(search.process.pid)
    open("/proc/$(search.process.pid)/mem") do mem
        filter!(search.candidates) do off
            seek(mem, off)
            read(mem, typeof(value)) == value
        end
    end
    ptrace_detach(search.process.pid)
    search
end