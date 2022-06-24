### Steps to compile IRBEM x64 on Windows
1. Download and install MSYS2 https://www.msys2.org/
2. Following the installation steps and update the packages:
```
pacman -Syu
```
3. Install base-devel package (https://packages.msys2.org/group/base-devel)
```
pacman -S base-devel
```
4. Install mingw-w64-x86_64-toolchain package (https://packages.msys2.org/group/mingw-w64-x86_64-toolchain). Select default `all` option during the installation.
```
pacman -S mingw-w64-x86_64-toolchain
```
Note that this is a large package but provides easiest installation process.

5. Install git package as it required by the IRBEM Makefile (https://packages.msys2.org/base/git)
```
pacman -S git
```
You can combine steps 3, 4 and 5 into one: `pacman -S base-devel mingw-w64-x86_64-toolchain git`

6. Close this terminal and open `MSYS2 MinGW x64`.
7. Navigate to the IRBEM folder. In the following example it is located at c:\libs\IRBEM\
```
cd /c
cd libs/IRBEM
```
8. (*) If you **have not cloned IRBEM library** you can do it now using `MSYS2 MinGW x64` terminal:
```
cd /c/libs/
git clone https://github.com/PRBEM/IRBEM.git
```
9. Compile the IRBEM library
```
make OS=win64 ENV=gfortran64 all
make OS=win64 ENV=gfortran64 install
```
10. Congratulations! Now you have compiled libirbem.dll library in the root folder of IRBEM.
11. Since libirbem.dll  is a shared library make sure to include `c:\msys64\mingw64\bin\` into Windows Path variable: 
> Press Win+x->Select "System"->In the "About" section find and open "Advanced system settings"->Click button "Environmental Variables..."->Find variable "Path" and click "Edit..."->Click "New" and include `c:\msys64\mingw64\bin\`-> Close all the windows by clicking "Ok". 

Change `c:\msys64\mingw64\bin\` according to you MSYS2 installation path. 

### How to compile IRBEM x32 on Windows
The steps are similar as in the previous description, except a few changes:

4. Instead of `mingw-w64-x86_64-toolchain` install package `mingw-w64-i686-toolchain`

6. Use terminal `MSYS2 MinGW x86`

9. Compile the IRBEM library
```
make OS=win32 ENV=gfortran all
make OS=win32 ENV=gfortran install
```
11. Make sure to include `mingw32` into Windows Path e.g., `c:\msys64\mingw32\bin\`
