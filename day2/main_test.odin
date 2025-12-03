package main

import "core:testing"

@(test)
part1_test :: proc(t: ^testing.T) {
	ok := part1(0)
	testing.expect(t, ok, "0 is a valid number")

	ok = part1(10)
	testing.expect(t, ok, "10 is a valid number")

	ok = part1(11)
	testing.expect(t, !ok, "11 is an invalid number")

	ok = part1(1212)
	testing.expect(t, !ok, "1212 is an invalid number")

	ok = part1(101)
	testing.expect(t, ok, "101 is an valid number")

	ok = part1(1001)
	testing.expect(t, ok, "1001 is an valid number")
}

@(test)
part2_test :: proc(t: ^testing.T) {
	ok := part2(0)
	testing.expect(t, ok, "0 is a valid number")

	ok = part2(10)
	testing.expect(t, ok, "10 is a valid number")

	ok = part2(11)
	testing.expect(t, !ok, "11 is an invalid number")

	ok = part2(111)
	testing.expect(t, !ok, "111 is an invalid number")

	ok = part2(1212)
	testing.expect(t, !ok, "1212 is an invalid number")

	ok = part2(101)
	testing.expect(t, ok, "101 is a valid number")

	ok = part2(1001)
	testing.expect(t, ok, "1001 is a valid number")

	ok = part2(121212)
	testing.expect(t, !ok, "121212 is an invalid number")

	ok = part2(1188511885)
	testing.expect(t, !ok, "1188511885 is an invalid number")

	ok = part2(2121212118)
	testing.expect(t, ok, "2121212118 is a valid number")
}
