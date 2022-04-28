cd(dirname(@__FILE__))

using Pkg
Pkg.activate(".")


include("src/target_process.jl")
include("src/value_search.jl")
include("src/found_value.jl")


# Easiest way to get debuggin permission for a process: be its parent
run(`xterm -e test_target/target`, wait=false)

target = TargetProcess("target")

# Enter 2000 in the xterm now to set the "gold" value to that
# then we start looking for the value
search = ValueSearch(target, Int32(2000))
@show search.candidates


# we probably have multiple candidates left, so change the "gold" and search again
refine_offsets!(search, Int32(3000))
@show search.candidates


# At the time of writing, I still had 2 results here, 
# but I'm taking a leap of faith and just using the first one
gold = FoundValue(search, 1)

# we can now read the current value like this
@show gold[]

# or "cheat" ourselves more gold like this
# note how you don't even need to write the exact type, the assignment converts it automatically
gold[] = 9001