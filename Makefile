.PHONY: test deps

test_app:
	./rebar compile
deps:
	./rebar get-deps
test:
	./rebar eunit skip_deps=true

