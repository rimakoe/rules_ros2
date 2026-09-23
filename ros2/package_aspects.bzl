load("@com_github_mvukov_rules_ros2//ros2:info.bzl", "Ros2BinInfo", "Ros2LibInfo")
load("@com_github_mvukov_rules_ros2//ros2:plugin_aspects.bzl", "get_transitive_items")
load("@rules_cc//cc/common:cc_info.bzl", "CcInfo")

Ros2LibCollectorAspectInfo = provider(
    doc = "Collects ROS 2 package names through a dependency graph.",
    fields = {
        "libraries": "depset of ROS 2 package names",
    },
)

def create_library_struct(target, info, prefix):
    if len(target[DefaultInfo].files.to_list()) == 0:
        library = None
    else:
        library = target[DefaultInfo].files.to_list()[0]

    return struct(
        target_name = target.label.name,
        package_name = info.package_name,
        library = library,
        hdrs = target[CcInfo].compilation_context.direct_public_headers,
        strip_include_prefix = prefix,
    )

def _ros2_library_collector_aspect_impl(target, ctx):
    direct_libraries = []

    if ctx.rule.kind == "cc_library":
        for dep in ctx.rule.attr.deps:
            if Ros2LibInfo in dep:
                direct_libraries.append(create_library_struct(target, dep[Ros2LibInfo], ctx.rule.attr.strip_include_prefix))

    transitive_libraries = get_transitive_items(
        ctx,
        Ros2LibCollectorAspectInfo,
        "libraries",
    )

    return [
        Ros2LibCollectorAspectInfo(
            libraries = depset(
                direct = direct_libraries,
                transitive = transitive_libraries,
            ),
        ),
    ]

ros2_library_collector_aspect = aspect(
    implementation = _ros2_library_collector_aspect_impl,
    attr_aspects = ["deps"],
    provides = [Ros2LibCollectorAspectInfo],
)

Ros2BinCollectorAspectInfo = provider(
    doc = "Collects ROS 2 package names through a dependency graph.",
    fields = {
        "binaries": "depset of ROS 2 package names",
    },
)

def create_binary_struct(target, info):
    return struct(
        target_name = target.label.name,
        package_name = info.package_name,
        binary = target[DefaultInfo].files.to_list()[0],
    )

def _ros2_binary_collector_aspect_impl(target, ctx):
    direct_binaries = []

    if ctx.rule.kind == "cc_binary":
        for dep in ctx.rule.attr.deps:
            if Ros2BinInfo in dep:
                direct_binaries.append(create_binary_struct(target, dep[Ros2BinInfo]))

    transitive_binaries = get_transitive_items(
        ctx,
        Ros2BinCollectorAspectInfo,
        "binaries",
    )

    return [
        Ros2BinCollectorAspectInfo(
            binaries = depset(
                direct = direct_binaries,
                transitive = transitive_binaries,
            ),
        ),
    ]

ros2_binary_collector_aspect = aspect(
    implementation = _ros2_binary_collector_aspect_impl,
    attr_aspects = ["deps"],
    provides = [Ros2BinCollectorAspectInfo],
)
