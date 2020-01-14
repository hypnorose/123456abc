%start program
%union{
	char * sval;
	int ival;
}

%token ASSIGN IF THEN ELSE ENDIF 
%token FOR  TO DOWNTO  ENDFOR READ  WRITE  WHILE DO  ENDDO FROM
%token DECLARE END BGN
%token PLUS MINUS TIMES DIV MOD
%token EQ NEQ LE GE LEQ GEQ 
%token <ival> NUM
%token <sval> PIDENTIFIER 
%{
#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <cstdio>
#include <string.h>
#define YYDEBUG 1
#define MAXSIZE 1000

	struct cell{

		char * name;
	};

	struct cmd{
		char * oper;
		int arg;
	};
	cell memory[MAXSIZE];



	

	
	int code_offset=0;
	int data_offset = 0;
	void install(char * temps){
		printf("%s",temps);
		memory[data_offset].name = strdup(temps);
		data_offset++;
	}
	

	using namespace std;
	extern int yylex();
	extern int yyparse();
	
	extern FILE *yyin;

	void yyerror(const char *s);
%}

%%
program: 		DECLARE declarations BGN commands END {printf("asdsa");}
|		 		BGN commands END {printf("sdad");}
;

declarations:   declarations ',' PIDENTIFIER					{install($3);}
|				declarations ',' PIDENTIFIER '(' NUM ':' NUM ')'
|				PIDENTIFIER										{install($1);}
|				PIDENTIFIER '(' NUM ':' NUM ')'
;
commands:		commands command
|				command
;
command:		identifier ASSIGN expression ';'
|				IF condition THEN commands ELSE commands ENDIF
|				IF condition THEN commands ENDIF
|				WHILE condition DO commands ENDIF
| 				DO commands WHILE condition ENDDO
|				FOR PIDENTIFIER FROM value TO value DO commands ENDFOR
|				FOR PIDENTIFIER FROM value TO value DOWNTO value commands ENDFOR
|				READ identifier ';'
|				WRITE value  ';' {printf("writed");}
;
expression:		value
|				value "PLUS" value
|				value "MINUS" value
|				value "TIMES" value
|				value "DIV" value
|				value "MOD" value
;
condition:		value "EQ" value
|				value "NEQ" value
|				value "LE" value
|				value "GE" value
|				value "LEQ" value
|				value "GEQ" value
;
value:			NUM {printf("liczba");}
|				identifier
;
identifier:		PIDENTIFIER {printf("pidd");}
|				PIDENTIFIER'('PIDENTIFIER')'
|				PIDENTIFIER'('NUM')'
;
%%

int main( int argc, char *argv[] ){ 
	FILE *yyin;
	//yyin = fopen( argv[0], "r" );
	yyparse();
}
void yyerror (const char *s) 
{
	printf ("Error: %s\n", s);

}
