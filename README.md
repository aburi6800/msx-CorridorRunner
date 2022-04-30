# Corridor Runner for MSX

## Build

z88dk and cmake are required. Install in advance.  
Clone the project, enter the project root folder, and do the following.  

```
$ mkdir build && cd build
$ cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/z88dk.cmake ..
$ make clean && make
```
The `c-runner.rom` file is output to the project's `dist` directory.  
  
  
## Run with openMSX

OpenMSX is available from:  

[openMSX](https://openmsx.org/)

On the command line, from the project root directory do the following:

```
$ openmsx ./dist/c-runner.rom
```
Or load c-runner.rm from the activated OpenMSX.

## License

MIT License

## Thanks

- [Z88DK - The Development Kit for Z80 Computers](https://github.com/z88dk/z88dk)
- [C-BIOS](http://cbios.sourceforge.net/)
- [openMSX](https://openmsx.org/)
