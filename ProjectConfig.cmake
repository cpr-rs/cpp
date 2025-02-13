set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "Export compile commands")
set({{ project.name | upper }}_VERSION "0.1.0")

execute_process(COMMAND date +"%Y-%m-%d" OUTPUT_VARIABLE {{ project.name | upper }}_BUILD_DATE OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND git rev-parse --short HEAD OUTPUT_VARIABLE {{ project.name | upper }}_BUILD_HASH OUTPUT_STRIP_TRAILING_WHITESPACE)
configure_file(
  "${PROJECT_SOURCE_DIR}/include/Config.hpp.in"
  "${PROJECT_SOURCE_DIR}/include/Config.hpp" @ONLY
)
