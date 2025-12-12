#+feature dynamic-literals
package main

import "core:bufio"
import "core:fmt"
import "core:log"
import "core:os"
import "core:slice"
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

solve2 :: proc(
	key, target: string,
	visited: []string,
	paths: ^map[string][]string,
	cache: ^map[string]i128,
) -> (
	sol: i128,
) {
	log.debug("key:", key, "visited:", visited, "paths[key]:", paths[key])

	//good := slice.contains(visited, "dac") && slice.contains(visited, "fft")

	if key == target {
		//log.debug("dac:", slice.contains(visited, "dac"), "fft:", slice.contains(visited, "fft"))
		//if good {
		return 1
		//} else {
		//	return 0
		//}
	}

	if s, ok := cache[key]; ok {
		return s
	}

	v := slice.clone_to_dynamic(visited)
	append_elem(&v, key)
	for k in paths[key] {
		if !slice.contains(v[:], k) {
			sol += solve2(k, target, v[:], paths, cache)
		}
	}
	delete(v)
	cache[key] = sol
	return sol
}

solve1 :: proc(key: string, visited: []string, paths: ^map[string][]string) -> (sol: i128) {
	if key == "out" {
		return 1
	}

	v := slice.clone_to_dynamic(visited)
	append_elem(&v, key)
	for k in paths[key] {
		if !slice.contains(v[:], k) {
			sol += solve1(k, v[:], paths)
		}
	}
	delete(v)
	return sol
}

main :: proc() {
	context.logger = log.create_console_logger()
	context.logger.lowest_level = get_log_level()
	scanner: bufio.Scanner
	stdin := os.stream_from_handle(os.stdin)
	bufio.scanner_init(&scanner, stdin, context.temp_allocator)

	log.info("running puzzle")

	paths: map[string][]string
	defer delete(paths)

	for {
		if !bufio.scanner_scan(&scanner) {
			break
		}
		line := bufio.scanner_text(&scanner)

		tokens, _ := strings.split(line, " ")
		outputs: [dynamic]string
		for s in tokens[1:] {
			append_elem(&outputs, strings.clone(s))
		}
		paths[strings.clone(tokens[0][0:3])] = slice.clone(outputs[:])
		delete(outputs)
	}

	if err := bufio.scanner_error(&scanner); err != nil {
		fmt.eprintln("error scanning input: %v", err)
	}


	log.debug(paths)

	cache: map[string]i128
	sol2 := solve2("svr", "fft", []string{}, &paths, &cache)
	if sol2 == 0 {
		clear_map(&cache)
		sol2 = solve2("svr", "dac", []string{}, &paths, &cache)
		clear_map(&cache)
		sol2 *= solve2("dac", "fft", []string{}, &paths, &cache)
		clear_map(&cache)
		sol2 *= solve2("fft", "out", []string{}, &paths, &cache)
	} else {
		clear_map(&cache)
		sol2 *= solve2("fft", "dac", []string{}, &paths, &cache)
		clear_map(&cache)
		sol2 *= solve2("dac", "out", []string{}, &paths, &cache)
	}

	fmt.printf("puzzle 1 = %d\n", solve1("you", []string{}, &paths))
	fmt.printf("puzzle 2 = %d\n", sol2)


	free_all(context.temp_allocator)
}
