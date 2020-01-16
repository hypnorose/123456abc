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
%type <ival> identifier

%left PLUS MINUS
%left TIMES DIV MOD

%{
#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <cstdio>
#include <string.h>
#undef YYDEBUG
#define YYDEBUG 0
#define EAX 0  // rejestr na który działaja operacje sub add itp
#define EBX 1
#define ECX 2
#define EDX 3
#define ESI 4
#define EDI 5
#define ONE 6

#define ESP 11
#define EBP 100
#define STACK_OVERFLOW 300
#define DATA_START 301

void yyerror(const char *s);
	int ebp = 100;
	int esp = ebp;
		
	struct cell {
		int address;
		char * name;
	};
	struct cmd{
		char * oper;
		int arg;
	};
	cell memory[999];
	cmd output[999];
	int output_offset=0;
	int data_offset = 0;



	void gen_code(const char * code,int arg){
		printf("%s %d\n",code,arg);
		output[output_offset].oper = strdup(code);
		output[output_offset++].arg = arg;
	}

	void gen_code(const char * code){
		printf("%s\n",code);
		output[output_offset++].oper = strdup(code);
	}
	void numberToP0(int number){
		gen_code("SUB",EAX);
		if(number > 0)
			gen_code("INC");
		else if (number < 0){
			number=-number;
			gen_code("DEC");
		}

		bool opers[100];// 0 - (+1); 1 - (*2)
		int oper_number = 0;
			while(number>1){
				if(number%2==0){
					opers[oper_number++]=1;
					number/=2;
				}
				else {
					opers[oper_number++]=0;
					number--;
				}
		}
		for(int i=oper_number-1;i>=0;i--){
			if(opers[i]==0){
				gen_code("INC");
			}
			else gen_code("SHIFT", ONE);
		}
	}
	void push_number(int number){
		gen_code("LOAD",ESP);
		gen_code("INC");
		gen_code("STORE",ESP);
	
		
		numberToP0(number);
		// teraz w p0 jest number
		gen_code("STOREI",ESP);

	}


	int findVar(char * var_name){
		for(int i=0;i<data_offset;i++){
			if(strcmp(var_name,memory[i].name)==0)return memory[i].address;
		}
		yyerror("Variable not found");
		return -1;
	}
	void assign(int var_addr){
		gen_code("LOADI",ESP);
		gen_code("STORE",var_addr);

	}
	void pop(char * var_name){

	}

	void setup(){
		gen_code("SUB",EAX);
		gen_code("INC");
		gen_code("STORE",ONE);
		numberToP0(EBP);
		gen_code("STORE",ESP);

	}
	


	

	
	
	void make_variable(char * temps){
		printf("%s",temps);
		memory[data_offset].name = strdup(temps);
		memory[data_offset].address = data_offset+DATA_START;
		data_offset++;
	}
	

	using namespace std;
	extern int yylex();
	extern int yyparse();
	
	extern FILE *yyin;

	
%}

%%
program: 		DECLARE declarations BGN commands END {printf("\nkoniecprogramu\n");}
|		 		BGN commands END {printf("\nkoniecprogramu\n");}
;

declarations:   declarations ',' PIDENTIFIER					{make_variable($3);}
|				declarations ',' PIDENTIFIER '(' NUM ':' NUM ')'
|				PIDENTIFIER										{make_variable($1);}
|				PIDENTIFIER '(' NUM ':' NUM ')'
;
commands:		commands command
|				command
;
command:		identifier ASSIGN expression ';'			{assign($1);}
|				IF condition THEN commands ELSE commands ENDIF
|				IF condition THEN commands ENDIF
|				WHILE condition DO commands ENDIF
| 				DO commands WHILE condition ENDDO
|				FOR PIDENTIFIER FROM value TO value DO commands ENDFOR
|				FOR PIDENTIFIER FROM value TO value DOWNTO value commands ENDFOR
|				READ identifier ';'
|				WRITE value  ';' {printf("xxx");}
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
value:			NUM 							{push_number(yylval.ival);}
|				identifier
;
identifier:		PIDENTIFIER 					{$$ = findVar($1);}
|				PIDENTIFIER'('PIDENTIFIER')'	{$$ = 0;}
|				PIDENTIFIER'('NUM')'			{$$ = 0;}
;
%%

int main( int argc, char *argv[] ){ 
	FILE *yyin;
	//yyin = fopen( argv[0], "r" );
	setup();
	yyparse();
}
void yyerror (const char *s) 
{
	printf ("Error: %s\n", s);

}
