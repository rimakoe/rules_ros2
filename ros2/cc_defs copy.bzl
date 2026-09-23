""" Defines commonly used C/C++ macros.
"""

load("@com_github_mvukov_rules_ros2//ros2:ament.bzl", "sh_exec_launcher", "split_kwargs")
load("@com_github_mvukov_rules_ros2//ros2:cc_opts.bzl", "C_COPTS")
load("@com_github_mvukov_rules_ros2//ros2:plugin_aspects.bzl", "Ros2PackageInfo")
load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library", "cc_test")
load("@rules_cc//cc/common:cc_info.bzl", "CcInfo")
load("@rules_shell//shell:sh_binary.bzl", "sh_binary")
load("@rules_shell//shell:sh_test.bzl", "sh_test")

Ros2LibInfo = provider(
    "explanation",
    fields = [
        "package_name",
        "path_to_lib",
    ],
)

def _ros2_cc_binary_info_impl(ctx):
    return [
        Ros2BinInfo(
            package_name = ctx.attr.ros2_package_name,
        ),
    ]

ros2_cc_binary_info = rule(
    implementation = _ros2_cc_binary_info_impl,
    attrs = {
        "ros2_package_name": attr.string(
            mandatory = True,
        ),
    },
)

def _ros2_cc_library_info_impl(ctx):
    return [
        Ros2LibInfo(
            package_name = ctx.attr.ros2_package_name,
        ),
    ]

ros2_cc_library_info = rule(
    implementation = _ros2_cc_library_info_impl,
    attrs = {
        "ros2_package_name": attr.string(
            mandatory = True,
        ),
    },
)

def ros2_c_library(name, ros2_package_name = None, copts = [], local_defines = [], **kwargs):
    ros2_package_name = ros2_package_name or name
    cc_library(
        name = name,
        copts = C_COPTS + copts,
        local_defines = ["ROS_PACKAGE_NAME=\\\"{}\\\"".format(ros2_package_name)] + local_defines,
        **kwargs
    )
    ros2_cc_library_info(name = name + "_info", ros2_package_name = ros2_package_name, visibility = kwargs.get("visibility"))

def ros2_cpp_library(name, ros2_package_name = None, local_defines = [], **kwargs):
    ros2_package_name = ros2_package_name or name
    cc_library(
        name = name,
        local_defines = ["ROS_PACKAGE_NAME=\\\"{}\\\"".format(ros2_package_name)] + local_defines,
        **kwargs
    )
    ros2_cc_library_info(name = name + "_info", ros2_package_name = ros2_package_name, visibility = kwargs.get("visibility"))

def ros2_c_binary(name, ros2_package_name = None, copts = [], **kwargs):
    ros2_package_name = ros2_package_name or name
    cc_binary(
        name = name,
        copts = C_COPTS + copts,
        **kwargs
    )
    ros2_cc_binary_info(name = name + "_info", ros2_package_name = ros2_package_name, visibility = kwargs.get("visibility"))

def ros2_cpp_binary(name, ros2_package_name = None, **kwargs):
    ros2_package_name = ros2_package_name or name
    _ros2_cpp_exec(cc_test, name, ros2_package_name, set_up_ament, idl_deps, **kwargs)
    ros2_cc_binary_info(name = name + "_info", ros2_package_name = ros2_package_name, visibility = kwargs.get("visibility"))

def ros2_cpp_test(name, ros2_package_name = None, idl_deps = None, set_up_ament = False, **kwargs):
    """
    a
    """
    ros2_package_name = ros2_package_name or name
    _ros2_cpp_exec(cc_test, name, ros2_package_name, set_up_ament, idl_deps, **kwargs)
    ros2_cc_binary_info(name = name + "_info", ros2_package_name = ros2_package_name, visibility = kwargs.get("visibility"))

def _ros2_cpp_exec(target, name, ros2_package_name, set_up_ament, idl_deps, **kwargs):
    if idl_deps != None and len(idl_deps) > 0:
        set_up_ament = True
    is_test = target == cc_test
    set_up_launcher = is_test or set_up_ament
    if set_up_launcher == False:
        _ros2_cc_target(target, "cpp", name, ros2_package_name, **kwargs)
        return

    launcher_target_kwargs, binary_kwargs = split_kwargs(**kwargs)
    target_impl = name + "_impl"
    cc_tags = launcher_target_kwargs.get("tags", []) + ["manual"]
    _ros2_cc_target(cc_binary, "cpp", target_impl, ros2_package_name, tags = cc_tags, **binary_kwargs)

    launcher = "{}_launch".format(name)
    ament_setup_deps = [target_impl] if set_up_ament else None
    sh_exec_launcher(
        launcher,
        ament_setup_deps = ament_setup_deps,
        template = "@com_github_mvukov_rules_ros2//ros2:launch_exec.sh.tpl",
        substitutions = {
            "{entry_point}": "$(rootpath {})".format(target_impl),
        },
        tags = ["manual"],
        data = [target_impl],
        idl_deps = idl_deps,
        testonly = is_test,
    )

    sh_target = sh_test if is_test else sh_binary
    sh_target(
        name = name,
        srcs = [launcher],
        data = [target_impl],
        **launcher_target_kwargs
    )

def ros2_cpp_binary(name, ros2_package_name = None, set_up_ament = False, idl_deps = None, **kwargs):
    """ Defines a ROS 2 C++ binary.

    Adds common ROS 2 C++ definitions on top of a cc_binary.

    Args:
        name: A unique target name.
        ros2_package_name: If given, defines a ROS package name for the target.
            Otherwise, the `name` is used as the package name.
        set_up_ament: If true, sets up ament file tree for the binary target.
        idl_deps: Additional IDL deps that are used as runtime plugins.
        **kwargs: https://bazel.build/reference/be/common-definitions#common-attributes-binaries
    """
    _ros2_cpp_exec(cc_binary, name, ros2_package_name, set_up_ament, idl_deps, **kwargs)
