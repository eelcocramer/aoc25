package main

import "core:bufio"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strconv"
import "core:strings"

match :: proc(s, sub: string) -> bool {
	log.info("a:", s[:len(sub)], "b:", sub)
	if strings.compare(s[:len(sub)], sub) != 0 {
		log.info("ret2 false")
		return false
	}
	if len(s) == len(sub) {
		log.info("ret2 true")
		return true
	}
	if len(s[len(sub):]) < len(sub) {
		log.info("ret3 false")
		return false
	}
	return match(s[len(sub):], sub)
}

check :: proc(s: string, i: int) -> bool {
	if i > len(s) / 2 {
		return true
	}
	if match(s[i:], s[0:i]) {
		return false
	}
	return check(s, i + 1)
}

part2 :: proc(num: u64) -> bool {
	s := fmt.aprintf("%d", num)
	log.info("num:", s)

	return check(s, 1)

	/*
	for i := 1; i <= len(s) / 2 && len(s) % i == 0; i += 1 {
		log.info("s[i:]", s[i:], "s[0:i]", s[0:i])
		if (!match(s[i:], s[0:i])) {
			log.info("match")
			return true
		}
	}

	return false
	*/
}

part1 :: proc(num: u64) -> bool {
	s := fmt.aprintf("%d", num)

	if len(s) % 2 != 1 {
		m := len(s) / 2
		a := strings.cut(s, 0, m)
		b := strings.cut(s, m)
		if strings.compare(a, b) == 0 {
			return false
		}
	}

	return true
}

inspect :: proc(range: string, valid: proc(_: u64) -> bool) -> (res: u64) {
	first, _, last := strings.partition(range, "-")
	f, _ := strconv.parse_u64(first)
	l, _ := strconv.parse_u64(last)

	for ; f <= l; f += 1 {
		if !valid(f) {
			res += f
		}
	}

	return res
}

main :: proc() {
	scanner: bufio.Scanner
	stdin := os.stream_from_handle(os.stdin)
	bufio.scanner_init(&scanner, stdin, context.temp_allocator)

	sol1, sol2: u64

	for {
		if !bufio.scanner_scan(&scanner) {
			break
		}
		line := bufio.scanner_text(&scanner)

		ranges := strings.split(line, ",")
		for r in ranges {
			sol := inspect(r, part1)
			sol1 += sol

			sol = inspect(r, part2)
			sol2 += sol
		}
	}

	if err := bufio.scanner_error(&scanner); err != nil {
		fmt.eprintln("error scanning input: %v", err)
	}

	fmt.printf("solution 1 = %d\n", sol1)
	fmt.printf("solution 2 = %d\n", sol2)

	free_all(context.temp_allocator)
}
