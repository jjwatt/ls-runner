package(default_visibility = ["//visibility:public"])

load(
    "@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl",
    "jsonnet_library",
    "jsonnet_to_json",
)

# jsonnet_library(
#     name = "envlib",
#     srcs = ["envlib.libsonnet"],
# )

# jsonnet_to_json(
#     name = "env",
#     src = "env.jsonnet",
#     outs = ["env.json"],
#     deps = [":envlib"],
# )

jsonnet_library(
    name = "workflow",
    srcs = ["workflow.libsonnet"],
)

jsonnet_to_json(
    name = "wordcount",
    src = "wordcount.jsonnet",
    outs = ["wordcount.json"],
    deps = [":workflow"],
)
