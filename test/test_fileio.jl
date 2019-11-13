using Kahuna
using Test

@testset "kahuna_read" begin

    @testset ".dm3 files" begin
        @test 2 + 2 == 4
    end

    @testset ".dm4 files" begin
        @test 2 + 2 == 4
    end

    @testset ".hdf5/.h5 files" begin
        @test 2 + 2 == 4
    end

    @testset ".mat files" begin
        # matfile = "test/sample_files/test_fileio_mat.mat";
        matfile = "sample_files/test_fileio_mat.mat";
        @test typeof(kahuna_read(matfile, "mat0d")) == Float64
        @test typeof(kahuna_read(matfile, "mat1d")) == Array{Float64,2} && size(kahuna_read(matfile, "mat1d")) == (1,10)
        @test typeof(kahuna_read(matfile, "mat2d")) == Array{Float64,2} && size(kahuna_read(matfile, "mat2d")) == (10,10)
        @test typeof(kahuna_read(matfile, "mat3d")) == Array{Float64,3} && size(kahuna_read(matfile, "mat3d")) == (10,10,10)
        @test typeof(kahuna_read(matfile, "mat4d")) == Array{Float64,4} && size(kahuna_read(matfile, "mat4d")) == (10,10,10,10)

        @test kahuna_read(matfile; mode="list") == Set(["mat0d", "mat1d", "mat2d", "mat4d", "mat3d"])

        @test kahuna_read(matfile) == Dict(map(x -> x => kahuna_read(matfile, x), collect(kahuna_read(matfile; mode="list"))))
    end

    @testset ".mib files" begin

        mibfile512_12bit = "sample_files/test_512_12bit_single.mib";

        # mibfiles = [mibfile256_1bit, mibfile256_6bit, mibfile256_12bit,
        #             mibfile256_1bit_raw, mibfile256_6bit_raw, mibfile256_12bit_raw,
        #             mibfile512_1bit, mibfile512_6bit, mibfile512_12bit,
        #             mibfile512_1bit_raw, mibfile512_6bit_raw, mibfile512_12bit_raw];
        mibfiles = [mibfile512_12bit]

        for mibfile in mibfiles
            mib_images, mib_headers = kahuna_read(mibfile)
            @test typeof(mib_images) == Array{Array{UInt16,2},1}
            @test typeof(mib_headers) == Array{MIBHeader,1}
            # @test typeof(kahuna_read(mibfile, [1, 10])) == Array{Float64,2} && size(kahuna_read(mibfile, [1, 10])) == (1,10)
            # @test typeof(kahuna_read(mibfile, [1, 10])) == Array{Float64,2} && size(kahuna_read(mibfile, [1, 10])) == (10,10)
            # @test typeof(kahuna_read(mibfile, [1, 10])) == Array{Float64,2} && size(kahuna_read(mibfile, [1, 10])) == (10,10)
        end

    end

    @testset ".toml files" begin
        @test 2 + 2 == 4
    end

    @testset ".jld files" begin
        @test 2 + 2 == 4
    end


end

@testset "kahuna_write" begin

    @testset ".hdf5/.h5 files" begin
        @test 2 + 2 == 4
    end

    @testset ".toml files" begin
        @test 2 + 2 == 4
    end

    @testset ".jld files" begin
        @test 2 + 2 == 4
    end

end
