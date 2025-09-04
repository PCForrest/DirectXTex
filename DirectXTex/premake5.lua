project "DirectXTex"
	kind "StaticLib"

	include "premake5.vstudio.vc2010.project.override.lua"

	language "C++"
	cppdialect "C++17"
	staticruntime "Off"
	location "%{wks.location}/Libs/Vendor/%{prj.name}/%{prj.name}"

	targetdir (bin_dir .. "/Libs/Vendor/%{prj.name}")
	objdir (int_dir .. "/Libs/Vendor/%{prj.name}")

	pchheader "DirectXTexP.h"
	pchsource "DirectXTexUtil.cpp"

	files
	{
		"%{prj.location}/premake5.lua",
		"%{prj.location}/*.h",
		"%{prj.location}/*.inl",
		"%{prj.location}/*.cpp"
	}

	removefiles
	{
		--"%{prj.location}/premake5.lua",
		--"%{prj.location}/d3dx12.h",
		--"%{prj.location}/DirectXTexD3D12.cpp",
	}

	includedirs
	{
		"$(ProjectDir)",
		"../Common",
		"$(ProjectDir)Shaders/Compiled",
	}

	dependson
	{
		-- nil
	}

	links
	{
		-- nil
	}

	defines
	{
		"_UNICODE",
		"UNICODE",
		"WIN32",
		"_LIB",
		"_WIN7_PLATFORM_UPDATE",
		"_WIN32_WINNT=0x0A00",
		"_CRT_STDIO_ARBITRARY_WIDE_SPECIFIERS",
	}

	filter "system:windows"
		systemversion "latest"

	filter "configurations:Debug"
		defines { "_DEBUG" }
		runtime "Debug"
		symbols "on"

	filter "configurations:Release"
		defines { "NDEBUG" }
		runtime "Release"
		optimize "on"

	filter "configurations:Dist"
		defines { "NDEBUG" }
		runtime "Release"
		optimize "on"

	filter {}