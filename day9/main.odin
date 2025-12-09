#+feature dynamic-literals
package main

import "core:bufio"
import "core:bytes"
import "core:fmt"
import "core:log"
import "core:math/linalg"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

VERBOSE :: #config(VERBOSE, false)
LOG_LEVEL_DEFAULT: string : "debug" when VERBOSE else "info"
LOG_LEVEL: string : #config(LOG_LEVEL, LOG_LEVEL_DEFAULT)

PAIRS :: #config(PAIRS, 1000)

get_log_level :: #force_inline proc() -> log.Level {
	when LOG_LEVEL == "debug" {return .Debug} else when LOG_LEVEL == "info" {return .Info} else when LOG_LEVEL == "warning" {return .Warning} else when LOG_LEVEL == "error" {return .Error} else when LOG_LEVEL == "fatal" {return .Fatal} else {
		#panic(
			"Unknown `ODIN_TEST_LOG_LEVEL`: \"" +
			LOG_LEVEL +
			"\", possible levels are: \"debug\", \"info\", \"warning\", \"error\", or \"fatal\".",
		)
	}
}

parse_vector :: proc(line: string) -> (v: linalg.Vector2f64) {
	x, _, y := strings.partition(line, ",")
	v.x, _ = strconv.parse_f64(x)
	v.y, _ = strconv.parse_f64(y)
	return
}

rectangle_size :: proc(v: linalg.Vector2f64) -> u128 {
	return u128((abs(v.x) + 1) * (abs(v.y) + 1))
}

main :: proc() {
	context.logger = log.create_console_logger()
	context.logger.lowest_level = get_log_level()
	scanner: bufio.Scanner
	stdin := os.stream_from_handle(os.stdin)
	bufio.scanner_init(&scanner, stdin, context.temp_allocator)

	p1: u128
	p2: u128

	log.info("running puzzle")

	vectors: [dynamic]linalg.Vector2f64
	defer delete(vectors)

	for {
		if !bufio.scanner_scan(&scanner) {
			break
		}
		line := bufio.scanner_text(&scanner)
		append_elem(&vectors, parse_vector(line))
	}

	if err := bufio.scanner_error(&scanner); err != nil {
		fmt.eprintln("error scanning input: %v", err)
	}

	distances: [dynamic]u128
	defer delete(distances)

	for i := 0; i < len(vectors); i += 1 {
		for w in vectors[i + 1:] {
			v := w - vectors[i]
			log.debug(v, rectangle_size(v), linalg.length(v))
			append(&distances, rectangle_size(v))
		}
	}

	slice.sort_by(distances[:], proc(a, b: u128) -> bool {
		return a < b
	})

	log.debug(distances)

	p1 = distances[len(distances) - 1]

	fmt.printf("puzzle 1 = %d\n", p1)
	fmt.printf("puzzle 2 = %d\n", p2)

	free_all(context.temp_allocator)
}
