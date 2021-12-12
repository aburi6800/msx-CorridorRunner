# Corridor Runner for MSX

## Build

```
mkdir build && cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/z88dk.cmake ..
make
```

## Run with openMSX


[openMSX](https://openmsx.org/)

```
$ ls -laF dist/*.rom
-rw-rw-r-- 1 hiromasa hiromasa 16384  9月  3 18:13 dist/example.rom
$ openmsx dist/example.rom
```

## License

MIT License

## Thanks

- [Z88DK - The Development Kit for Z80 Computers](https://github.com/z88dk/z88dk)
- [MAME](https://www.mamedev.org/)
- [C-BIOS](http://cbios.sourceforge.net/)
- [openMSX](https://openmsx.org/)
