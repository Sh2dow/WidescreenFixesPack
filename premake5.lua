workspace "WidescreenFixesPack"
   configurations { "Release", "Debug" }
   platforms { "Windows" }
   architecture "x32"
   location "build"
   objdir ("build/obj")
   buildlog ("build/log/%{prj.name}.log")
   cppdialect "C++latest"
   include "makefile.lua"
   buildoptions { "/Zc:__cplusplus" }
   flags { "MultiProcessorCompile" }
   
   kind "SharedLib"
   language "C++"
   targetdir "data/%{prj.name}/scripts"
   targetextension ".asi"
   characterset ("UNICODE")
   staticruntime "On"
   
   defines { "rsc_CompanyName=\"ThirteenAG\"" }
   defines { "rsc_LegalCopyright=\"MIT License\""} 
   defines { "rsc_FileVersion=\"1.0.0.0\"", "rsc_ProductVersion=\"1.0.0.0\"" }
   defines { "rsc_InternalName=\"%{prj.name}\"", "rsc_ProductName=\"%{prj.name}\"", "rsc_OriginalFilename=\"%{prj.name}.asi\"" }
   defines { "rsc_FileDescription=\"https://thirteenag.github.io/wfp\"" }
   defines { "rsc_UpdateUrl=\"https://github.com/ThirteenAG/WidescreenFixesPack\"" }
   
   files { "source/%{prj.name}/*.cpp" }
   files { "data/%{prj.name}/**" }
   files { "Resources/*.rc" }
   files { "external/hooking/Hooking.Patterns.h", "external/hooking/Hooking.Patterns.cpp" }
   files { "external/injector/safetyhook/include/**.hpp", "external/injector/safetyhook/src/**.cpp" }
   files { "external/injector/zydis/**.h", "external/injector/zydis/**.c" }
   files { "includes/stdafx.h", "includes/stdafx.cpp" }
   includedirs { "external/injector/safetyhook/include" }
   includedirs { "external/injector/zydis" }
   includedirs { "external/hooking" }
   includedirs { "external/injector/include" }
   includedirs { "external/inireader" }
   includedirs { "external/spdlog/include" }
   includedirs { "external/filewatch" }
   includedirs { "external/modutils" }
   includedirs { "includes" }
   
   includedirs { "includes/LED" }
   libdirs { "includes/LED" }
   
   local dxsdk = os.getenv "DXSDK_DIR"
   if dxsdk then
      includedirs { dxsdk .. "/include" }
      libdirs { dxsdk .. "/lib/x86" }
   elseif os.isdir("external/minidx9") then
      includedirs { "external/minidx9/Include" }
      libdirs { "external/minidx9/Lib/x86" }
   else
      includedirs { "C:/Program Files (x86)/Microsoft DirectX SDK (June 2010)/include" }
      libdirs { "C:/Program Files (x86)/Microsoft DirectX SDK (June 2010)/lib/x86" }
   end
   
   pbcommands = {
      "setlocal EnableDelayedExpansion",
      --"set \"path=" .. (gamepath) .. "\"",
      "set file=$(TargetPath)",
      "FOR %%i IN (\"%file%\") DO (",
      "set filename=%%~ni",
      "set fileextension=%%~xi",
      "set target=!path!!filename!!fileextension!",
      "if exist \"!target!\" copy /y \"%%~fi\" \"!target!\"",
      ")" 
      }

   function setpaths(gamepath, exepath, scriptspath)
      scriptspath = scriptspath or "scripts/"
      if (gamepath) then
         cmdcopy = { "set \"path=" .. gamepath .. scriptspath .. "\"" }
         table.insert(cmdcopy, pbcommands)
         postbuildcommands (cmdcopy)
         debugdir (gamepath)
         if (exepath) then
            debugcommand (gamepath .. exepath)
            dir, file = exepath:match'(.*/)(.*)'
            debugdir (gamepath .. (dir or ""))
         end
      end
      targetdir ("data/%{prj.name}/" .. scriptspath)
   end
   
   function setbuildpaths_psp(gamepath, exepath, scriptspath, pspsdkpath, sourcepath, prj_name)
      -- local pbcmd = {}
      -- for k,v in pairs(pbcommands) do
      --   pbcmd[k] = v
      -- end
      if (gamepath) then
        buildcommands {"setlocal EnableDelayedExpansion"}
        rebuildcommands {"setlocal EnableDelayedExpansion"}
        local ppsspppath = os.getenv "PPSSPPMemstick"
        if (ppsspppath == nil) then
            buildcommands {"set _PPSSPPMemstick=" .. gamepath .. "memstick/PSP"}
            rebuildcommands {"set _PPSSPPMemstick=" .. gamepath .. "memstick/PSP"}
        else
            buildcommands {"set _PPSSPPMemstick=!PPSSPPMemstick!"}
            rebuildcommands {"set _PPSSPPMemstick=!PPSSPPMemstick!"}
        end
         
        buildcommands {
        "powershell -ExecutionPolicy Bypass -File \"" .. pspsdkpath .. "\" -C \"" .. sourcepath .. "\"\r\n" ..
        "if !errorlevel! neq 0 exit /b !errorlevel!\r\n" ..
        "if not defined _PPSSPPMemstick goto :eof\r\n" ..
        "if not exist !_PPSSPPMemstick! goto :eof\r\n" ..
        "if not exist !_PPSSPPMemstick!/PLUGINS/ mkdir !_PPSSPPMemstick!/PLUGINS/\r\n" ..
        "set target=!_PPSSPPMemstick!/PLUGINS/$(ProjectName)\r\n" ..
        "copy /y $(NMakeOutput) \"!target!\"\r\n"
        }
        rebuildcommands {
        "powershell -ExecutionPolicy Bypass -File \"" .. pspsdkpath .. "\" -C \"" .. sourcepath .. "\" clean\r\n" ..
        "powershell -ExecutionPolicy Bypass -File \"" .. pspsdkpath .. "\" -C \"" .. sourcepath .. "\"\r\n" ..
        "if !errorlevel! neq 0 exit /b !errorlevel!\r\n" ..
        "if not defined _PPSSPPMemstick goto :eof\r\n" ..
        "if not exist !_PPSSPPMemstick! goto :eof\r\n" ..
        "set target=!_PPSSPPMemstick!/PLUGINS/$(ProjectName)\r\n" ..
        "copy /y $(NMakeOutput) \"!target!\"\r\n"
        }
        cleancommands {
        "setlocal EnableDelayedExpansion\r\n" ..
        "powershell -ExecutionPolicy Bypass -File \"" .. pspsdkpath .. "\" -C \"" .. sourcepath .. "\" clean\r\n" ..
        "if !errorlevel! neq 0 exit /b !errorlevel!\r\n"
        }
        debugdir (gamepath)
        if (exepath) then
           debugcommand (gamepath .. exepath)
           dir, file = exepath:match'(.*/)(.*)'
           debugdir (gamepath .. (dir or ""))
        end
      end
      targetdir ("data/%{prj.name}/" .. scriptspath)
   end
   
   function setbuildpaths_ps2(gamepath, exepath, scriptspath, ps2sdkpath, sourcepath, prj_name)
      -- local pbcmd = {}
      -- for k,v in pairs(pbcommands) do
      --   pbcmd[k] = v
      -- end
      if (gamepath) then
        buildcommands {"setlocal EnableDelayedExpansion"}
        rebuildcommands {"setlocal EnableDelayedExpansion"}
        local pcsx2fpath = os.getenv "PCSX2FDir"
        if (pcsx2fpath == nil) then
            buildcommands {"set _PCSX2FDir=" .. gamepath}
            rebuildcommands {"set _PCSX2FDir=" .. gamepath}
        else
            buildcommands {"set _PCSX2FDir=!PCSX2FDir!"}
            rebuildcommands {"set _PCSX2FDir=!PCSX2FDir!"}
        end
        buildcommands {
        "powershell -ExecutionPolicy Bypass -File \"" .. ps2sdkpath .. "\" -C \"" .. sourcepath .. "\"\r\n" ..
        "if !errorlevel! neq 0 exit /b !errorlevel!\r\n" ..
        "if not defined _PCSX2FDir goto :eof\r\n" ..
        "if not exist !_PCSX2FDir! goto :eof\r\n" ..
        "if not exist !_PCSX2FDir!/PLUGINS mkdir !_PCSX2FDir!/PLUGINS\r\n" ..
        "set target=!_PCSX2FDir!/PLUGINS/\r\n" ..
        "copy /y $(NMakeOutput) \"!target!\"\r\n"
        }
        rebuildcommands {
        "powershell -ExecutionPolicy Bypass -File \"" .. ps2sdkpath .. "\" -C \"" .. sourcepath .. "\" clean\r\n" ..
        "powershell -ExecutionPolicy Bypass -File \"" .. ps2sdkpath .. "\" -C \"" .. sourcepath .. "\"\r\n" ..
        "if !errorlevel! neq 0 exit /b !errorlevel!\r\n" ..
        "if not defined _PCSX2FDir goto :eof\r\n" ..
        "if not exist !_PCSX2FDir! goto :eof\r\n" ..
        "if not exist !_PCSX2FDir!/PLUGINS mkdir !_PCSX2FDir!/PLUGINS\r\n" ..
        "set target=!_PCSX2FDir!/PLUGINS/\r\n" ..
        "copy /y $(NMakeOutput) \"!target!\"\r\n"
        }
        cleancommands {
        "setlocal EnableDelayedExpansion\r\n" ..
        "powershell -ExecutionPolicy Bypass -File \"" .. ps2sdkpath .. "\" -C \"" .. sourcepath .. "\" clean\r\n" ..
        "if !errorlevel! neq 0 exit /b !errorlevel!"
        }
         
         debugdir (gamepath)
         if (exepath) then
            debugcommand (gamepath .. exepath)
            dir, file = exepath:match'(.*/)(.*)'
            debugdir (gamepath .. (dir or ""))
         end
      end
      targetdir ("data/%{prj.name}/" .. scriptspath)
   end
   
   function add_asmjit()
      files { "external/asmjit/src/**.h", "external/asmjit/src/**.cpp" }
      includedirs { "external/asmjit/src/asmjit" }
   end

   function add_kananlib()
      defines { "BDDISASM_HAS_MEMSET", "BDDISASM_HAS_VSNPRINTF" }
      files { "external/injector/kananlib/include/utility/**.hpp", "external/injector/kananlib/src/**.cpp" }
      files { "external/injector/bddisasm/bddisasm/*.c" }
      files { "external/injector/bddisasm/bdshemu/*.c" }
      includedirs { "external/injector/kananlib/include" }
      includedirs { "external/injector/bddisasm/inc" }
      includedirs { "external/injector/bddisasm/bddisasm/include" }
   end

   function add_pspsdk()
      includedirs { "external/pspsdk/usr/local/pspdev/psp/sdk/include" }
      includedirs { "external/pspsdk/usr/local/pspdev/bin" }
      files { "source/%{prj.name}/*.h", "source/%{prj.name}/*.c", "source/%{prj.name}/*.cpp", "source/%{prj.name}/makefile" }
   end

   function add_ps2sdk()
      includedirs { "external/ps2sdk/ps2sdk/ee" }
      files { "source/%{prj.name}/*.h", "source/%{prj.name}/*.c", "source/%{prj.name}/*.cpp", "source/%{prj.name}/makefile" }
   end

   function writeghaction(tag, prj_name)       
      file = io.open(".github/workflows/" .. tag .. ".yml", "w")
      if (file) then
str = [[
name: %s

on:
  workflow_dispatch:

jobs:
  call-workflow-passing-data:
    uses: ThirteenAG/WidescreenFixesPack/.github/workflows/all.yml@master
    with:
      tag_list: %s
      project: /t:%s
]]
         file:write(string.format(str, tag, tag, prj_name:gsub("%.", "_")))
         file:close()
      end
   end

   vpaths {
      ["source"] = { "source/**.*" },
      ["ini"] = { "data/**.ini" },
      ["devdata/*"] = { "data/*" },
      ["data"] = { "data/**.cfg", "data/**.dat", "data/**.png", "data/**.ual", "data/**.x64ual", "data/**.dll" },
      ["resources/*"] = { "./resources/*" },
      ["includes/*"] = { "./includes/*" },
      ["external/*"] = "./external/*",
   }

   filter "configurations:Debug*"
      defines "DEBUG"
      symbols "On"

   filter "configurations:Release*"
      defines "NDEBUG"
      optimize "On"

group "Win64"
project "Assembly64.TestApp"
   kind "ConsoleApp"
   targetextension ".exe"
   platforms { "Win64" }
   architecture "x64"
   setpaths("./data/%{prj.name}/", "%{prj.name}.exe", "")

project "Assembly64.TestAsi"
   platforms { "Win64" }
   architecture "x64"
   add_asmjit()
   setpaths("./data/Assembly64.TestApp/", "Assembly64.TestApp.exe", "")

group "Win32/NeedForSpeed"
project "NFSCarbon.WidescreenFix"
   setpaths("Z:/WFP/Games/Need For Speed/Need for Speed Carbon/", "NFSC.exe")
project "NFSMostWanted.WidescreenFix"
   setpaths("Z:/WFP/Games/Need For Speed/Need for Speed Most Wanted/", "speed.exe")
project "NFSProStreet.GenericFix"
   setpaths("Z:/WFP/Games/Need For Speed/Need for Speed ProStreet/", "nfsps.exe")
project "NFSUndercover.GenericFix"
   setpaths("Z:/WFP/Games/Need For Speed/Need for Speed Undercover/", "nfs.exe")
project "NFSUnderground.WidescreenFix"
   setpaths("Z:/WFP/Games/Need For Speed/Need For Speed Underground/", "speed.exe")
   files { "textures/NFS/NFSU/icon.rc" }
   defines { "IDR_NFSUICON=200" }
project "NFSUnderground2.WidescreenFix"
   setpaths("Z:/WFP/Games/Need For Speed/Need For Speed Underground 2/", "speed2.exe")
group "Win32"

