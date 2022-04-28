cd(dirname(@__FILE__))
using Pkg
Pkg.activate(".")
Pkg.instantiate()

using Revise

include("src/cheat_wizard.jl")
using .CheatWizard


# Easiest way to get debuggin permission for a process: be its parent
run(`test_target/target`, wait=false)

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
gold[] = 9002


####

# let's start messing with an actual Game now
# I chose "ΔV Rings of Saturn" (highly recommend this game)

# I bought the game on steam, and being the parent process of steam is enough
# to let us mess with any game started from there.

run(`steam`, wait=false)

target = TargetProcess("Delta-V.x86_64")

# This game is a bit trickier to mess with than the test_target example...
# The money is stored as a double precision float, we won't find the exact
# value we see in the GUI in memory, so I added a `FuzzySearch` that looks
# for a small interval of values at once.

money_search = FuzzySearch(target, 20000.0e0)
@show money_search.candidates

refine_offsets!(money_search, 16500.0e0)
@show money_search.candidates

# In my test, the first 3 results were related to the animation of the money
# but the 4th one was the actual money itself
# so I grabbed that and became rich.
money = FoundValue(money_search, 4)
money[] = 1000000000
