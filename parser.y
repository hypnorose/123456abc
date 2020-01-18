%start program

%union{
	char * sval;
	int ival;
	struct jmp_info * jval;
}

%token ASSIGN IF THEN ELSE ENDIF 
%token FOR  TO DOWNTO  ENDFOR READ  WRITE  WHILE DO ENDWHILE ENDDO FROM
%token DECLARE END BGN 
%token PLUS MINUS TIMES DIV MOD
%token EQ NEQ LE GE LEQ GEQ 
%token <ival> NUM
%token <sval> PIDENTIFIER 
%type <ival> identifier
%type <jval> condition
%type <jval> WHILE
%left PLUS MINUS
%left TIMES DIV MOD

%{
#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <cstdio>
#include <string.h>
#undef YYDEBUG
#define YYDEBUG 1
#define EAX 0  // rejestr na który działaja operacje sub add itp
#define EBX 1
#define ECX 2
#define EDX 3
#define ESI 4
#define EDI 5
#define ONE 6
#define MINUS_ONE 8
#define EEX 7
#define ESP 11
#define EBP 100
#define STACK_OVERFLOW 300
#define DATA_START 301
extern FILE *yyout;
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
	struct jmp_info{
		int jmp_false;
		int jmp_true;
		int jmp_end;
		int jmp_prestart;
	};


	cell memory[999];
	cmd output[999];
	int output_offset=0;
	int data_offset = 0;

	jmp_info *  new_jmp_info(){
		jmp_info * j =  (jmp_info *)malloc(sizeof(jmp_info));
		return j;
	}

	int gen_code(const char * code){
		printf("%s\n",code);
		output[output_offset].oper = strdup(code);
		output[output_offset].arg = -1;
		return output_offset++;
	}
	int gen_code(const char * code,int arg){
		printf("%s %d\n",code,arg);
		output[output_offset].oper = strdup(code);
		output[output_offset].arg = arg;
		return output_offset++;
	}


	void pop(){
		gen_code("LOAD",ESP);
		gen_code("DEC");
		gen_code("STORE",ESP);
	}



	void numberToP0(int number){
		gen_code("SUB",EAX);
		gen_code("INC");
		bool neg =0;
		if(number > 0);
		
		else if (number < 0){
			neg=1;
			number=-number;
			
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
		if(neg){
			gen_code("STORE",EBX);
			gen_code("SUB",EAX);
			gen_code("SUB",EBX);
		
		}
			//gen_code("PUT");
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
		pop();
	}
	
	void setup(){
		gen_code("SUB",EAX);
		gen_code("INC");
		gen_code("STORE",ONE);
		numberToP0(EBP);
		gen_code("STORE",ESP);
		gen_code("SUB",EAX);
		gen_code("DEC");
		gen_code("STORE",MINUS_ONE);

	}

	void pushIdValue(int addr  ){
		gen_code("LOAD",ESP);
		gen_code("INC");
		gen_code("STORE",ESP);

		gen_code("LOAD",addr);
		gen_code("STOREI",ESP);
		

	}
	void write(){
		gen_code("LOADI",ESP);
		gen_code("PUT");
		pop();

	}
	void read(int v){
		gen_code("GET");
		gen_code("STORE",v);

	}
namespace math {
	void plus(){
		gen_code("LOADI",ESP);
		gen_code("STORE",EBX);
		pop();
		gen_code("LOADI",ESP);
		gen_code("ADD",EBX);
		gen_code("STOREI",ESP);
	}
	void minus(){
		gen_code("LOADI",ESP);
		gen_code("STORE",EBX);
		pop();
		gen_code("LOADI",ESP);
		gen_code("SUB",EBX);
		gen_code("STOREI",ESP);
	}
	void times(){
		gen_code("SUB",EAX);
		gen_code("STORE",ESI); // zerujemy esi, tu będzie wynik na końcu
		gen_code("STORE",EDI); 
		gen_code("STORE",EDX);
		gen_code("LOADI",ESP);
		gen_code("STORE",EBX);
		int jmp_pos = gen_code("JPOS",-1);
		gen_code("SUB",EAX);
		gen_code("INC");
		gen_code("STORE",EDI);
		gen_code("SUB",EAX);
		gen_code("SUB",EBX);
		output[jmp_pos].arg = 1 + gen_code("STORE",EBX); 
		pop();
		gen_code("LOADI",ESP);
		gen_code("STORE",ECX);
		int again =  gen_code("LOAD",EDX);
		gen_code("INC");
		gen_code("STORE",EDX);
		gen_code("SUB",EAX);
		gen_code("INC");
		gen_code("SHIFT",EDX);
		gen_code("STORE",EEX);
		gen_code("SUB",EBX);
		gen_code("JNEG",again); 

		// w tym momencie znaleźliśmy potęgę dwójki większą od drugiego czynnika
		// jest ona w EDX, w ECX pierwszy czynnik, w EBX drugi
		int loop = gen_code("LOAD",EBX);
		gen_code("SUB",EEX);
		int jumpneg = gen_code("JNEG",-1);
		// tutaj program wchodzi jeśli jest nieujemne, tzn da sie odjac potege dwojki
		gen_code("LOAD",ECX);
		gen_code("SHIFT",EDX);
		gen_code("ADD",ESI);
		gen_code("STORE",ESI); // dodajemy 2^EDX * ECX do ESI
		gen_code("LOAD",EBX);
		gen_code("SUB",EEX);	
		gen_code("STORE",EBX);

		int neg_target = gen_code("LOAD",EEX); // tu sobie skaczemu jak jest negatywne
		output[jumpneg].arg = neg_target;
		gen_code("SHIFT",MINUS_ONE);
		gen_code("STORE",EEX);
		//debug
		gen_code("LOAD",EDX);
		gen_code("DEC");
		gen_code("STORE",EDX);
		gen_code("LOAD",EBX);
		int jump_end = gen_code("JZERO",-1);
		gen_code("JUMP", loop);
		int end_target = gen_code("LOAD",ESP);
		output[jump_end].arg=end_target;
		
		// gen_code("INC");
		// gen_code("STORE",ESP);
		gen_code("LOAD",EDI);
		int no_minus = gen_code("JZERO",-1);
		gen_code("SUB",EAX);
		gen_code("SUB",ESI);
		int finish =  gen_code("JUMP",-1);
		output[no_minus].arg = gen_code("LOAD",ESI);
		output[finish].arg=gen_code("STOREI",ESP);


	}
	void div(){
		gen_code("SUB",EAX);
		gen_code("STORE",ESI); // zerujemy esi, tu będzie wynik na końcu
		gen_code("STORE",EDI); 
		gen_code("STORE",EDX);
		gen_code("LOADI",ESP);
		gen_code("STORE",EBX); // dzielnik		}
		pop();
		gen_code("LOAD",EBX);
		int jmp_zero_2 = gen_code("JZERO",-1);
		int jmp_non_zero_2 = gen_code("JUMP",-1);
		
		int jmp_neg1 = output[jmp_non_zero_2].arg = gen_code("JPOS",-1);
		gen_code("SUB",EAX);
		gen_code("INC");
		gen_code("STORE",EDI);
		gen_code("SUB",EAX);
		gen_code("SUB",EBX); // jesli dzielnik ujemny to robimy z niego dodatni
		gen_code("STORE",EBX);
		output[jmp_neg1].arg = gen_code("LOADI",ESP);
		gen_code("STORE",ECX); // ECX - dzielna
		int jmp_neg2 = gen_code("JPOS",-1);
		gen_code("SUB",EAX);
		gen_code("SUB",ECX); // jesli dzielna ujemna to niech bedzie dodatnia
		gen_code("STORE",ECX);
		gen_code("LOAD",EDI);
		gen_code("DEC");
		gen_code("STORE",EDI);
		output[jmp_neg2].arg = gen_code("SUB",EAX);
		int m = gen_code("LOAD",EDX); // wykladnik potegi
		gen_code("INC");
		gen_code("STORE",EDX);
		gen_code("SUB",EAX);
		gen_code("ADD",EBX);
		gen_code("SHIFT",EDX);
		gen_code("STORE",EEX); // wartosc potegi * baza
		gen_code("SUB",ECX);
		gen_code("JNEG",m); 

		//db
		gen_code("LOAD",EEX);
		gen_code("LOAD",EDX);
		//db
		int again = gen_code("LOAD",ECX);
		gen_code("SUB",EEX);
		int jmp_lower = gen_code("JNEG",-1); // skok jeśli EEX > ECX
		
		gen_code("SUB",EAX);
		gen_code("INC");
		gen_code("SHIFT",EDX);
		gen_code("ADD",ESI);

	
		gen_code("STORE",ESI);

		gen_code("LOAD",ECX);
		gen_code("SUB",EEX);
		gen_code("STORE",ECX);
		
		output[jmp_lower].arg = gen_code("LOAD",EEX);
	
		gen_code("SHIFT",MINUS_ONE);					// neg
		gen_code("STORE",EEX);
		gen_code("LOAD",EDX);
		gen_code("DEC");
		gen_code("STORE",EDX);
		
		gen_code("INC");
		int jmp_koniec = gen_code("JZERO",-1);
			gen_code("JUMP",again);
		output[jmp_koniec].arg = gen_code("LOAD",EDI);

		int jmp_pos_out = gen_code("JZERO",-1);
		gen_code("SUB",EAX);
		gen_code("SUB",ESI);
		gen_code("STORE",ESI);

		output[jmp_zero_2].arg = output[jmp_pos_out].arg = gen_code("LOAD",ESI);
		gen_code("STOREI",ESP);


	}


	void modulo(){
		gen_code("SUB",EAX);
		gen_code("STORE",ESI); // zerujemy esi, tu będzie wynik na końcu
		gen_code("STORE",EDI); 
		gen_code("STORE",EDX);
		gen_code("STORE",ECX);
		gen_code("LOADI",ESP);
		gen_code("STORE",EBX); // dzielnik		}
		pop();
		gen_code("LOAD",EBX);
		int jmp_zero_2 = gen_code("JZERO",-1);
		int jmp_non_zero_2 = gen_code("JUMP",-1);
		int jmp_neg1 = output[jmp_non_zero_2].arg = gen_code("JPOS",-1);
		gen_code("SUB",EAX);
		gen_code("INC");
		gen_code("STORE",EDI);
		gen_code("SUB",EAX);
		gen_code("SUB",EBX); // jesli dzielnik ujemny to robimy z niego dodatni
		gen_code("STORE",EBX);
		output[jmp_neg1].arg = gen_code("LOADI",ESP);
		gen_code("STORE",ECX); // ECX - dzielna
		int jmp_neg2 = gen_code("JPOS",-1);
		gen_code("SUB",EAX);
		gen_code("SUB",ECX); // jesli dzielna ujemna to niech bedzie dodatnia
		gen_code("STORE",ECX);
		output[jmp_neg2].arg = gen_code("SUB",EAX);
		int m = gen_code("LOAD",EDX); // wykladnik potegi
		gen_code("INC");
		gen_code("STORE",EDX);
		gen_code("SUB",EAX);
		gen_code("ADD",EBX);
		gen_code("SHIFT",EDX);
		gen_code("STORE",EEX); // wartosc potegi * baza
		gen_code("SUB",ECX);
		gen_code("JNEG",m); 

		//db
		gen_code("LOAD",EEX);
		gen_code("LOAD",EDX);
		//db
		int again = gen_code("LOAD",ECX);
		gen_code("SUB",EEX);
		int jmp_lower = gen_code("JNEG",-1); // skok jeśli EEX > ECX
		
		gen_code("SUB",EAX);
		gen_code("INC");
		gen_code("SHIFT",EDX);
		gen_code("ADD",ESI);

	
		gen_code("STORE",ESI);

		gen_code("LOAD",ECX);
		gen_code("SUB",EEX);
		gen_code("STORE",ECX);
		
		output[jmp_lower].arg = gen_code("LOAD",EEX);
	
		gen_code("SHIFT",MINUS_ONE);					// neg
		gen_code("STORE",EEX);
		gen_code("LOAD",EDX);
		gen_code("DEC");
		gen_code("STORE",EDX);
		
		gen_code("INC");
		int jmp_koniec = gen_code("JZERO",-1);
			gen_code("JUMP",again);
		output[jmp_koniec].arg = gen_code("LOAD",EDI);

		int jmp_pos_out = gen_code("JZERO",-1);
		gen_code("SUB",EAX);
		gen_code("SUB",ECX);
		gen_code("STORE",ECX);

		output[jmp_zero_2].arg = output[jmp_pos_out].arg = gen_code("LOAD",ECX);
		gen_code("STOREI",ESP);
	}
}

namespace logic {
	void eq(jmp_info * j){
		gen_code("LOADI",ESP);
		gen_code("STORE",ECX);
		pop();
		gen_code("LOADI",ESP);
		gen_code("STORE",EBX);
		pop();
		gen_code("LOAD",ECX);
		gen_code("SUB",EBX);
		int jmp_true = gen_code("JZERO",-1);
		int jmp_false = gen_code("JUMP",false);
		output[jmp_true].arg = jmp_false + 1;

		j->jmp_true = jmp_true;
		j->jmp_false = jmp_false;

	}
	void neq(jmp_info * j){
		gen_code("LOADI",ESP);
		gen_code("STORE",ECX);
		pop();
		gen_code("LOADI",ESP);
		gen_code("STORE",EBX);
		pop();
		gen_code("LOAD",ECX);
		gen_code("SUB",EBX);
		int jmp_false = gen_code("JZERO",-1);
		//int jmp_true = gen_code("JUMP",false);
		//output[jmp_true].arg = jmp_false + 1; 

		j->jmp_true = 0;
		j->jmp_false = jmp_false;
	}
	void le(jmp_info * j){
		gen_code("LOADI",ESP);
		gen_code("STORE",ECX);
		pop();
		gen_code("LOADI",ESP);
		gen_code("STORE",EBX);
		pop();
		gen_code("LOAD",EBX);
		gen_code("INC");
		gen_code("SUB",ECX);
		int jmp_false = gen_code("JPOS",-1);
		//int jmp_true = gen_code("JUMP",false);
		//output[jmp_true].arg = jmp_false + 1; 

		j->jmp_true = 0;
		j->jmp_false = jmp_false;
	}
	void ge(jmp_info * j){
		gen_code("LOADI",ESP);
		gen_code("STORE",ECX);
		pop();
		gen_code("LOADI",ESP);
		gen_code("STORE",EBX);
		pop();
		gen_code("LOAD",EBX);
		gen_code("SUB",ECX);
		gen_code("DEC"); // różni się od geq tylko ta linijką
		int jmp_false = gen_code("JNEG",-1);
		//int jmp_true = gen_code("JUMP",false);
		//output[jmp_true].arg = jmp_false + 1; 

		j->jmp_true = 0;
		j->jmp_false = jmp_false;
	}
	void leq(jmp_info * j){
		gen_code("LOADI",ESP);
		gen_code("STORE",ECX);
		pop();
		gen_code("LOADI",ESP);
		gen_code("STORE",EBX);
		pop();
		gen_code("LOAD",EBX);
		gen_code("SUB",ECX);
		int jmp_false = gen_code("JPOS",-1);
		//int jmp_true = gen_code("JUMP",false);
		//output[jmp_true].arg = jmp_false + 1; 

		j->jmp_true = 0;
		j->jmp_false = jmp_false;
	}
	void geq(jmp_info * j){
		gen_code("LOADI",ESP);
		gen_code("STORE",ECX);
		pop();
		gen_code("LOADI",ESP);
		gen_code("STORE",EBX);
		pop();
		gen_code("LOAD",EBX);
		gen_code("SUB",ECX);
		int jmp_false = gen_code("JNEG",-1);
		//int jmp_true = gen_code("JUMP",false);
		//output[jmp_true].arg = jmp_false + 1; 

		j->jmp_true = 0;
		j->jmp_false = jmp_false;
	}
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
commands:		commands command {printf("tas");}
|				command {printf("te");}
;
command:		identifier ASSIGN expression ';'									{assign($1);			}
|				IF condition THEN commands											
				{$2->jmp_end= gen_code("JUMP",-1);} 
				ELSE 
				{output[$2->jmp_false].arg = output_offset;}
				commands ENDIF
				{output[$2->jmp_end].arg=output_offset;}

|				IF  condition THEN commands ENDIF 							
				{output[$2->jmp_false].arg  = output_offset;}
|				WHILE 
				{$1 = new_jmp_info();
				$1->jmp_prestart = output_offset;}
				condition DO commands ENDWHILE		
				{gen_code("JUMP",$1->jmp_prestart); 
				printf("%d",$3->jmp_false);
				output[$3->jmp_false].arg  = output_offset;}						

| 				DO commands WHILE condition ENDDO
|				FOR PIDENTIFIER FROM value TO value DO commands ENDFOR
|				FOR PIDENTIFIER FROM value TO value DOWNTO value DO commands ENDFOR
|				READ identifier ';' {read($2);}
|				WRITE value  ';' {write();}
;
expression:		value 							{}
|				value PLUS value 				{ math::plus();}
|				value MINUS value 				{ math::minus();}
|				value TIMES value 				{ math::times();}
|				value DIV value 				{ math::div();}
|				value MOD value 				{ math::modulo();}

;
condition:		value EQ value 					{jmp_info* j = new_jmp_info();
													logic::eq(j);
												$$ = j;								}
|				value NEQ value 				{jmp_info* j = new_jmp_info();
												logic::neq(j);
												$$ = j;								}
|				value LE value 					{jmp_info* j = new_jmp_info();
												logic::le(j);
												$$ = j;								}
|				value GE value 					{jmp_info* j = new_jmp_info();
												logic::ge(j);
												$$ = j;								}
|				value LEQ value 				{jmp_info* j = new_jmp_info();
												logic::leq(j);
												$$ = j;								}
|				value GEQ value 				{jmp_info* j = new_jmp_info();
												logic::geq(j);
												$$ = j;								}
;
value:			NUM 							{	push_number(yylval.ival);		}
|				identifier						{	pushIdValue($1);					
																					}
;
identifier:		PIDENTIFIER 					{	$$ = findVar($1);}
|				PIDENTIFIER'('PIDENTIFIER')'	{	$$ = 0;}
|				PIDENTIFIER'('NUM')'			{	$$ = 0;}
;
%%

int main( int argc, char *argv[] ){ 
	extern FILE *yyin;
	extern FILE *yyout;
	
	if(argc>0){
		yyin = fopen( argv[1], "r" );
	}
	if(argc>1){
		yyout = fopen( argv[2], "w" );
	}
	setup();
	yyparse();
	gen_code("HALT");
	for(int i=0;i<output_offset;i++){
		if(output[i].arg!=-1){
			fprintf(yyout,"%s %d\n",output[i].oper,output[i].arg);
		}
		else fprintf(yyout,"%s\n",output[i].oper);
	}

}
void yyerror (const char *s) 
{
	printf ("Error: %s\n", s);

}
