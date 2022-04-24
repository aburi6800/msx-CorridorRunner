# Corridor Runner for MSX

## Build

Clone the project and execute the following command.  

```
$ mkdir build && cd build
$ cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/z88dk.cmake ..
$ make clean && make
```
The `.rom` file is output to the project's `dist` directory.  

## Run with openMSX

[openMSX](https://openmsx.org/)

```
$ openmsx ../dist/example.rom
```

## License

MIT License

## Thanks

- [Z88DK - The Development Kit for Z80 Computers](https://github.com/z88dk/z88dk)
- [MAME](https://www.mamedev.org/)
- [C-BIOS](http://cbios.sourceforge.net/)
- [openMSX](https://openmsx.org/)
