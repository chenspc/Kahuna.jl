module Kahuna

using FileIO
using MAT
using HDF5
using JLD2
using Images
using Plots
using Dates

export AbstractMIB, AbstractMIBHeader, AbstractMIBImage, MIBHeader

abstract type AbstractMIB end
abstract type AbstractMIBHeader end
abstract type AbstractMIBImage end

struct MIBHeader <: AbstractMIBHeader

    id::Int
    offset::Int
    nchip::Int
    dims::Vector{Int}
    data_type::DataType
    chip_dims::Vector{Int}
    time::DateTime
    exposure_s::Float64
    image_bit_depth::Int
    raw::Bool

    MIBHeader(id,
              offset,
              nchip,
              dims,
              data_type,
              chip_dims,
              time,
              exposure_s,
              image_bit_depth,
              raw) = new(id,
                         offset,
                         nchip,
                         dims,
                         data_type,
                         chip_dims,
                         time,
                         exposure_s,
                         image_bit_depth,
                         raw)

end


include("fileio.jl")

end # module
