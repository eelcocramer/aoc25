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

Box :: struct {
	id:       int,
	position: linalg.Vector3f64,
}

parse_box :: proc(line: ^string, id: int) -> (b: Box) {
	log.debug("parsing box", "line:", line)

	count := 0
	for str in strings.split_iterator(line, ",") {
		b.position[count], _ = strconv.parse_f64(str)
		count += 1
	}

	b.id = id
	return
}

Distance :: struct {
	a:      ^Box,
	b:      ^Box,
	length: f64,
}

distance :: proc(a, b: ^Box) -> Distance {
	return Distance{a = a, b = b, length = linalg.length(a.position - b.position)}
}

compare_distances :: proc(i, j: Distance) -> bool {
	return i.length < j.length
}

add_connection :: proc(
	d: Distance,
	seen: ^[dynamic]^Box,
	circuits: ^[dynamic][dynamic]^Box,
) -> u128 {
	add: int
	if !slice.contains(seen[:], d.a) {
		append_elem(seen, d.a)
		add += 1
	}
	if !slice.contains(seen[:], d.b) {
		append_elem(seen, d.b)
		add += 1
	}

	if add == 2 {
		append_elem(circuits, [dynamic]^Box{d.a, d.b})
	} else {
		a, b: int = -1, -1
		for i := 0; i < len(circuits); i += 1 {
			if slice.contains(circuits[i][:], d.a) && slice.contains(circuits[i][:], d.b) {
				return 0
			} else if slice.contains(circuits[i][:], d.a) {
				a = i
			} else if slice.contains(circuits[i][:], d.b) {
				b = i
			}
		}

		if a == -1 {
			append_elem(&circuits[b], d.a)
		} else if b == -1 {
			append_elem(&circuits[a], d.b)
		} else {
			for box in circuits[b] {
				append_elem(&circuits[a], box)
			}
			unordered_remove(circuits, b)
		}
	}

	if len(circuits) == 1 {
		return u128(d.a.position[0] * d.b.position[0])
	}

	return 0
}

solve_p2 :: proc(boxes: [dynamic]Box, distances: [dynamic]Distance) -> u128 {
	circuits: [dynamic][dynamic]^Box
	defer delete(circuits)

	seen: [dynamic]^Box
	defer delete(seen)

	for d in distances {
		res := add_connection(d, &seen, &circuits)
		log.debug("d:", d, "res:", res, "len(seen)", len(seen))
		if res != 0 && len(seen) == len(boxes) {
			return res
		}
	}
	return 0
}

solve_p1 :: proc(distances: [dynamic]Distance) -> u128 {
	groups: [dynamic][dynamic]int
	defer delete(groups)

	for i := 0; i < PAIRS; i += 1 {
		append_elem(&groups, [dynamic]int{distances[i].a.id, distances[i].b.id})
	}

	groups_merged: [dynamic][dynamic]int
	defer delete(groups_merged)
	for len(groups) > 0 {
		first := slice.clone_to_dynamic(groups[0][:])
		rest := slice.clone_to_dynamic(groups[1:])

		lf := -1
		for len(first) > lf {
			lf = len(first)

			rest_tmp: [dynamic][dynamic]int
			for r in rest {
				tmp := slice.clone_to_dynamic(first[:])
				for i in r {
					if !slice.contains(tmp[:], i) {
						append_elem(&tmp, i)
					}
				}
				log.debug("tmp:", slice.unique(tmp[:]), "first:", first, "r:", r)
				if len(tmp) < len(first) + len(r) {
					first = slice.clone_to_dynamic(tmp[:])
				} else {
					append_elem(&rest_tmp, r)
				}
			}

			rest = rest_tmp
		}

		append_elem(&groups_merged, first)
		groups = rest
	}

	slice.sort_by(groups_merged[:], proc(a, b: [dynamic]int) -> bool {
		return len(a) > len(b)
	})

	log.debug("merged:", groups_merged)

	sol := u128(1)
	for i := 0; i < 3; i += 1 {
		sol *= u128(len(groups_merged[i]))
	}

	return sol
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

	boxes: [dynamic]Box
	defer delete(boxes)

	distances: [dynamic]Distance
	defer delete(distances)

	id := 0
	for {
		if !bufio.scanner_scan(&scanner) {
			break
		}
		line := bufio.scanner_text(&scanner)
		box := parse_box(&line, id)
		append_elem(&boxes, box)
		id += 1
	}

	if err := bufio.scanner_error(&scanner); err != nil {
		fmt.eprintln("error scanning input: %v", err)
	}

	for i := 0; i < len(boxes) - 1; i += 1 {
		for j := i + 1; j < len(boxes); j += 1 {
			append_elem(&distances, distance(&boxes[i], &boxes[j]))
		}
	}

	slice.sort_by(distances[:], compare_distances)

	p1 = solve_p1(distances)
	p2 = solve_p2(boxes, distances)

	fmt.printf("puzzle 1 = %d\n", p1)
	fmt.printf("puzzle 2 = %d\n", p2)

	free_all(context.temp_allocator)
}
