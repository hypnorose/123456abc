
parser.tab.c parser.tab.h: parser.y
	bison -d parser.y
lex.yy.c: parser.lex parser.tab.h
	flex parser.lex
parser: lex.yy.c parser.tab.c parser.tab.h
	g++ parser.tab.c lex.yy.c -o compiler.exe
