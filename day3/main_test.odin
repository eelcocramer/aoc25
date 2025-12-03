package main

import "core:testing"

@(test)
high_jolt_test :: proc(t: ^testing.T) {
	jolt := highest_jolt("987654321111111", 2)
	testing.expect(t, jolt == "98", "did not find 98")

	jolt = highest_jolt("811111111111119", 2)
	testing.expect(t, jolt == "89", "did not find 89")

	jolt = highest_jolt("234234234234278", 2)
	testing.expect(t, jolt == "78", "did not find 78")

	jolt = highest_jolt("818181911112111", 2)
	testing.expect(t, jolt == "92", "did not find 92")

	jolt = highest_jolt("987654321111111", 12)
	testing.expect(t, jolt == "987654321111", "did not find 987654321111")

	jolt = highest_jolt("811111111111119", 12)
	testing.expect(t, jolt == "811111111119", "did not find 811111111119")

	jolt = highest_jolt("234234234234278", 12)
	testing.expect(t, jolt == "434234234278", "did not find 434234234278")

	jolt = highest_jolt("818181911112111", 12)
	testing.expect(t, jolt == "888911112111", "did not find 888911112111")
}
