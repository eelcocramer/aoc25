# AoC 2025 in Odin

Every year I'm trying to solve the [Advent of Code](https://adventofcode.com)
using a new programming language.
This year using [Odin](https://odin-lang.org).

All solutions are in their respective directories.
To solve the puzzles use:

```bash
cat puzzle.txt | odin run .
```

To run the simple example use:

```bash
cat test.txt | odin run .
```

Some days have units tests.
To run use:

```bash
odin test .
# or with debug logging enabled
odin test . -define:ODIN_TEST_LOG_LEVEL=debug
```

> I'm really enjoying Odin. The learning curv is not as painful compared to Zig
> or Rust which I tried in previous years.
