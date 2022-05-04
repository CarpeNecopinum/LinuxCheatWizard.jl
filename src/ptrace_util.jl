
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
