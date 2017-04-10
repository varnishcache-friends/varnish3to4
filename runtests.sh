#!/bin/sh

status=0
for test in $(echo tests/*.test); do
	output=${test/.test/.out}
	python varnish3to4 $test -o $output
	cmp -s $output ${test/.test/.exp}
	retval=$?
	[ $retval -ne 0 ] && status=$retval
done
exit $status
