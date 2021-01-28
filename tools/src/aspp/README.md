# aspp

Simple assembler source file preprocessor. It processes source's file dependencies and produces a text line to be used in makefiles.

## License

Public domain (see [UNLICENSE](UNLICENSE) file).

## Authors

See [AUTHORS](AUTHORS) file.

## Dependencies

This project uses these external works:

Bash-script run-time:
  * GNU Core utilities
  * GNU Bash
  * GNU Grep
  * GNU Sed

GNU/Linux compilation (common dependencies):
  * GNU Make
  * GNU Core utilities

GNU/Linux native compilation:
  * GNU C compiler

GNU/Linux cross-compilation for Windows NT:
  * GNU C compiler (MinGW target)

## GNU/Linux compilation

### Build

Use the following commands to build the project:

Command                | Target directory              | Target executable
---------------------- | ----------------------------- | ---
`make DEBUG=0 all`     | `build/release/linux`         | native GNU/Linux executable
`make DEBUG=0 mingw32` | `build/release/linux-mingw32` | Windows NT executable (32-bit MinGW compiler)
`make DEBUG=0 mingw64` | `build/release/linux-mingw64` | Windows NT executable (64-bit MinGW compiler)
`make DEBUG=1 all`     | `build/debug/linux`           | native GNU/Linux executable, debug version
`make DEBUG=1 mingw32` | `build/debug/linux-mingw32`   | Windows NT executable, debug version (32-bit MinGW compiler)
`make DEBUG=1 mingw64` | `build/debug/linux-mingw64`   | Windows NT executable, debug version (64-bit MinGW compiler)

**Note**: Parameter `DEBUG=0` may be omitted.

### Clean

Use the following commands to clean target directory:

Command                      | Target directory               | What is removed
---------------------------- | ------------------------------ | ---
`make DEBUG=0 clean`         | `build/release/linux`          | result files
`make DEBUG=0 mingw32-clean` | `build/release/linux-mingw32`  | result files
`make DEBUG=0 mingw64-clean` | `build/release/linux-mingw64`  | result files
`make DEBUG=1 clean`         | `build/debug/linux`            | result files
`make DEBUG=1 mingw32-clean` | `build/debug/linux-mingw32`    | result files
`make DEBUG=1 mingw64-clean` | `build/debug/linux-mingw64`    | result files
`make distclean`             | `build`                        | everything

**Note**: Parameter `DEBUG=0` may be omitted.

For more information type `make` without parameters.

## Usage

```
Usage:
    aspp [options] [filename ...] [options]

Options (GCC-compatible):
-h, --help      show this help and exit
-E              preprocess
-I <path>       include directory
-M[M]           output autodepend make rule
-MF <file>      autodepend output name
-MT <target>    autodepend target name (can be specified multiple times)

Other options:
--syntax <syntax>   select source file syntax (tasm, sjasm)
```

## Links

* [GNU Operating System](https://www.gnu.org/)
* [GNU Core Utilities](https://www.gnu.org/software/coreutils/) ([package](https://pkgs.org/download/coreutils))
* [GNU Make](https://www.gnu.org/software/make/) - utility for directing compilation ([package](https://pkgs.org/download/make))
* [GNU Bash](https://www.gnu.org/software/bash/) - GNU Bourne Again SHell ([package](https://pkgs.org/download/bash))
* [GNU grep](https://www.gnu.org/software/grep) - a non-interactive command-line utility to search for text in files ([package](https://pkgs.org/download/grep))
* [GNU sed](https://www.gnu.org/software/sed) - a non-interactive command-line text editor ([package](https://pkgs.org/download/sed))
* [GNU Compiler Collection](https://www.gnu.org/software/gcc/) ([package](https://pkgs.org/download/gcc))
* [GNU Standards](http://savannah.gnu.org/projects/gnustandards) - GNU coding and package maintenance standards ([package](https://pkgs.org/download/gnu-standards))
