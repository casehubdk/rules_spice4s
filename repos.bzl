load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

spice4s_build_file = """
load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")
load("@io_bazel_rules_scala//scala_proto:scala_proto.bzl", "scala_proto_library")

proto_library(
    name = "protolib",
    srcs = glob(["proto/src/main/**/*.proto"]),
    visibility = ["//visibility:public"],
    deps = [
      "@common_protos//:scalapb_protos",
      "@common_protos//:common_protos",
      "@validate_scalapb_protos//:validate_scalapb_protos",
      "@fs2_grpc//validate",
      "@google_api_common_protos//google/api:annotations_proto",
      "@google_api_common_protos//google/api:http_proto",
    ],
    strip_import_prefix = "proto/src/main/protobuf"
)

scala_proto_library(
    name = "s4s_gen",
    visibility = ["//visibility:public"],
    deps = [
      ":protolib"
    ],
)

scala_library(
  name = "spice4s-client",
  scalacopts = ["-Xsource:3"],
  srcs = glob([
    "client/src/main/scala/**/*.scala"
  ]),
  plugins = [
      "@maven//:com_olegpy_better_monadic_for_2_13",
      "@maven//:org_typelevel_kind_projector_2_13_11",
  ],
  visibility = ["//visibility:public"],
  deps = [
    ":s4s_gen",
  ]
)

scala_library(
  name = "spice4s-encoder",
  scalacopts = ["-Xsource:3"],
  srcs = glob([
    "encoder/src/main/scala/**/*.scala"
  ]),
  plugins = [
      "@maven//:com_olegpy_better_monadic_for_2_13",
      "@maven//:org_typelevel_kind_projector_2_13_11",
  ],
  visibility = ["//visibility:public"],
  deps = [
    ":s4s_gen",
    ":spice4s-client",
  ]
)

scala_library(
  name = "spice4s-generator-core",
  scalacopts = ["-Xsource:3"],
  srcs = glob([
    "generator-core/src/main/scala/**/*.scala"
  ]),
  plugins = [
      "@maven//:com_olegpy_better_monadic_for_2_13",
      "@maven//:org_typelevel_kind_projector_2_13_11",
  ],
  visibility = ["//visibility:public"],
  deps = [
    ":s4s_gen",
    ":spice4s-client",
  ]
)

scala_library(
  name = "spice4s-parser",
  scalacopts = ["-Xsource:3"],
  srcs = glob([
    "parser/src/main/scala/**/*.scala"
  ]),
  plugins = [
      "@maven//:com_olegpy_better_monadic_for_2_13",
      "@maven//:org_typelevel_kind_projector_2_13_11",
  ],
  visibility = ["//visibility:public"],
  deps = [
    "@maven//:org_typelevel_cats_parse_2_13",
    "@maven//:org_typelevel_cats_core_2_13",
    "@maven//:org_scala_lang_scala_library",
  ]
)

scala_library(
  name = "spice4s-generator",
  scalacopts = ["-Xsource:3"],
  srcs = glob([
    "generator/src/main/scala/**/*.scala"
  ]),
  plugins = [
      "@maven//:com_olegpy_better_monadic_for_2_13",
      "@maven//:org_typelevel_kind_projector_2_13_11",
  ],
  visibility = ["//visibility:public"],
  deps = [
    "@maven//:org_typelevel_cats_parse_2_13",
    "@maven//:org_typelevel_cats_core_2_13",
    "@maven//:org_scala_lang_scala_library",
    "@maven//:co_fs2_fs2_core_2_13",
    "@maven//:co_fs2_fs2_io_2_13",
    "@maven//:org_typelevel_cats_effect_2_13",
    "@maven//:org_typelevel_cats_effect_kernel_2_13",
    "@maven//:org_scalameta_scalameta_2_13",
    "@maven//:org_scalameta_common_2_13",
    "@maven//:org_scalameta_parsers_2_13",
    "@maven//:org_scalameta_trees_2_13",
    ":spice4s-parser",
    "@maven//:org_typelevel_cats_kernel_2_13",
  ]
)

scala_library(
  name = "spice4s-generator-cli",
  scalacopts = ["-Xsource:3"],
  srcs = glob([
    "generator-cli/src/main/scala/**/*.scala"
  ]),
  plugins = [
      "@maven//:com_olegpy_better_monadic_for_2_13",
      "@maven//:org_typelevel_kind_projector_2_13_11",
  ],
  visibility = ["//visibility:public"],
  deps = [
    "@maven//:org_typelevel_cats_core_2_13",
    "@maven//:org_scala_lang_scala_library",
    "@maven//:co_fs2_fs2_io_2_13",
    "@maven//:org_typelevel_cats_effect_2_13",
    "@maven//:org_typelevel_cats_effect_kernel_2_13",
    ":spice4s-generator",
    "@maven//:org_typelevel_cats_kernel_2_13",
    "@maven//:com_monovore_decline_effect_2_13",
    "@maven//:com_monovore_decline_2_13",
  ]
)
"""

def rules_spice4s_repositories():
  spice4s_version = "8143af272a0546028bf218b3d102475cd72acc8d"
  http_archive(
      name = "spice4s",
      # sha256 = "8410832c7fadaac05b5d052efe296f0ebfd01e89267c744c9aeb29abb8ba4581",
      strip_prefix = "spice4s-%s" % spice4s_version,
      type = "zip",
      url = "https://github.com/casehubdk/spice4s/archive/%s.zip" % spice4s_version,
      build_file_content = spice4s_build_file
  )
