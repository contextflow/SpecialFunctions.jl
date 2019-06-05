## This file autogenerated by BinaryProvider.write_deps_file().
## Do not edit.
##
## Include this file within your main top-level source, and call
## `check_deps()` from within your module's `__init__()` method

if isdefined((@static VERSION < v"0.7.0-DEV.484" ? current_module() : @__MODULE__), :Compat)
    import Compat.Libdl
elseif VERSION >= v"0.7.0-DEV.3382"
    import Libdl
end
const openspecfun = joinpath(dirname(@__FILE__), "usr/lib/libopenspecfun.so")
const openspecfun2 = "libopenspecfun.so"
function check_deps()
    global openspecfun, openspecfun2
    isfile(openspecfun) &&  Libdl.dlopen_e(openspecfun)
    isfile(openspecfun2) &&  Libdl.dlopen_e(openspecfun2)
end
