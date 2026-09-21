# generate_parameter_library.bzl

def generate_parameter_library(
        name,
        yaml_file,
        prefix = "",
        validate_header = None,
        generator = "@generate_parameter_library",
        deps = None):
    """
    Generates a C++ parameter library from a YAML parameter definition.

    Args:
        name: Name of the resulting cc_library.
        yaml_file: YAML file containing the parameter definitions.
        validate_header: Optional user validation header.
        generator: Bazel target for generate_parameter_library_cpp.
        deps: Additional dependencies of the generated library.
    """

    if deps == None:
        deps = []

    if prefix == None:
        generated_header = name + ".hpp"
    else:
        generated_header = prefix + "/" + name + ".hpp"

    inputs = [yaml_file]
    validate_arg = ""

    if validate_header != None:
        inputs.append(validate_header)
        validate_arg = "$(location %s)" % validate_header

    native.genrule(
        name = name + "_generate",
        srcs = inputs,
        outs = [generated_header],
        cmd = "$(location {generator}) $@ $(location {yaml}) {validate}".format(
            generator = generator,
            validate = validate_arg,
            yaml = yaml_file,
        ),
        tools = [generator],
    )

    native.cc_library(
        name = name,
        hdrs = [":" + name + "_generate"],
        includes = ["."],
        visibility = ["//visibility:public"],
        deps = deps + [
            "@fmt",
            "@ros2_rclcpp//:rclcpp",
            "@ros2_rclcpp//:rclcpp_lifecycle",
            "@rsl",
            "@cpp_polyfills//:tcb_span",
            "@cpp_polyfills//:tl_expected",
        ],
    )
