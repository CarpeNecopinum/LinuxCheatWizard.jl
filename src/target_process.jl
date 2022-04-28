
function pidof(exe_name::String)
    parse(Int, read(`pidof $exe_name`, String))
end

struct TargetProcess
    pid::UInt
    rw_maps::Vector{Tuple{UInt,UInt}}

    TargetProcess(pid::UInt) = new(pid, [])
    TargetProcess(exe_name::String) = new(pidof(exe_name), [])
end

function update_rw_maps!(process::TargetProcess)
    empty!(process.rw_maps)
    lines = readlines("/proc/$(process.pid)/maps")
    for line in lines
        (addr_range, perms) = split(line, " ")
        (perms[2] == 'w') || continue

        pair = split(addr_range, "-") |> Tuple |> x -> parse.(UInt, x, base=16)
        push!(process.rw_maps, pair)
    end
    process
end