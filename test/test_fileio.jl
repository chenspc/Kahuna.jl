using Owen
using Test

@testset "owen_read"

    @testset ".dm3 files"

    end

    @testset ".dm4 files"

    end

    @testset ".hdf5/.h5 files"

    end

    @testset ".mat files"

        matfile = "test/test_fileio_mat.mat";

        @test typeof(owen_read(matfile, "mat0d")) == Float64
        @test typeof(owen_read(matfile, "mat1d")) == Array{Float64,2} && size(owen_read(matfile, "mat1d")) == (1,10)
        @test typeof(owen_read(matfile, "mat2d")) == Array{Float64,2} && size(owen_read(matfile, "mat2d")) == (10,10)
        @test typeof(owen_read(matfile, "mat3d")) == Array{Float64,3} && size(owen_read(matfile, "mat3d")) == (10,10,10)
        @test typeof(owen_read(matfile, "mat4d")) == Array{Float64,4} && size(owen_read(matfile, "mat4d")) == (10,10,10,10)

        @test owen_read(matfile; mode="list") == Set(["mat0d", "mat1d", "mat2d", "mat4d", "mat3d"])

        @test owen_read(matfile) == Dict(map(x -> x => owen_read(matfile, x), collect(owen_read(matfile; mode="list"))))

    end

    @testset ".mib files"

        mibfile256_1bit = "test/test_fileio_mib256_1bit.mib";
        mibfile256_6bit = "test/test_fileio_mib256_6bit.mib";
        mibfile256_12bit = "test/test_fileio_mib256_12bit.mib";
        mibfile256_1bit_raw64 = "test/test_fileio_mib256_1bit_raw64.mib";
        mibfile256_6bit_raw64 = "test/test_fileio_mib256_6bit_raw64.mib";
        mibfile256_12bit_raw64 = "test/test_fileio_mib256_12bit_raw64.mib";

        mibfile512_1bit = "test/test_fileio_mib512_1bit.mib";
        mibfile512_6bit = "test/test_fileio_mib512_6bit.mib";
        mibfile512_12bit = "test/test_fileio_mib512_12bit.mib";
        mibfile512_1bit_raw64 = "test/test_fileio_mib512_1bit_raw64.mib";
        mibfile512_6bit_raw64 = "test/test_fileio_mib512_6bit_raw64.mib";
        mibfile512_12bit_raw64 = "test/test_fileio_mib512_12bit_raw64.mib";

        mibfiles = [mibfile256_1bit, mibfile256_6bit, mibfile256_12bit,
                    mibfile256_1bit_raw64, mibfile256_6bit_raw64, mibfile256_12bit_raw64,
                    mibfile512_1bit, mibfile512_6bit, mibfile512_12bit,
                    mibfile512_1bit_raw64, mibfile512_6bit_raw64, mibfile512_12bit_raw64];

        for mibfile in mibfile256_6bit
            @test typeof(owen_read(mibfile)) == Array{Float64,2}
            @test typeof(owen_read(mibfile, [1, 10])) == Array{Float64,2} && size(owen_read(mibfile, [1, 10])) == (1,10)
            @test typeof(owen_read(mibfile, [1, 10])) == Array{Float64,2} && size(owen_read(mibfile, [1, 10])) == (10,10)
            @test typeof(owen_read(mibfile, [1, 10])) == Array{Float64,2} && size(owen_read(mibfile, [1, 10])) == (10,10)
        end

    end

    @testset ".toml files"

    end

    @testset ".jld files"

    end


end

@testset "owen_write"

    @testset ".hdf5/.h5 files"

    end

    @testset ".toml files"

    end

    @testset ".jld files"

    end

end
