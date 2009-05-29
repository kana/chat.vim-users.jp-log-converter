# Requirements: GNU make

all: test
.PHONY: accept-test-result all test
.DELETE_ON_ERROR:

test: test-converter.ok

test-converter.ok: test-converter.expected test-converter.output
	diff -u $^
	touch $@

test-converter.output: converter_spec.rb converter.rb
	spec $< | grep -v 'Finished in' >$@

accept-test-result:
	cp test-converter.output test-converter.expected

# __END__
