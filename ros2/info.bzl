# bla
load("@rules_cc//cc/common:cc_info.bzl", "CcInfo")
load("@rules_python//python:py_info.bzl", "PyInfo")

Ros2LibInfo = provider(
    "explanation",
    fields = [
        "package_name",
        "files",
    ],
)

def _ros2_cc_library_info_impl(ctx):
    return [
        CcInfo(),
        Ros2LibInfo(
            package_name = ctx.attr.ros2_package_name,
            files = None,
        ),
    ]

ros2_cc_library_info = rule(
    implementation = _ros2_cc_library_info_impl,
    attrs = {
        "ros2_package_name": attr.string(mandatory = True),
        "library": attr.label(mandatory = False),
    },
)

# explanation
Ros2BinInfo = provider(
    "explanation",
    fields = [
        "package_name",
        "path_to_bin",
    ],
)

def _ros2_cc_binary_info_impl(ctx):
    return [
        CcInfo(),
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

# explanation
Ros2PyBinInfo = provider(
    "explanation",
    fields = [
        "package_name",
    ],
)

def _ros2_py_binary_info_impl(ctx):
    return [
        PyInfo(transitive_sources = depset([])),
        Ros2PyBinInfo(
            package_name = ctx.attr.ros2_package_name,
        ),
    ]

ros2_py_binary_info = rule(
    implementation = _ros2_py_binary_info_impl,
    attrs = {
        "ros2_package_name": attr.string(
            mandatory = True,
        ),
    },
)

# explanation
Ros2PyLibInfo = provider(
    "explanation",
    fields = [
        "package_name",
    ],
)

def _ros2_py_library_info_impl(ctx):
    return [
        PyInfo(transitive_sources = depset([])),
        Ros2PyLibInfo(
            package_name = ctx.attr.ros2_package_name,
        ),
    ]

ros2_py_library_info = rule(
    implementation = _ros2_py_library_info_impl,
    attrs = {
        "ros2_package_name": attr.string(
            mandatory = True,
        ),
    },
)
