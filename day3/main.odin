package main

import "core:bufio"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strconv"

highest_jolt :: proc(bank: string, batteries: int, allocator := context.temp_allocator) -> string {
	high: u8

	log.debug("batteries:", batteries, "bank:", bank)

	if batteries == 1 {
		for i := 0; i < len(bank); i += 1 {
			if bank[i] > high {
				high = bank[i]
			}
		}

		return fmt.aprintf("%c", high, allocator = allocator)
	}

	pos: int
	for i := 0; i < len(bank) - batteries + 1; i += 1 {
		log.debug("i:", i, "b:", bank[i], "high:", high)
		if bank[i] > high {
			high = bank[i]
			pos = i
		}
	}

	hj := highest_jolt(bank[pos + 1:], batteries - 1)
	jolt := fmt.aprintf("%c%s", high, hj, allocator = allocator)
	log.debug("jolt:", jolt)

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

		h := highest_jolt(bank, 2)
		high, _ := strconv.parse_int(h)
		p1 += high

		h = highest_jolt(bank, 12)
		high_u128, _ := strconv.parse_u128(h)
		p2 += high_u128
	}

	if err := bufio.scanner_error(&scanner); err != nil {
		fmt.eprintln("error scanning input: %v", err)
	}

	fmt.printf("puzzle 1 = %d\n", p1)
	fmt.printf("puzzle 2 = %d\n", p2)

	free_all(context.temp_allocator)
}
