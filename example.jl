cd(dirname(@__FILE__))
using Pkg
Pkg.activate(".")
Pkg.instantiate()

using Revise

includet("src/cheat_wizard.jl")
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

money_search = FuzzySearch(target, 989064589.0e0)
@show money_search.candidates

refine_offsets!(money_search, 896637768.0e0)
@show money_search.candidates

# In my test, the first 3 results were related to the animation of the money
# but the 4th one was the actual money itself
# so I grabbed that and became rich.
money = FoundValue(money_search, 4)
money[] = 2e0^62

# Drones can be cool to mess around with the ship's mass
drones_search = FuzzySearch(target, 9809.4e0)
@show drones_search.candidates

drones = FoundValue(drones_search, 2)
drones[] = 100000000


####

# Next-up: XCOM-Enemy Within

# again via steam

run(`steam`, wait=false)

target = TargetProcess("game.x86_64")

money_search = AlignedSearch{Int32}(target, ==(492830))
money = FoundValue(money_search)
money[] += 1

near_to_money = find_pointers_nearby(target, money.offset, 16)

meld_search = AlignedSearch{Int32}(target, ==(30))

fragments_search = AlignedSearch{Int32}(target, ==(11))
refine_offsets!(fragments_search, ==(9))
fragments = FoundValue(fragments_search)
fragments[] = 1000000

alloys_search = AlignedSearch{Int32}(target, ==(37))
refine_offsets!(alloys_search, ==(36))
alloys = FoundValue(alloys_search)
alloys[] = 1e6

elirium_search = AlignedSearch{Int32}(target, ==(9))
refine_offsets!(elirium_search, ==(7))
elirium = FoundValue(elirium_search)
elirium[] = 1e6

money_search = ValueSearch(target, Int32(245))
refine_offsets!(money_search, Int32(235))
money = FoundValue(money_search)
money[] = 500000

meld_search = AlignedSearch{Int32}(target, ==(50))
refine_offsets!(meld_search, ==(90))
meld = FoundValue(meld_search)
meld[] = 1e7


## Trying Space Rangers 2
target = TargetProcess("Rangers.exe")

money_search = ValueSearch(target, Int32(110))
refine_offsets!(money_search, 872)

money = FoundValue(money_search.inner)
money[] = 2^31 - 1
money[]

xp_search = ValueSearch(target, Int32(3388))
refine_offsets!(xp_search, 1788)
xp = FoundValue(xp_search.inner)
xp[] = 3388
