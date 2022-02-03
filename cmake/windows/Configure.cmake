find_package(SDL2 REQUIRED)
find_package(sdl2-image REQUIRED)
find_package(sdl2-mixer REQUIRED)
find_package(PhysFS REQUIRED)

add_executable(${EXE} ${EXE_SOURCES})
target_link_libraries(${EXE}
	PUBLIC
		SDL2::SDL2
		SDL2::SDL2main
		SDL2::SDL2_image
		SDL2::SDL2_mixer
		${PHYSFS_LIBRARY}
)
target_include_directories(${EXE} SYSTEM PRIVATE
	${PHYSFS_INCLUDE_DIR}
)

option(HIDE_WINDOWS_CONSOLE "Hide the Windows console.")
target_link_options(${EXE}
	PRIVATE
		$<$<BOOL:${HIDE_WINDOWS_CONSOLE}>:
			/ENTRY:mainCRTStartup
			/SUBSYSTEM:WINDOWS
		>
)

if(${PACKAGE_TYPE} STREQUAL "WorkingDir")
	message(STATUS "Configuring working directory version; CMake installation is not supported")
	set(BASE_PATH "SDL_strdup(\"./\")")
	set(BASE_PATH_APPEND "\"\"")
	set(PREF_PATH "SDL_strdup(\"./\")")
else()
	if(${PACKAGE_TYPE} STREQUAL "Portable")
		message(STATUS "Configuring portable package")
		set(BASE_PATH "SDL_GetBasePath()")
		set(BASE_PATH_APPEND "\"\"")
		set(PREF_PATH "SDL_GetBasePath()")
	elseif(${PACKAGE_TYPE} STREQUAL "Installable")
		message(STATUS "Configuring installable package")
		set(BASE_PATH "SDL_GetBasePath()")
		set(BASE_PATH_APPEND "\"\"")
		set(PREF_PATH "SDL_GetPrefPath(\"nightmareci\", \"HeborisC7EX SDL2\")")
	else()
		message(FATAL_ERROR "Package type \"${PACKAGE_TYPE}\" unsupported")
	endif()
	install(TARGETS ${EXE} DESTINATION ".")
	install(DIRECTORY "${SRC}/config/mission" "${SRC}/config/stage" DESTINATION "config")
	install(DIRECTORY "${SRC}/res" DESTINATION ".")
	install(FILES "${SRC}/changelog.txt" "${SRC}/heboris.txt" "${SRC}/README.md" DESTINATION ".")
	include(InstallRuntimeDependenciesMSVC.cmake REQUIRED)
endif()
configure_file("${SRC}/src/main_sdl/paths.h.in" "src/main_sdl/paths.h" @ONLY)