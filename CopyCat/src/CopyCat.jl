module CopyCat

using Base: values, error
using Core: throw
using ArgParse
using Base.Filesystem: abspath, cp, isdir, joinpath, mv, splitpath, walkdir, mkdir
using Base.Iterators: enumerate

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
    !isdir(target_path) && mkdir(target_path)
    return cp(joinpath(source_path, file), joinpath(target_path, file))
end

function move_file(source_path::String, target_path::String, file::String)::Any
    !isdir(target_path) && mkdir(target_path)
    return mv(joinpath(source_path, file), joinpath(target_path, file))
end

function get_subfolders(base_path::String, to_replace_path::String)::String
    !startswith(base_path, to_replace_path) &&
        throw(error("Not possible to get correct subdirectories sub-path string."))

    return replace(base_path, to_replace_path => String(""))
end

function process_files(source_path::String, target_path::String, move::Bool = false)::Bool
    try
        for (root, dirs, files) in walkdir(source_path)
            # here we will handle all moving, or copying files
            if length(files) > 0
                expanded_target_path::String = target_path

                if root !== source_path
                    # for some reason, no Filesystem join method works here :o
                    # they drop all the absolute part until the subfolders
                    # possible because of this: https://docs.julialang.org/en/v1/base/file/#Base.Filesystem.joinpath
                    # so I had to just string concat the path
                    expanded_target_path = target_path * get_subfolders(root, source_path)
                end

                !move ? copy_file.(root, expanded_target_path, files) :
                move_file.(root, expanded_target_path, files)
            end
        end
    catch err
        throw(err)
    end
    return true
end

function main()
    a = parse_cli_args()
    abs_paths::Array{String} = convert_path_to_abs.(values(a))
    process_files(abs_paths[1], abs_paths[2])
end

main()

end # module
