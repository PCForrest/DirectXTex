require('vstudio')

local p = premake
local m = p.vstudio.vc2010

project "DirectXTex"
	kind "StaticLib"
	language "C++"

	targetdir (bin_dir .. "/Libs/Vendor/%{prj.name}")
	objdir (int_dir .. "/Libs/Vendor/%{prj.name}")

	pchheader "DirectXTexP.h"
	pchsource "DirectXTexUtil.cpp"

	files {
		"premake5.lua",
		"*.h",
		"*.inl",
		"*.cpp",
		"../Common/d3dx12.h",
		"Shaders/BC6HEncode.hlsl",
		"Shaders/BC7Encode.hlsl",
		"Shaders/CompileShaders.cmd",
	}

	removefiles {
		"premake5.lua"
	}

	vpaths {
		["Header Files"] =
		{
			"DirectXTex.h",
			"DirectXTex.inl",
		},
		["Source Files"] =
		{
			"BC.cpp",
			"BC.h",
			"BC4BC5.cpp",
			"BC6HBC7.cpp",
			"BCDirectCompute.cpp",
			"BCDirectCompute.h",
			"../Common/d3dx12.h",
			"DDS.h",
			"DirectXTexCompress.cpp",
			"DirectXTexCompressGPU.cpp",
			"DirectXTexConvert.cpp",
			"DirectXTexD3D11.cpp",
			"DirectXTexD3D12.cpp",
			"DirectXTexDDS.cpp", 
			"DirectXTexFlipRotate.cpp", 
			"DirectXTexHDR.cpp", 
			"DirectXTexImage.cpp",
			"DirectXTexMipmaps.cpp",
			"DirectXTexMisc.cpp",
			"DirectXTexNormalMaps.cpp",
			"DirectXTexP.h",
			"DirectXTexPMAlpha.cpp",
			"DirectXTexResize.cpp",
			"DirectXTexTGA.cpp",
			"DirectXTexUtil.cpp",
			"DirectXTexWIC.cpp",
			"filters.h",
			"scoped.h",
		},
		["Source Files/Shaders"] = 
		{
			"Shaders/BC6HEncode.hlsl",
			"Shaders/BC7Encode.hlsl",
			"Shaders/CompileShaders.cmd",
		},
	}

	includedirs {
		"../Common",
		"Shaders/Compiled",
	}

	dependson {
		-- nil
	}

	links {
		-- nil
	}

	defines {
		"_UNICODE",
		"UNICODE",
		"WIN32",
		"_LIB",
		"_WIN32_WINNT=0x0A00",
		"_CRT_STDIO_ARBITRARY_WIDE_SPECIFIERS",
	}

	filter "files:**.hlsl"
		buildaction "None"

	filter "system:windows"
		systemversion "latest"
		cppdialect "C++17"
		staticruntime "off"

	filter "system:linux"
		pic "On"
		systemversion "latest"
		cppdialect "C++17"
		staticruntime "off"

	filter "configurations:Debug"
		defines { "_DEBUG" }
		runtime "Debug"
		symbols "on"

	filter "configurations:Profile"
		defines { "NDEBUG" }
		runtime "Release"
		optimize "on"

	filter "configurations:Release"
		defines { "NDEBUG" }
		runtime "Release"
		optimize "on"

	filter {}

	--[[ FUNCTIONS ]]

	local function ensure_shaders_for_directx_tex(prj)
		if (prj.name == "DirectXTex") then
			p.push('<Target Name="ATGEnsureShaders" BeforeTargets="PrepareForBuild">')
				p.push('<PropertyGroup>')
					p.w('<_ATGFXCPath>$(WindowsSDK_ExecutablePath_x64.Split(\';\')[0])</_ATGFXCPath>')
					p.w('<_ATGFXCPath>$(_ATGFXCPath.Replace("x64",""))</_ATGFXCPath>')
					p.w('<_ATGFXCPath Condition="\'$(_ATGFXCPath)\' != \'\' and !HasTrailingSlash(\'$(_ATGFXCPath)\')">$(_ATGFXCPath)\\</_ATGFXCPath>')
					p.w('<_ATGFXCVer>$([System.Text.RegularExpressions.Regex]::Match($(_ATGFXCPath), `10\\.0\\.\\d+\\.0`))</_ATGFXCVer>')
					p.w('<_ATGFXCVer Condition="\'$(_ATGFXCVer)\' != \'\' and !HasTrailingSlash(\'$(_ATGFXCVer)\')">$(_ATGFXCVer)\\</_ATGFXCVer>')
				p.pop('</PropertyGroup>')
				p.w('<Exec Condition="!Exists(\'Shaders/Compiled/BC6HEncode_EncodeBlockCS.inc\')" WorkingDirectory="$(ProjectDir)Shaders" Command="CompileShaders" EnvironmentVariables="WindowsSdkVerBinPath=$(_ATGFXCPath);WindowsSDKVersion=$(_ATGFXCVer);CompileShadersOutput=$(ProjectDir)Shaders/Compiled" LogStandardErrorAsError=\"true\" />')
				p.push('<PropertyGroup>')
					p.w('<_ATGFXCPath />')
					p.w('<_ATGFXCVer />')
				p.pop('</PropertyGroup>')
			p.pop('</Target>')
			printf("Generated 'ATGEnsureShaders' for DirectXTex project...")
		end
	end

	local function delete_shaders_for_directx_tex(prj)
		if (prj.name == "DirectXTex") then
			p.push('<Target Name="ATGDeleteShaders" AfterTargets="Clean">')
				p.push('<ItemGroup>')
					p.w('<_ATGShaderHeaders Include="$(ProjectDir)Shaders/Compiled/*.inc" />')
					p.w('<_ATGShaderSymbols Include="$(ProjectDir)Shaders/Compiled/*.pdb" />')
				p.pop('</ItemGroup>')
				p.w('<Delete Files="@(_ATGShaderHeaders)" />')
				p.w('<Delete Files="@(_ATGShaderSymbols)" />')
			p.pop('</Target>')
			printf("Generated 'ATGDeleteShaders' for DirectXTex project...")
		end
	end

	--[[ OVERRIDE ]]

	p.override(m.elements, "project", function(base, prj)
		local calls = base(prj)
		table.insertafter(calls, m.importExtensionTargets, delete_shaders_for_directx_tex)
		table.insertafter(calls, m.importExtensionTargets, ensure_shaders_for_directx_tex)
		return calls
	end)
