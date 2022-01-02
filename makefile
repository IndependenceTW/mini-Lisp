all: compile


compile: l_to_c
	gcc -o lisp ./src/lisp.yy.c -lfl

l_to_c:
	flex -o ./src/lisp.yy.c ./src/lisp.l

clean:
	@rm ./src/*.yy.c
