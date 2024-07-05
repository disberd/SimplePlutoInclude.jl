module SimplePlutoInclude

using Dates: Dates, unix2datetime

export @plutoinclude

include("implementation.jl")
include("macro.jl")

end # module SimplePlutoInclude
