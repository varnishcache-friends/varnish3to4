#!/bin/sh

status=0
for test in $(echo tests/*.test); do
	output=$(echo $test | sed 's/\.test/\.out/')
	expect=$(echo $test | sed 's/\.test/\.exp/')
	python varnish3to4 $test -o $output
	cmp -s $output $expect
	retval=$?
	[ $retval -ne 0 ] && status=$retval
done
exit $status
