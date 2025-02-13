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

FetchContent_Declare(
  catch2
  GIT_REPOSITORY https://github.com/catchorg/Catch2.git
  GIT_TAG v3.7.1
)

FetchContent_Declare(
  cxxopts
  GIT_REPOSITORY https://github.com/jarro2783/cxxopts.git
  GIT_TAG v3.2.1
)

FetchContent_Declare(
  backward
  GIT_REPOSITORY https://github.com/bombela/backward-cpp.git
  GIT_TAG master
  SYSTEM
)

FetchContent_MakeAvailable(catch2)
FetchContent_MakeAvailable(cxxopts)
FetchContent_MakeAvailable(backward)
