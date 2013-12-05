test:
	rspec spec.rb
	./kata.rb < test/numbers | diff test/output -

.PHONY: test
