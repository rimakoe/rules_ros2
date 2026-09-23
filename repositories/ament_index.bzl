# ament index package structure generator

AmentIndexInfo = provider(
    doc = "Ament resource-index entries and files.",
    fields = {
        "files": "Depset containing generated resource-index files.",
    },
)

def _ament_resource_impl(ctx):
    output = ctx.actions.declare_file(
        "share/ament_index/resource_index/{}/{}".format(
            ctx.attr.resource_type,
            ctx.attr.resource_name,
        ),
    )

    if ctx.file.content:
        ctx.actions.run_shell(
            inputs = [ctx.file.content],
            outputs = [output],
            arguments = [
                ctx.file.content.path,
                output.path,
            ],
            command = """
                cp "$1" "$2"
            """,
        )
    else:
        ctx.actions.write(
            output = output,
            content = ctx.attr.value,
        )

    return [
        DefaultInfo(files = depset([output])),
        AmentIndexInfo(files = depset([output])),
    ]

ros2_ament_resource = rule(
    implementation = _ament_resource_impl,
    attrs = {
        "resource_type": attr.string(mandatory = True),
        "resource_name": attr.string(mandatory = True),

        # Optional file containing the resource-index contents.
        "content": attr.label(
            allow_single_file = True,
        ),

        # Or generate the contents directly.
        "value": attr.string(default = ""),
    },
)

def ros2_ament_package(
        name,
        package_name):
    ros2_ament_resource(
        name = name,
        resource_type = "packages",
        resource_name = package_name,
    )
