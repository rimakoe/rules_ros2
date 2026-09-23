# bla
load("@rules_cc//cc/common:cc_info.bzl", "CcInfo")

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
