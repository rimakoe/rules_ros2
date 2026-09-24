# package factory
load("@com_github_mvukov_rules_ros2//ros2:cc_defs.bzl", "ros2_cpp_binary", "ros2_cpp_library")
load("@com_github_mvukov_rules_ros2//ros2:launch.bzl", "ros2_launch")
load("@com_github_mvukov_rules_ros2//ros2:py_defs.bzl", "ros2_py_binary", "ros2_py_library")

# blsd
Ros2PackageInfo = provider(
    "",
    fields = [
        "package_name",
        "nodes",
        "libraries",
        "python_modules",
    ],
)

Ros2PyInfo = provider(
    "",
    fields = [
        "package_name",
        "path_to_module",
    ],
)

def _ros2_package_impl(ctx):
    nodes = []
    libraries = []
    python_modules = []

    for dep in ctx.attr.deps:
        if hasattr(dep, "Ros2BinInfo"):
            nodes.append(dep)

        if hasattr(dep, "Ros2LibInfo"):
            libraries.append(dep)

        if hasattr(dep, "Ros2PyInfo"):
            python_modules.append(dep)

    return [
        Ros2PackageInfo(
            package_name = ctx.attr.package_name,
            nodes = nodes,
            libraries = libraries,
            python_modules = python_modules,
        ),
    ]

ros2_package_rule = rule(
    implementation = _ros2_package_impl,
    attrs = {
        "package_name": attr.string(mandatory = True),
        "deps": attr.label_list(),
    },
)

def ros2_package(package_name):
    deps = []

    def cpp_library(name, **kwargs):
        ros2_cpp_library(
            name = name,
            ros2_package_name = package_name,
            **kwargs
        )
        deps.append(":" + name)

    def cpp_binary(name, **kwargs):
        ros2_cpp_binary(
            name = name,
            ros2_package_name = package_name,
            **kwargs
        )
        deps.append(":" + name)

    def py_library(name, **kwargs):
        ros2_py_library(
            name = name,
            ros2_package_name = package_name,
            **kwargs
        )
        deps.append(":" + name)

    def py_binary(name, **kwargs):
        ros2_py_binary(
            name = name,
            ros2_package_name = package_name,
            **kwargs
        )
        deps.append(":" + name)

    def launch(**kwargs):
        ros2_launch(**kwargs)

    def create():
        ros2_package_rule(
            name = "package",
            package_name = package_name,
            deps = deps,
        )

    return struct(
        cpp_library = cpp_library,
        cpp_binary = cpp_binary,
        py_library = py_library,
        py_binary = py_binary,
        launch = launch,
        create = create,
    )
