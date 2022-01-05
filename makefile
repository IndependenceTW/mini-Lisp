all: bind
	#clear

bind: compile_bison compile_flex
	gcc -o lisp lisp.tab.o lex.yy.o -ll
	
compile_bison:
	bison -d ./src/lisp.y
	gcc -c lisp.tab.c

compile_flex:
	flex ./src/lisp.l
	gcc -c ./lex.yy.c

clean:
	@rm ./*.c
	@rm ./*.h
	@rm ./*.o
	clear
