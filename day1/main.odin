package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:strconv"

handle_puzzle2 :: proc(cmd: string, dial: int) -> (cur: int, zeros: int) {
	cur = dial
	dir := 1
	if cmd[0] == 'L' {
		dir = -1
	}

	n, _ := strconv.parse_int(cmd[1:])
	zeros = n / 100

	n = n % 100
	n *= dir
	cur += n

	if cur > 99 {
		if dial != 0 {
			zeros += 1
		}
		cur -= 100
	} else if cur < 0 {
		if dial != 0 {
			zeros += 1
		}
		cur += 100
	} else if cur == 0 && dial != 0 {
		zeros += 1
	}

	return cur, zeros
}

handle_puzzle1 :: proc(cmd: string, dial: int) -> int {
	cur := dial
	dir := 1
	if cmd[0] == 'L' {
		dir = -1
	}

	n, _ := strconv.parse_int(cmd[1:])

	n = n % 100
	n *= dir
	cur += n

	if cur > 99 {
		cur -= 100
	} else if cur < 0 {
		cur += 100
	}

	return cur
}

main :: proc() {
	scanner: bufio.Scanner
	stdin := os.stream_from_handle(os.stdin)
	bufio.scanner_init(&scanner, stdin, context.temp_allocator)

	passwd_p1 := 0
	dial_p1 := 50

	passwd_p2 := 0
	dial_p2 := 50
	zeros_p2 := 0

	for {
		if !bufio.scanner_scan(&scanner) {
			break
		}
		line := bufio.scanner_text(&scanner)
		dial_p1 = handle_puzzle1(line, dial_p1)
		if dial_p1 == 0 {
			passwd_p1 += 1
		}

		dial_p2, zeros_p2 = handle_puzzle2(line, dial_p2)
		passwd_p2 += zeros_p2
	}

	if err := bufio.scanner_error(&scanner); err != nil {
		fmt.eprintln("error scanning input: %v", err)
	}

	fmt.printf("passwd p1 = %d\n", passwd_p1)
	fmt.printf("passwd p2 = %d\n", passwd_p2)

	free_all(context.temp_allocator)
}
