module CopyCat

using Base: values, error
using Core: throw
using ArgParse
using Base.Filesystem: abspath, cp, isdir, joinpath, mv, walkdir

ParsedArgs = Dict{String, Any}

function parse_cli_args()::ParsedArgs
    settings = ArgParseSettings()
    @add_arg_table! settings begin
        "source"
        help = "Dirpath to source folder."
        action = :store_arg
        arg_type = String
        required = true
        nargs = 'A'

        "target"
        help = "Dirpath to target folder."
        action = :store_arg
        arg_type = String
        required = true
        nargs = 'A'
    end

    return parse_args(settings)
end

function convert_path_to_abs(path::String)::String
    abs_path::String = abspath(path)

    if isdir(abs_path)
        return abs_path
    end
    throw(error("$path converted to $abs_path does not point to existing directory."))
end

function copy_file(source_path::String, target_path::String, file::String)::Any
    return cp(joinpath(source_path, file), joinpath(target_path, file))
end

function move_file(source_path::String, target_path::String, file::String)::Any
    return mv(joinpath(source_path, file), joinpath(target_path, file))
end

function process_files(source_path::String, target_path::String, move::Bool = false)::Bool
    try
        for (root, dirs, files) in walkdir(source_path)
            # here we will handle all moving, or copying files
            if !move
                # do copy operations
                length(files) > 0 && copy_file.(source_path, target_path, files)
                return true
            end

            # do move operations
            length(files) > 0 && # move file funct here
                return true
        end
    catch err
        throw(err)
    end
end

function main()
    a = parse_cli_args()
    abs_paths::Array{String} = convert_path_to_abs.(values(a))
    process_files(abs_paths[1], abs_paths[2])
end

main()

end # module
