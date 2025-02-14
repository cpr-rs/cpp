# External Dependencies

include(FetchContent)

#[[
FetchContent_Declare(
    <name>
    GIT_REPOSITORY <repo>
    GIT_TAG <tag>
    <GIT_SHALLOW TRUE/FALSE>
)

FetchContent_MakeAvailable(<name>)
#]]
{% if cpr.testing_enabled %}

FetchContent_Declare(
  catch2
  GIT_REPOSITORY https://github.com/catchorg/Catch2.git
  GIT_TAG v3.7.1
)
{% endif %}

FetchContent_Declare(
  structopt
  GIT_REPOSITORY https://github.com/p-ranav/structopt.git
  GIT_TAG master
)

FetchContent_Declare(
  backward
  GIT_REPOSITORY https://github.com/bombela/backward-cpp.git
  GIT_TAG master
  SYSTEM
)

FetchContent_Declare(
  fmt
  GIT_REPOSITORY https://github.com/fmtlib/fmt
  GIT_TAG e69e5f977d458f2650bb346dadf2ad30c5320281
)

{% if cpr.testing_enabled %}FetchContent_MakeAvailable(catch2){% endif %}
FetchContent_MakeAvailable(structopt)
FetchContent_MakeAvailable(backward)
FetchContent_MakeAvailable(fmt)

set(USE_VENDOR_TARGETS 
  structopt::structopt
  Backward::Object
  fmt::fmt
)
{% if cpr.testing_enabled %}set(USE_TEST_VENDOR_TARGETS "${USE_VENDOR_TARGETS}" Catch2::Catch2WithMain){% endif %}
