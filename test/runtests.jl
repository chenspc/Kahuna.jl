using Owen
using Test
using Libdl

push!(Libdl.DL_LOAD_PATH, "/usr/lib") 

include("test_fileio.jl")
@testset "Owen.jl" begin
    # Write your own tests here.
end
