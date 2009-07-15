all: lepsuc

lex.yy.c: lepsuc.lex
	flex lepsuc.lex

y.tab.c: lepsuc.y
	yacc lepsuc.y

lepsuc: lex.yy.c y.tab.c
	g++ -o lepsuc y.tab.c -lfl

clean: 
	rm y.tab.c
	rm lex.yy.c
