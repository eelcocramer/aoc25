package main

import "core:bufio"
import "core:bytes"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strconv"

is_roll :: proc(diagram: ^[dynamic][]byte, x, y: int) -> bool {
	if x < 0 || x >= len(diagram) {
		return false
	}

	if y < 0 || y >= len(diagram[x]) {
		return false
	}

	if diagram[x][y] == '.' {
		return false
	}

	return true
}

candidate :: proc(diagram: ^[dynamic][]byte, max, x, y: int) -> bool {
	count: int

	if diagram[x][y] == '.' {
		return false
	}

	if is_roll(diagram, x, y - 1) {
		count += 1
	}
	if is_roll(diagram, x, y + 1) {
		count += 1
	}
	if is_roll(diagram, x - 1, y - 1) {
		count += 1
	}
	if is_roll(diagram, x - 1, y) {
		count += 1
	}
	if is_roll(diagram, x - 1, y + 1) {
		count += 1
	}
	if is_roll(diagram, x + 1, y - 1) {
		count += 1
	}
	if is_roll(diagram, x + 1, y) {
		count += 1
	}
	if is_roll(diagram, x + 1, y + 1) {
		count += 1
	}

	return count < max
}

solve :: proc(diagram: ^[dynamic][]byte, max: int) -> (solution: u128) {
	for x := 0; x < len(diagram); x += 1 {
		for y := 0; y < len(diagram[x]); y += 1 {
			if candidate(diagram, max, x, y) {
				diagram[x][y] = 'X'
				solution += 1
			}
		}
	}
	return
}

clean :: proc(diagram: ^[dynamic][]byte) {
	for x := 0; x < len(diagram); x += 1 {
		for y := 0; y < len(diagram[x]); y += 1 {
			if diagram[x][y] == 'X' {
				diagram[x][y] = '.'
			}
		}
	}
}

main :: proc() {
	scanner: bufio.Scanner
	stdin := os.stream_from_handle(os.stdin)
	bufio.scanner_init(&scanner, stdin, context.temp_allocator)

	p1: u128
	p2: u128

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

	p1 = solve(&diagram, 4)

	for {
		sol := solve(&diagram, 4)
		p2 += sol
		if sol == 0 {
			break
		}
		clean(&diagram)
	}

	fmt.printf("puzzle 1 = %d\n", p1)
	fmt.printf("puzzle 2 = %d\n", p2)

	free_all(context.temp_allocator)
}
