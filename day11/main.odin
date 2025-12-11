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

Output :: struct {
	id:  string,
	sol: i128,
}

solve1 :: proc(key: string, paths: ^map[string][]Output) -> (sol: i128) {
	for &o in paths[key] {
		log.debug(o)
		if o.sol < 0 {
			if o.id == "out" {
				o.sol = 1
			} else {
				o.sol = solve1(o.id, paths)
			}
		}
		sol += o.sol
	}
	return sol
}

main :: proc() {
	context.logger = log.create_console_logger()
	context.logger.lowest_level = get_log_level()
	scanner: bufio.Scanner
	stdin := os.stream_from_handle(os.stdin)
	bufio.scanner_init(&scanner, stdin, context.temp_allocator)

	p2: u128

	log.info("running puzzle")

	paths: map[string][]Output
	defer delete(paths)

	for {
		if !bufio.scanner_scan(&scanner) {
			break
		}
		line := bufio.scanner_text(&scanner)

		tokens, _ := strings.split(line, " ")
		outputs: [dynamic]Output
		for s in tokens[1:] {
			append_elem(&outputs, Output{id = strings.clone(s), sol = -1})
		}
		paths[strings.clone(tokens[0][0:3])] = slice.clone(outputs[:])
		delete(outputs)
	}

	if err := bufio.scanner_error(&scanner); err != nil {
		fmt.eprintln("error scanning input: %v", err)
	}

	for k, _ in paths {
		log.debug(k)
	}

	fmt.printf("puzzle 1 = %d\n", solve1("you", &paths))
	fmt.printf("puzzle 2 = %d\n", p2)

	free_all(context.temp_allocator)
}
