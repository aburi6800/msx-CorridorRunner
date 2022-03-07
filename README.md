# Corridor Runner for MSX

## Build

```
mkdir build && cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/z88dk.cmake ..
make clean && make
```

## Run with openMSX


[openMSX](https://openmsx.org/)

```
$ ls -laF dist/*.rom
-rwxrwxrwx 1 hitoshi hitoshi 16384  3月  7 21:28 dist/example.rom*
$ openmsx dist/example.rom
```

## License

MIT License

## Thanks

- [Z88DK - The Development Kit for Z80 Computers](https://github.com/z88dk/z88dk)
- [MAME](https://www.mamedev.org/)
- [C-BIOS](http://cbios.sourceforge.net/)
- [openMSX](https://openmsx.org/)
