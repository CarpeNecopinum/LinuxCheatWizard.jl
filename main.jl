cd(dirname(@__FILE__))

using Pkg
Pkg.activate(".")

using Mmap

function pidof(exe_name::String)
    read(`pidof $exe_name`) |> String |> x -> parse(Int, x)
end

function read_rw_maps(pid::Int)
    lines = readlines("/proc/$pid/maps")
    result = Vector{Tuple{UInt,UInt}}()
    for line in lines
        (addr_range, perms) = split(line, " ")
        (perms[2] == 'w') || continue

        pair = split(addr_range, "-") |> Tuple |> x -> parse.(UInt, x, base=16)
        push!(result, pair)
    end
    result
end

function ptrace_attach(pid)
    nullptr = Ptr{Cvoid}()
    res = ccall(:ptrace, Clong, (Clong, Clong, Ptr{Cvoid}, Ptr{Cvoid}), 16, target_pid, nullptr, nullptr)
    if res < 0
        err = Base.Libc.strerror()
        @show err
    end
end

function ptrace_detach(pid)
    nullptr = Ptr{Cvoid}()
    res = ccall(:ptrace, Clong, (Clong, Clong, Ptr{Cvoid}, Ptr{Cvoid}), 17, target_pid, nullptr, nullptr)
    if res < 0
        err = Base.Libc.strerror()
        @show err
    end
end

run(`xterm -e ./victim`, wait=false)

target_pid = pidof("victim")
maps = read_rw_maps(target_pid)

ptrace_attach(target_pid)
ptrace_detach(target_pid)

target_mem = open("/proc/$target_pid/mem", "r+")

function find_offsets(mem::IOStream, maps::Vector{Tuple{UInt,UInt}}, value::Any)
    results = UInt[]
    for m in maps
        seek(mem, m[1])
        all_data = zeros(typeof(value), (m[2] - m[1]) ÷ sizeof(value))
        read!(mem, all_data)

        indices = findall(x -> x == value, all_data) .|> x -> ((x - 1) * sizeof(value) + m[1])
        append!(results, indices)
    end
    results
end

function read_from_offset(mem::IOStream, offset::UInt64, type)
    seek(mem, offset)
    read(mem, type)
end

function refine_offsets!(mem::IOStream, offsets::Vector{UInt64}, value::Any)
    filter!(offsets) do off
        read_from_offset(mem, off, typeof(value)) == value
    end
end

function write_to_offset(mem::IOStream, offset::UInt64, value::Any)
    seek(mem, offset)
    write(mem, value)
end


offs = find_offsets(target_mem, maps, Int32(3000))
refine_offsets!(target_mem, offs, Int32(4000))

