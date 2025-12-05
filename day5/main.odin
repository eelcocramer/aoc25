package main

import "core:bufio"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strconv"
import "core:strings"

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

Range :: struct {
	low:  u64,
	high: u64,
}

in_range :: proc(id: u64, r: Range) -> bool {
	return id >= r.low && id <= r.high
}

parse_range :: proc(line: string) -> (r: Range) {
	low, _, high := strings.partition(line, "-")
	r.low, _ = strconv.parse_u64(low)
	r.high, _ = strconv.parse_u64(high)
	return
}

main :: proc() {
	scanner: bufio.Scanner
	stdin := os.stream_from_handle(os.stdin)
	bufio.scanner_init(&scanner, stdin, context.temp_allocator)

	p1: u128
	p2: u128

	proc_ranges := true

	ranges: [dynamic]Range
	defer delete(ranges)

	available: [dynamic]u64
	defer delete(available)

	for {
		if !bufio.scanner_scan(&scanner) {
			break
		}
		line := bufio.scanner_text(&scanner)

		if line == "" {
			proc_ranges = false
		} else if proc_ranges {
			append_elem(&ranges, parse_range(line))
		} else {
			i, _ := strconv.parse_u64(line)
			append_elem(&available, i)
		}

	}

	if err := bufio.scanner_error(&scanner); err != nil {
		fmt.eprintln("error scanning input: %v", err)
	}

	for i in available {
		for r in ranges {
			if in_range(i, r) {
				p1 += 1
				break
			}
		}
	}

	fmt.printf("puzzle 1 = %d\n", p1)
	fmt.printf("puzzle 2 = %d\n", p2)

	free_all(context.temp_allocator)
}
