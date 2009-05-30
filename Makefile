# Requirements: GNU make

all: test
.PHONY: accept-test-result all test
.DELETE_ON_ERROR:

test: test-converter.ok test-output.ok

test-converter.ok: test-converter.expected test-converter.output
	diff -u $^
	touch $@
test-converter.output: converter_spec.rb converter.rb
	spec $< | grep -v 'Finished in' >$@

test-output.ok: test-output.html
	htmllint -accessibility -religious -d mailto-link,navigation-link \
	         -w verbose test-output.html
	touch $@
test-output.html: converter.rb test-log.txt
	ruby converter.rb 2009-05-30 <test-log.txt >test-output.html

accept-test-result:
	cp test-converter.output test-converter.expected

# __END__
