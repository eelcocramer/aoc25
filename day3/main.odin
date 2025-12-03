package main

import "core:bufio"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strconv"

/*
highest_jolt :: proc(bank: string) -> (jolt: int) {
	first, second: u8
	high_pos: int

	log.info("bank:", bank)

	for pos := 0; pos < len(bank) - 1; pos += 1 {
		if bank[pos] > first {
			first = bank[pos]
			high_pos = pos
		}
	}

	log.info("first:", first)

	for pos := high_pos + 1; pos < len(bank); pos += 1 {
		if bank[pos] > second {
			second = bank[pos]
		}
	}

	log.info("second:", second)

	jolt_str := fmt.aprintf("%c%c", first, second)
	jolt, _ = strconv.parse_int(jolt_str)


	log.info("str:", jolt_str, "jolt:", jolt)

	return
}
*/

highest_jolt :: proc(bank: string, batteries: int) -> string {
	high: u8

	log.info("batteries:", batteries, "bank:", bank)

	if batteries == 1 {
		for i := 0; i < len(bank); i += 1 {
			if bank[i] > high {
				high = bank[i]
			}
		}

		return fmt.aprintf("%c", high)
	}

	pos: int
	for i := 0; i < len(bank) - batteries + 1; i += 1 {
		log.info("i:", i, "b:", bank[i], "high:", high)
		if bank[i] > high {
			high = bank[i]
			pos = i
		}
	}

	jolt := fmt.aprintf("%c%s", high, highest_jolt(bank[pos + 1:], batteries - 1))
	log.info("jolt:", jolt)
	return jolt
}

main :: proc() {
	scanner: bufio.Scanner
	stdin := os.stream_from_handle(os.stdin)
	bufio.scanner_init(&scanner, stdin, context.temp_allocator)

	p1: int
	p2: u128

	for {
		if !bufio.scanner_scan(&scanner) {
			break
		}
		bank := bufio.scanner_text(&scanner)

		high, _ := strconv.parse_int(highest_jolt(bank, 2))
		p1 += high

		high_u128, _ := strconv.parse_u128(highest_jolt(bank, 12))
		p2 += high_u128
	}

	if err := bufio.scanner_error(&scanner); err != nil {
		fmt.eprintln("error scanning input: %v", err)
	}

	fmt.printf("puzzle 1 = %d\n", p1)
	fmt.printf("puzzle 2 = %d\n", p2)

	free_all(context.temp_allocator)
}
