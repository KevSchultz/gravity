-- The name of your workspace will be used, for example, to name the Visual Studio .sln file generated by Premake.
workspace "gravity"

-- location of premake generated files
location "generated"

-- We indicate that all the projects are C++ only
language "C++"

-- We will compile for x86_64. You can change this to x86 for 32 bit builds.
architecture "x86_64"

-- Configurations are often used to store some compiler / linker settings together.
-- The Debug configuration will be used by us while debugging.
-- The optimized Release configuration will be used when shipping the app.
configurations {"Debug", "Release"}

-- We use filters to set options, a new feature of Premake5.

-- We now only set settings for the Debug configuration
filter {"configurations:Debug"}
-- We want debug symbols in our debug config
symbols "On"

-- We now only set settings for Release
filter {"configurations:Release"}
-- Release should be optimized
optimize "On"

-- Reset the filter for other settings
filter {}

-- Here we use some "tokens" (the things between %{ ... }). They will be replaced by Premake
-- automatically when configuring the projects.
-- * %{prj.name} will be replaced by "ExampleLib" / "App" / "UnitTests"
--  * %{cfg.longname} will be replaced by "Debug" or "Release" depending on the configuration
-- The path is relative to *this* folder
targetdir("build/bin/%{prj.name}/%{cfg.longname}")
objdir("build/obj/%{prj.name}/%{cfg.longname}")

-- This function includes GLFW's header files
function includeGLFW()
    includedirs "libraries/GLFW/include"
end

-- This function links statically against GLFW
function linkGLFW()
    libdirs "libraries/GLFW/lib"

    -- Our static lib should not link against GLFW
    filter "kind:not StaticLib"
    links "glfw3"
    filter {}
end

-- Our first project, the static library
project "OpenGL"
    -- kind is used to indicate the type of this project.
    kind "StaticLib"


    -- glad headers
    includedirs "libraries/glad/include"

    -- glm headers
    includedirs "libraries/glm/include"

    -- We specify where the source files are.
    -- It would be better to separate header files in a folder and sources
    -- in another, but for our simple project we will put everything in the same place.
    -- Note: ** means recurse in subdirectories, so it will get all the files in ExampleLib/
    files "src/OpenGL/**"

    -- We need GLFW, so we include it
    includeGLFW()

function useOpenGL()
    -- The library's public headers
    includedirs "src/OpenGL"

    -- We link against a library that's in the same workspace, so we can just
    -- use the project name - premake is really smart and will handle everything for us.
    links "OpenGL"

    -- Users of Renderer need to link GLFW
    linkGLFW()
end

-- gravity app
project "gravity"
    kind "WindowedApp"
    files "src/gravity/**"

    includedirs "libraries/glad/include"

    linkGLFW()

    -- We also need the headers
    includedirs "src/OpenGL"

    useOpenGL()
