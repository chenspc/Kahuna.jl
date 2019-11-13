using Kahuna
using Test
using SafeTestsets
using Libdl

push!(Libdl.DL_LOAD_PATH, "/usr/lib")

@safetestset "File I/O" begin include("test_fileio.jl") end
