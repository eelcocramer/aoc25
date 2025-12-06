package main

import "core:bufio"
import "core:fmt"
import "core:log"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

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

main :: proc() {
	context.logger = log.create_console_logger()
	context.logger.lowest_level = get_log_level()
	scanner: bufio.Scanner
	stdin := os.stream_from_handle(os.stdin)
	bufio.scanner_init(&scanner, stdin, context.temp_allocator)

	p1: u128
	p2: u128

	log.info("running puzzle")

	proc_ranges := true

	worksheet: [dynamic][dynamic]u128
	defer delete(worksheet)

	operators: [dynamic]u8
	defer delete(operators)

	for {
		if !bufio.scanner_scan(&scanner) {
			break
		}
		line := bufio.scanner_text(&scanner)

		if line[0] == '*' || line[0] == '+' {
			for str in strings.split_iterator(&line, " ") {
				if len(str) == 0 {
					continue
				}
				append_elem(&operators, str[0])
			}
		} else {
			nums: [dynamic]u128
			for str in strings.split_iterator(&line, " ") {
				if len(str) == 0 {
					continue
				}
				num, _ := strconv.parse_u128(str)
				append_elem(&nums, num)
			}
			append_elem(&worksheet, nums)
		}
	}

	if err := bufio.scanner_error(&scanner); err != nil {
		fmt.eprintln("error scanning input: %v", err)
	}

	log.debug("worksheet:", worksheet)
	log.debug("operators:", operators)

	for i := 0; i < len(worksheet[0]); i += 1 {
		sum := worksheet[0][i]
		for j := 1; j < len(worksheet); j += 1 {
			log.debug("val:", worksheet[j][i])
			if operators[i] == '+' {
				log.debug("+")
				sum += worksheet[j][i]
			} else {
				log.debug("*")
				sum *= worksheet[j][i]
			}
		}
		log.debug("sum:", sum)
		p1 += sum
	}

	fmt.printf("puzzle 1 = %d\n", p1)
	fmt.printf("puzzle 2 = %d\n", p2)

	free_all(context.temp_allocator)
}
