package main

import "core:bufio"
import "core:bytes"
import "core:fmt"
import "core:log"
import "core:os"

VERBOSE :: #config(VERBOSE, false)
LOG_LEVEL_DEFAULT: string : "debug" when VERBOSE else "info"
LOG_LEVEL: string : #config(LOG_LEVEL, LOG_LEVEL_DEFAULT)

get_log_level :: #force_inline proc() -> log.Level {
	when LOG_LEVEL == "debug" {return .Debug} else when LOG_LEVEL == "info" {return .Info} else when LOG_LEVEL == "warning" {return .Warning} else when LOG_LEVEL == "error" {return .Error} else when LOG_LEVEL == "fatal" {return .Fatal} else {
		#panic(
			"Unknown `ODIN_TEST_LOG_LEVEL`: \"" +
			LOG_LEVEL +
			"\", possible levels are: \"debug\", \"info\", \"warning\", \"error\", or \"fatal\".",
		)
	}
}

is_split :: proc(diagram: [dynamic][]byte, x, y: int) -> bool {
	if x < 1 {
		return false
	}
	return diagram[x - 1][y] == 'S' && diagram[x][y] == '^'
}

is_beam :: proc(diagram: [dynamic][]byte, x, y: int) -> bool {
	if x < 1 {
		return false
	}
	return diagram[x - 1][y] == 'S'
}

solve1 :: proc(diagram: [dynamic][]byte) -> (solution: u128) {
	for x := 1; x < len(diagram); x += 1 {
		for y := 0; y < len(diagram[x]); y += 1 {
			if is_split(diagram, x, y) {
				diagram[x][y - 1] = 'S'
				diagram[x][y + 1] = 'S'
				solution += 1
			} else if is_beam(diagram, x, y) {
				diagram[x][y] = 'S'
			}
		}
	}
	return
}

solve2 :: proc(diagram: ^[dynamic][]byte, cache: ^[dynamic][]i128, x, y: int) -> i128 {
	if y < 0 && y >= len(diagram[x - 1]) {
		return 0
	}
	if x >= len(diagram) {
		return 1
	}
	if diagram[x][y] == '^' {
		if cache[x][y] == -1 {
			cache[x][y] =
				solve2(diagram, cache, x + 1, y - 1) + solve2(diagram, cache, x + 1, y + 1)
		}
		return cache[x][y]
	}

	return solve2(diagram, cache, x + 1, y)
}

main :: proc() {
	context.logger = log.create_console_logger()
	context.logger.lowest_level = get_log_level()

	scanner: bufio.Scanner
	stdin := os.stream_from_handle(os.stdin)
	bufio.scanner_init(&scanner, stdin, context.temp_allocator)

	p1: u128
	p2: i128

	diagram: [dynamic][]byte
	defer delete(diagram)

	for {
		if !bufio.scanner_scan(&scanner) {
			break
		}
		row := bufio.scanner_bytes(&scanner)
		append_elem(&diagram, bytes.clone(row))
	}

	if err := bufio.scanner_error(&scanner); err != nil {
		fmt.eprintln("error scanning input: %v", err)
	}

	p1 = solve1(diagram)

	s: int
	for ; s < len(diagram[0]); s += 1 {
		if diagram[0][s] == 'S' {
			break
		}
	}

	cache: [dynamic][]i128
	defer delete(cache)

	for i := 0; i < len(diagram); i += 1 {
		append(&cache, make([]i128, len(diagram[0])))
		for j := 0; j < len(cache[i]); j += 1 {
			cache[i][j] = -1
		}
	}

	p2 = solve2(&diagram, &cache, 1, s)

	fmt.printf("puzzle 1 = %d\n", p1)
	fmt.printf("puzzle 2 = %d\n", p2)

	free_all(context.temp_allocator)
}
