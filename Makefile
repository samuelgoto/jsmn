# You can put your build options here
-include config.mk

all: libjsmn.a 

libjsmn.a: jsmn.o
	$(AR) rc $@ $^

%.o: %.c jsmn.h
	$(CC) -c $(CFLAGS) $< -o $@

test: test_default test_strict test_links test_strict_links
test_default: test/tests.c
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o test/$@
	./test/$@
test_strict: test/tests.c
	$(CC) -DJSMN_STRICT=1 $(CFLAGS) $(LDFLAGS) $< -o test/$@
	./test/$@
test_links: test/tests.c
	$(CC) -DJSMN_PARENT_LINKS=1 $(CFLAGS) $(LDFLAGS) $< -o test/$@
	./test/$@
test_strict_links: test/tests.c
	$(CC) -DJSMN_STRICT=1 -DJSMN_PARENT_LINKS=1 $(CFLAGS) $(LDFLAGS) $< -o test/$@
	./test/$@

jsmn_test.o: jsmn_test.c libjsmn.a

docscript: docscript/docscript.o libjsmn.a
	$(CC) $(LDFLAGS) $^ -o docscript/docscript

# emrun --no_browser --port 8080 .
# http://localhost:8080/docscript/docscript.html
web:
	emcc jsmn.c docscript/docscript.c -O3 -s WASM=1 -o docscript/docscript.html -s NO_EXIT_RUNTIME=1 --emrun

simple_example: example/simple.o libjsmn.a
	$(CC) $(LDFLAGS) $^ -o $@

jsondump: example/jsondump.o libjsmn.a
	$(CC) $(LDFLAGS) $^ -o $@

clean:
	rm -f *.o example/*.o
	rm -f *.a *.so *.wasm *.js
	rm -f docscript/*.js docscript/*.wasm docscript/*.html docscript/*.o docscript/docscript
	rm -f simple_example
	rm -f jsondump
	rm -f test/test_default
	rm -f test/test_links
	rm -f test/test_strict
	rm -f test/test_strict_links

.PHONY: all clean test

