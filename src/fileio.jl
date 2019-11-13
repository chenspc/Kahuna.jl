export kahuna_read, kahuna_write, load_dm3, load_dm4, load_hdf5, load_mat, load_mib, load_toml, load_jld2
export save_hdf5, save_toml, save_jld2
export firstheader, type2dict, mib2h5

function kahuna_read(filepath::AbstractString, args...; kwargs...)
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

function kahuna_write(filepath::AbstractString, parent::AbstractString, name::AbstractString, data, args...; kwargs...)
    file_extension = splitext(filepath)[2]
    if file_extension == ".hdf5" || file_extension == ".h5"
        save_hdf5(filepath, parent, name, data, args...; kwargs...)
    elseif file_extension == ".toml"
        save_toml(filepath, args...; kwargs...)
    elseif file_extension == ".jld2"
        save_jld2(filepath, args...; kwargs...)
    else
        FileIO.save(filepath, data)
    end
end

function kahuna_write(filepath::AbstractString, mib_images::Vector{Array{T, 2}} where T <: Union{UInt8, UInt16, UInt32, UInt64}, mib_headers::Vector{MIBHeader}, args...; kwargs...)
    file_extension = splitext(filepath)[2]
    if file_extension == ".hdf5" || file_extension == ".h5"
        save_hdf5(filepath::AbstractString, mib_images::Vector{Array{T, 2}} where T <: Union{UInt8, UInt16, UInt32, UInt64}, mib_headers::Vector{MIBHeader}, args...; kwargs...)
    elseif file_extension == ".jld2"
        @save filepath mib_images mib_headers
    else
        disp("Data not saved.")
    end
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

function save_hdf5(filepath::AbstractString, parent::AbstractString, name::AbstractString, data, args...; kwargs...)
    fid = h5open(filepath, "w"; kwargs...)
        # d_write(parent, name, data)
    close(fid)
end

# function save_hdf5(filepath::AbstractString, mib_images::Vector{Array{Integer, 2}}, mib_headers::Vector{AbstractMIBHeader}, args...; range=[1,typemax(Int)], kwargs...)
function save_hdf5(filepath::AbstractString, mib_images::Vector{Array{T, 2}} where T <: Union{UInt8, UInt16, UInt32, UInt64}, mib_headers::Vector{MIBHeader}; range=[1,typemax(Int)], kwargs...)
    for i = 1:length(mib_images)
        if range[1] <= mib_headers[i].id <= range[2]
            h5write(filepath, string("image_" , lpad(i, 8, "0")), mib_images[i])
            h5writeattr(filepath, string("image_" , lpad(i, 8, "0")), type2dict(mib_headers[i]))
        end
    end
end

function save_toml(filepath)

end

function save_jld2(filepath)

end

function read_mib(filepath::AbstractString, first_header::AbstractMIBHeader; range=[1,typemax(Int)])
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
                push!(headers, make_mibheader(String(header_string); id=n))
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
    first_header = make_mibheader(header_string; id=1)
    return first_header
end

function make_mibheader(header_string::AbstractString; id=0)
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
    MIBHeader(id,
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

function type2dict(mibtype::AbstractMIBHeader)
    Dict(string(fn) => string(getfield(mibtype, fn)) for fn ∈ fieldnames(typeof(mibtype)))
end

function mib2h5(load_filepath::AbstractString, save_filepath::AbstractString; range=[1,typemax(Int)])
    mib_images, mib_headers = kahuna_read(load_filepath; range=[1,typemax(Int)])
    kahuna_write(save_filepath, mib_images, mib_headers)
end

function mib2h5(load_filepath::AbstractString)
    save_filepath = string(splitext(load_filepath)[1], ".h5")
    mib2h5(load_filepath, save_filepath)
end
