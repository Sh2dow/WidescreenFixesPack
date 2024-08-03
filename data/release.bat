echo off
RD /S /Q ".\Archives"
rem Copying asi loader
setlocal enabledelayedexpansion
FOR /R ".\" %%F IN (*.ual) DO (
findstr /c:"loadfromscriptsonly" "%%F" >nul 2>&1
if errorlevel 1 (
    echo String not found...
) else (
   SET filepath=%%F
   SET dll=!filepath:.ual=.dll!
   ECHO !dll!
   7za e -so "..\Ultimate-ASI-Loader.zip" *.dll -r > !dll!
)
)

FOR /R ".\" %%F IN (*.x64ual) DO (
findstr /c:"loadfromscriptsonly" "%%F" >nul 2>&1
if errorlevel 1 (
    echo String not found...
) else (
   SET filepath=%%F
   SET dll=!filepath:.x64ual=.dll!
   ECHO !dll!
   copy "..\..\Ultimate-ASI-Loader\bin\x64\Release\dinput8.dll" !dll!
   7za e -so "..\Ultimate-ASI-Loader_x64.zip" *.dll -r > !dll!
)
)

rem Additional files
FOR /R ".\" %%F IN (*.wrapper) DO (
findstr /c:"FPSLimit" "%%F" >nul 2>&1
if errorlevel 1 (
        findstr /c:"SetVertexShaderConstantHook" "%%F" >nul 2>&1
        if errorlevel 1 (
            echo String not found...
        ) else (
        SET filepath=%%F
        SET dll=!filepath:.wrapper=.dll!
        ECHO !dll!
        7za e -so "..\d3d8.zip" *.dll -r > !dll!
)
) else (
   SET filepath=%%F
   SET dll=!filepath:.wrapper=.dll!
   ECHO !dll!
   7za e -so "..\d3d9.zip" *.dll -r > !dll!
)
)

rem dgVoodoo

rem Creating archives

rem Additional texture archives

FOR /d %%X IN (*) DO (
7za a -tzip "Archives\%%X.zip" ".\%%X\*" -r -xr^^!Archives -x^^!*.pdb -x^^!*.db -x^^!*.ipdb -x^^!*.iobj -x^^!*.tmp -x^^!*.iobj -x^^!*.ual -x^^!*.x64ual -x^^!*.iobj -x^^!*.wrapper -x^^!*.lib -x^^!*.exp -x^^!*.ilk -x^^!*.map -x^^!*.gitkeep
)

rem Creating texture archives
EXIT

7-Zip Extra
~~~~~~~~~~~
License for use and distribution
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Copyright (C) 1999-2016 Igor Pavlov.

7-Zip Extra files are under the GNU LGPL license.


Notes: 
  You can use 7-Zip Extra on any computer, including a computer in a commercial 
  organization. You don't need to register or pay for 7-Zip.


GNU LGPL information
--------------------

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You can receive a copy of the GNU Lesser General Public License from 
  http://www.gnu.org/

