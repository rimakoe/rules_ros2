load("@com_github_mvukov_rules_ros2//ros2:cc_defs.bzl", "ros2_cpp_binary")

ros2_cpp_binary(
    name = "test_ros2_control",
    srcs = [
        "src/node.test.cpp",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "@control_msgs//:cpp_control_msgs",
        "@ros2_control//:controller_interface",
        "@ros2_control//:controller_manager",
        "@ros2_control//:cpp_controller_manager_msgs",
        "@ros2_control//:hardware_interface",
        "@ros2_control//:joint_limits",
        "@ros2_control//:transmission_interface",
    ],
)
