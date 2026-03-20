# crumblysong

`crumblysong` is a songbook package
for [Typst](https://github.com/typst/typst)
that allows (relatively) easy
typesetting of song sections
and chords over lyrics.

See [`lib.typ`](./lib.typ) for a basic example
and more documentation.

## Installation

`crumblysong` is currently used as a local Typst package.
To install it, you need to copy the package files
into your system's Typst local package directory.

The location depends on your operating system:

- **Linux:** `~/.local/share/typst/packages/local/`
- **macOS:** `~/Library/Application Support/typst/packages/local/`
- **Windows:** `%APPDATA%\typst\packages\local\`

Inside the `local` directory,
create a folder for the package and its version:
`crumblysong/0.1.0/`.
Finally either copy the files
or clone this repository
into the `0.1.0` directory.

After that you can import the package with
```typ
#import "@local/crumblysong:0.1.0": *
```
