require('vstudio')

local p = premake
local m = p.vstudio.vc2010

local function ensureShadersForDirectXTex(prj)
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

local function deleteShadersForDirectXTex(prj)
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

p.override(m.elements, "project", function(base, prj)
	local calls = base(prj)
	table.insertafter(calls, m.importExtensionTargets, deleteShadersForDirectXTex)
	table.insertafter(calls, m.importExtensionTargets, ensureShadersForDirectXTex)
	return calls
end)
