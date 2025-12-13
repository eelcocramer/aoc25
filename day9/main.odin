#+feature dynamic-literals
package main

import "core:bufio"
import "core:bytes"
import "core:fmt"
import "core:log"
import "core:math"
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
	y, _, x := strings.partition(line, ",")
	v.x, _ = strconv.parse_f64(x)
	v.y, _ = strconv.parse_f64(y)
	return
}

rectangle_size :: proc(v: linalg.Vector2f64) -> u128 {
	return u128((abs(v.x) + 1) * (abs(v.y) + 1))
}

Rectangle :: struct {
	a:    linalg.Vector2f64,
	b:    linalg.Vector2f64,
	size: u128,
}

outer_lines :: proc(vectors: [dynamic]linalg.Vector2f64) -> []Rectangle {
	rectangles: [dynamic]Rectangle
	defer delete(rectangles)

	y_by_x: map[f64][dynamic]f64
	defer delete(y_by_x)

	for v in vectors {
		if _, ok := y_by_x[v.x]; !ok {
			y_by_x[v.x] = make([dynamic]f64)
		}
		append_elem(&y_by_x[v.x], v.y)
	}

	min, max: f64
	for i := 0; i < len(vectors); i += 1 {
		v := vectors[i]

		yv := y_by_x[v.x]
		if len(yv) > 0 {
			min = yv[0]
			max = yv[len(yv) - 1]
		}

		append_elem(&rectangles, Rectangle{a = [2]f64{v.x, min}, b = [2]f64{v.x, max}})

		for j := i + 1; j < len(vectors); j += 1 {
			w := vectors[j]

			yw := y_by_x[w.x]
			for y in yw {
				if y == min {
					append_elem(&rectangles, Rectangle{a = [2]f64{v.x, min}, b = [2]f64{w.x, min}})
				}
				if y == max {
					append_elem(&rectangles, Rectangle{a = [2]f64{v.x, max}, b = [2]f64{w.x, min}})
				}
			}
		}
	}

	return slice.clone(rectangles[:])
}

solve :: proc(vectors: [dynamic]linalg.Vector2f64, check: bool) -> u128 {
	rectangles: [dynamic]Rectangle
	defer delete(rectangles)

	for i := 0; i < len(vectors); i += 1 {
		for w in vectors[i + 1:] {
			v := w - vectors[i]
			log.debug(v, rectangle_size(v), linalg.length(v))
			append(&rectangles, Rectangle{a = vectors[i], b = w, size = rectangle_size(v)})
		}
	}

	slice.sort_by(rectangles[:], proc(a, b: Rectangle) -> bool {
		return a.size > b.size
	})

	log.debug(rectangles)

	if !check {
		return rectangles[0].size
	}

	slice.sort_by(vectors[:], proc(a, b: linalg.Vector2f64) -> bool {
		return a.x < b.x
	})

	log.debug(vectors)

	for r in rectangles {
		if inbounds(r, vectors, lines) {
			log.debug("solution", r)
			return r.size
		}
	}

	return 0
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

	p1 = solve(vectors, false)
	p2 = solve(vectors, true)

	fmt.printf("puzzle 1 = %d\n", p1)
	fmt.printf("puzzle 2 = %d\n", p2)

	free_all(context.temp_allocator)
}
