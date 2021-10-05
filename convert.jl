using Gumbo
using Cascadia
using Dates
using LinearAlgebra
using PyCall
using Conda
using CSV
using DataFrames

# PARAMS
XTHRESHOLD = 90
YTHRESHOLD = 7  #! all expect one have 4 but one has 5
YEAR = 2022

d = parsehtml(read("calendar.html", String))
p = eachmatch(Selector("p"),d.root)
events = filter(
  p -> any(occursin.(
    #! some have 3.9564484pt  instead of 3.9966pt => use 3.9XXXXX
    #! some have 2.9XXX
    [
      "font-family:HelveticaNeueLTCom,serif;font-size:3.9",
      "font-family:HelveticaNeueLTCom,serif;font-size:2.9"
    ],
    p.children[1].attributes["style"]
  ))
, p)
# events = filter(e->size(e.children)[1]==1, events)
events_withstyleprops = map(
  e->(
    e,
    merge(map(
      prop -> Dict([split(prop,":")]), split(e.attributes["style"], ";")
    )...)
  ), events
)
events_withxycoords = map(
  e->(
    nodeText(e[1]),
    parse(Int, chop(e[2]["left"], tail=2)),
    parse(Int, chop(e[2]["top"], tail=2))
  ), events_withstyleprops
)


events_without_colors = filter!(
  e->e[3] > XTHRESHOLD, events_withxycoords
)

events_sorted = sort(
  sort(events_without_colors, lt=(x,y)->x[2]<y[2])
  , lt=(x,y)->x[2]==y[2] && x[3]<y[3]
)

events_merged = []
events_sorted_copy = copy(events_sorted)
while (size(events_sorted_copy)[1] > 0)
  coll = [popfirst!(events_sorted_copy)]
  while (
    !isempty(events_sorted_copy)
    && abs(coll[end][3] - events_sorted_copy[1][3]) < YTHRESHOLD
  )
    push!(coll, popfirst!(events_sorted_copy))
  end
  print(coll)
  push!(events_merged, coll)
end
events_merged_reduced = map(ecoll->reduce((x,y)->(join([x[1],y[1]], " "), (x[2]+y[2])/2, (x[3]+y[3])/2), ecoll), events_merged)
events_locationvectors = map(
  e -> (e[1], [e[2], e[3]])
  , events_merged_reduced
)


days = filter(
  p -> occursin(
    "font-family:HelveticaNeueLTCom,serif;font-size:9.492pt",
    p.children[1].attributes["style"]
  )
, p)
days_withstyleprops = map(
  e->(
    e,
    merge(map(
      prop -> Dict([split(prop,":")]), split(e.attributes["style"], ";")
    )...)
  ), days
)
days_withxycoords = map(
  e->(
    nodeText(e[1]),
    parse(Int, chop(e[2]["left"], tail=2)),
    parse(Int, chop(e[2]["top"], tail=2))
  ), days_withstyleprops
)
numericdays_withxycoords = map(
  d->(parse(Int, d[1]), d[2], d[3])
  , days_withxycoords
)

months = filter(
  p -> occursin(
    "font-family:HelveticaNeueLTCom,serif;font-size:8.7427pt",
    p.children[1].attributes["style"]
  )
, p)
months_withstyleprops = map(
  e->(
    e,
    merge(map(
      prop -> Dict([split(prop,":")]), split(e.attributes["style"], ";")
    )...)
  ), months
)
months_withxycoords = map(
  e->(
    nodeText(e[1]),
    parse(Int, chop(e[2]["left"], tail=2)),
    parse(Int, chop(e[2]["top"], tail=2))
  ), months_withstyleprops
)
months_sorted = sort(months_withxycoords, lt=(x,y)->x[2]<y[2])
numericmonths_withxycoords = map(
  m -> (m[1], m[2][2], m[2][3])
  , enumerate(months_sorted)
)

dates_withxycoords = map(
  d->(
    Date(
      YEAR,
      findmin(abs.(d[2] .- map(m->m[2],numericmonths_withxycoords)))[2],
      d[1]
    ),
    d[2], d[3]
  ),
  numericdays_withxycoords
)
dates_locationvectors = map(
  e -> (e[1], [e[2], e[3]])
  , dates_withxycoords
)


# Geometrically match events to dates in Euclidian norm ||⋅||₂
calendar_events = sort(map(
  e->(
    dates_locationvectors[
      findmin(norm.([e[2]] .- map(d->d[2], dates_locationvectors)))[2]
    ][1],
    e[1]
  )
  , events_locationvectors
))

df = DataFrame(
  date = map(e->string(e[1]), calendar_events),
  event = map(e->string(e[2]), calendar_events)
)

CSV.write("events.csv", df, quotestrings=true, writeheader=false)
