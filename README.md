VSNASM
=============
[![Github All Releases](https://img.shields.io/github/downloads/ShiftMediaProject/VSNASM/total.svg)](https://github.com/ShiftMediaProject/VSNASM/releases)
[![GitHub release](https://img.shields.io/github/release/ShiftMediaProject/VSNASM.svg)](https://github.com/ShiftMediaProject/VSNASM/releases/latest)
[![GitHub issues](https://img.shields.io/github/issues/ShiftMediaProject/VSNASM.svg)](https://github.com/ShiftMediaProject/VSNASM/issues)
[![license](https://img.shields.io/github/license/ShiftMediaProject/VSNASM.svg)](https://github.com/ShiftMediaProject/VSNASM)
[![donate](https://img.shields.io/badge/donate-link-brightgreen.svg)](https://shiftmediaproject.github.io/8-donate/)

## About

This project provides a set of build customisations that can be used within Visual Studio to compile assembly code using NASM.
Provides Visual Studio integration for the NASM assembler.
Supports Visual Studio 2010, 2012, 2013, 2015, 2017 and 2019.

## NASM

The Netwide Assembler (NASM) is an assembler and disassembler for the Intel x86 architecture. It can be used to write 16-bit, 32-bit (IA-32) and 64-bit (x86-64) programs.
For more information on NASM refer to the official site: [www.nasm.us](www.nasm.us).

## Installation

The project provides a basic installer script that can automatically detect any installed Visual Studio 2013, 2015, 2017 or 2019 installation and then install the required components.
To use this script simply run '**install_script.bat**' from an elevated command prompt.

Alternatively, to manually install the extension you will first need to download the required win32 or win64 binary (depending on your system) from the official NASM website [www.nasm.us](www.nasm.us).

From the download archive you will need to extract nasm.exe into a location that Visual Studio can see.
To tell Visual Studio where to find nasm.exe you have several options:

1. Find the directory where the Visual Studio C++ compiler is installed.
This can be determined from within Visual Studio by checking the contents of the VCInstallDir macro.
For example the location for Visual Studio 2015 would be:

    1. C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC         -- For a 64 bit system
    2. C:\Program Files\Microsoft Visual Studio 14.0\VC               -- For a 32 bit system

2. You can install nasm to any directory and then set environment variable NASMPATH to point to the absolute directory of the installed nasm.exe (this path should include the final backslash).

To use the build customisation in Visual Studio you need to copy the 3 provided files (nasm.props, nasm.xml, nasm.targets) into a location where they can be found by the Visual Studio build customisation processes.
There are several ways to do this:

1. Copy these files to the MSBuild customisations directory.
This can be determined from within Visual Studio by checking the contents of the VCTargetsPath macro.
For example the location for various Visual Studio versions on a 64 bit system would be:

    1. Visual Studio 2013: C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V120\BuildCustomizations
    2. Visual Studio 2015: C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V140\BuildCustomizations
    3. Visual Studio 2017: C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\VC\VCTargets\BuildCustomizations
	4. Visual Studio 2019: C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Microsoft\VC\v160\BuildCustomizations

2. Copy these files to a convenient location and set that path in the 'Build Customisations Search Path' in the Visual Studio 'Projects and Solutions|VC++ Project Settings' item in the 'Tools|Options' menu.

3. Copy these files to a convenient location and set this path in the 'Build Customisation dialogue (discussed later).

To use NASM in a project you must enable the customisation by right clicking on the project in the Solution Explorer and select 'Build Customisations..'. This will give you a dialog box that allows you to select NASM as an assembler (note that your assembly files need to have the extension '.asm').  If you have used option **3** above, you will need to let the dialogue find them using the 'Find Existing' button below the dialogue.

To assemble a file with NASM, select the Property Page for the file and ensure that 'Nasm Assembler' is selected in the Tool dialog entry.
The additional NASM property page can then be used to change various options supported by NASM.