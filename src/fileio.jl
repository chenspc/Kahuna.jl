export owen_read, owen_write, load_dm3, load_dm4, load_hdf5, load_mat, load_mib, load_toml, load_jld2
export save_hdf5, save_toml, save_jld2
export firstheader

function owen_read(filepath::AbstractString, args...; kwargs...)
    file_extension = splitext(filepath)[2]
    if file_extension == ".dm3"
        output = load_dm3(filepath, args...; kwargs...)
    elseif file_extension == ".dm4"
        output = load_dm4(filepath, args...; kwargs...)
    elseif file_extension == ".hdf5" || file_extension == ".h5"
        output = load_hdf5(filepath, args...; kwargs...)
    elseif file_extension == ".mat"
        output = load_mat(filepath, args...; kwargs...)
    elseif file_extension == ".mib"
        output = load_mib(filepath, args...; kwargs...)
    elseif file_extension == ".toml"
        output = load_toml(filepath, args...; kwargs...)
    elseif file_extension == ".jld2"
        output = load_jld2(filepath, args...; kwargs...)
    else
        output = FileIO.load(filepath)
    end
    return output
end

function owen_write(filepath, data)
    file_extension = splitext(filepath)[2]
    if file_extension == ".hdf5" || file_extension == ".h5"
        output = load_hdf5(filepath, args...; kwargs...)
    elseif file_extension == ".toml"
        output = load_toml(filepath, args...; kwargs...)
    elseif file_extension == ".jld2"
        output = load_jld2(filepath, args...; kwargs...)
    else
        output = FileIO.save(filepath, data)
    end
    return output
end

function load_dm3(filepath)

end

function load_dm4(filepath)

end

function load_hdf5(filepath)

end

function load_mat(filepath::AbstractString, varname::AbstractString)

    file = matopen(filepath)
    if exists(file, varname)
        output = read(file, varname)
    end
    close(file)

    return output
end

function load_mat(filepath::AbstractString; mode="all", kwargs...)
    if mode == "all"
        output = matread(filepath)
    elseif mode == "list"
        file = matopen(filepath)
        output = names(file)
        close(file)
    end
    return output
end

function load_mib(filepath::AbstractString; kwargs...)
    first_header = firstheader(filepath)
    images, headers = read_mib(filepath, first_header; kwargs...)
end

function load_toml(filepath)

end

function load_jld2(filepath)

end

function save_hdf5(filepath)

end

function save_toml(filepath)

end

function save_jld2(filepath)

end









abstract type AbstractMIB end
abstract type AbstractMIBHeader end
abstract type AbstractMIBImage end

struct MIBHeader <: AbstractMIBHeader

    offset::Int
    nchip::Int
    dims::Vector{Int}
    data_type::DataType
    chip_dims::Vector{Int}
    time::DateTime
    exposure_s::Float64
    image_bit_depth::Int
    raw::Bool

    MIBHeader(offset,
              nchip,
              dims,
              data_type,
              chip_dims,
              time,
              exposure_s,
              image_bit_depth,
              raw) = new(offset,
                         nchip,
                         dims,
                         data_type,
                         chip_dims,
                         time,
                         exposure_s,
                         image_bit_depth,
                         raw)

end

function read_mib(filepath::AbstractString, first_header::MIBHeader; range=[1,typemax(Int)])

    offset = first_header.offset
    type = first_header.data_type
    dims = first_header.dims
    raw = first_header.raw
    image_bit_depth = first_header.image_bit_depth

    fid = open(filepath, "r")
    headers = Vector{MIBHeader}()
    if raw
        depth_dict = Dict(1 => UInt8, 6 => UInt8, 12 => UInt16,
                          24 => UInt32, 48 => UInt64)
        type = depth_dict[image_bit_depth]
    end
        buffer = Array{type}(undef, dims[1], dims[2])
        images = Vector{Array{type, 2}}()

    n = 0
    while eof(fid) == false && n < range[2]
            header_string = read(fid, offset)
            read!(fid, buffer)
            n += 1
            if n >= range[1]
                push!(headers, make_mibheader(String(header_string)))
                push!(images, hton.(buffer))
            end
    end
    close(fid)

    return images, headers

end

function firstheader(filepath)

    fid = open(filepath)
    trial = split(String(read(fid, 384)), ",")
    offset = parse(Int, trial[3])
    seekstart(fid)
    header_string = String(read(fid, offset))
    close(fid)
    first_header = make_mibheader(header_string)
    return first_header

end

function make_mibheader(header_string::AbstractString)

    header = split(header_string, ",")
    offset = parse(Int, header[3])
    nchip = parse(Int, header[4])
    dims = parse.(Int, header[5:6])
    type_dict = Dict("U1" => UInt8, "U8" => UInt8, "U08" => UInt8, "U16" => UInt16,
                     "U32" => UInt32, "U64" => UInt64, "R64" => UInt64)
    data_type = type_dict[header[7]]
    chip_dims = parse.(Int, split(lstrip(header[8]), "x"))
    time = DateTime(header[10][1:end-3], "y-m-d H:M:S.s")
    exposure_s = parse(Float64, header[11])
    image_bit_depth = parse(Int, header[end-1])
    raw = header[7] == "R64"
    MIBHeader(offset,
              nchip,
              dims,
              data_type,
              chip_dims,
              time,
              exposure_s,
              image_bit_depth,
              raw)

end
