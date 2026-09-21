# ros_version.bzl

def ros_generate_version_header(
        name,
        package_name,
        version,
        target,
        header_path = None):
    """Generates a ROS-style version.h and attaches it to a target.

    Args:
        name: Name of the generated filegroup/rule.
        package_name: ROS package name, e.g. "rclcpp".
        version: Package version, e.g. "28.0.0".
        target: The Bazel target that consumes the generated header.
        header_path: Header path relative to the generated include root.
    """

    if header_path == None:
        header_path = package_name + "/version.h"

    parts = version.split(".")
    if len(parts) != 3:
        fail("Version must have format MAJOR.MINOR.PATCH, got: " + version)

    major = parts[0]
    minor = parts[1]
    patch = parts[2]

    native.genrule(
        name = name + "_gen",
        outs = [header_path],
        cmd = """
mkdir -p "$(@D)"
cat > "$@" <<'EOF'
#pragma once

#define {pkg}_VERSION_MAJOR {major}
#define {pkg}_VERSION_MINOR {minor}
#define {pkg}_VERSION_PATCH {patch}

#define {pkg}_VERSION_GTE(major, minor, patch) \\
  (({pkg}_VERSION_MAJOR > (major)) || \\
   ({pkg}_VERSION_MAJOR == (major) && {pkg}_VERSION_MINOR > (minor)) || \\
   ({pkg}_VERSION_MAJOR == (major) && {pkg}_VERSION_MINOR == (minor) && \\
    {pkg}_VERSION_PATCH >= (patch)))
EOF
""".format(
            major = major,
            minor = minor,
            patch = patch,
            pkg = package_name.upper(),
        ),
    )

    native.cc_library(
        name = name,
        hdrs = [":" + name + "_gen"],
        includes = ["."],
        visibility = ["//visibility:public"],
    )
