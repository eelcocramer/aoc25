#+feature dynamic-literals
package main

import "core:bufio"
import "core:bytes"
import "core:fmt"
import "core:log"
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

Machine :: struct {
	target:  []rune,
	wirings: [][]int,
}

parse_wiring :: proc(w: string) -> []int {
	wiring: [dynamic]int
	defer delete(wiring)

	tokens := strings.split(w[1:len(w) - 1], ",")

	for t in tokens {
		w, _ := strconv.parse_int(t)
		append_elem(&wiring, w)
	}

	return slice.clone(wiring[:])
}

press :: proc(states: [][]rune, m: Machine) -> [][]rune {
	post: [dynamic][]rune
	defer delete(post)

	for s in states {
		for wiring in m.wirings {
			c := slice.clone_to_dynamic(s)
			for i in wiring {
				if c[i] == '.' {
					c[i] = '#'
				} else {
					c[i] = '.'
				}
			}
			append_elem(&post, slice.clone(c[:]))
		}
	}

	return slice.clone(post[:])
}

main :: proc() {
	context.logger = log.create_console_logger()
	context.logger.lowest_level = get_log_level()
	scanner: bufio.Scanner
	stdin := os.stream_from_handle(os.stdin)
	bufio.scanner_init(&scanner, stdin, context.temp_allocator)

	log.info("running puzzle")

	machines: [dynamic]Machine
	defer delete(machines)

	for {
		if !bufio.scanner_scan(&scanner) {
			break
		}
		line := bufio.scanner_text(&scanner)

		tokens, _ := strings.split(line, " ")
		wirings: [dynamic][]int

		for t in tokens[1:len(tokens) - 1] {
			append_elem(&wirings, parse_wiring(t))
		}

		buf: [dynamic]rune
		for c in tokens[0][1:len(tokens[0]) - 1] {
			append_elem(&buf, c)
		}

		m := Machine {
			target  = slice.clone(buf[:]),
			wirings = slice.clone(wirings[:]),
		}

		delete(wirings)
		delete(buf)
		append_elem(&machines, m)

	}

	if err := bufio.scanner_error(&scanner); err != nil {
		fmt.eprintln("error scanning input: %v", err)
	}

	sol1, sol2: i128

	for m in machines {
		start: [dynamic]rune
		for _ in m.target {
			append_elem(&start, '.')
		}

		next := [][]rune{start[:]}
		found: bool = false
		for i: i128 = 1; !found; i += 1 {
			next = press(next, m)
			for n in next {
				if slice.equal(n, m.target) {
					found = true
					sol1 += i
					break
				}
			}

		}
		delete(start)
	}

	fmt.printf("puzzle 1 = %d\n", sol1)
	fmt.printf("puzzle 2 = %d\n", sol2)


	free_all(context.temp_allocator)
}
