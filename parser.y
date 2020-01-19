%start program

%union{
	char * sval;
	long long ival;
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
%type <jval> WHILE DO FOR
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
#define STACK_OVERFLOW 1000
#define DATA_START 1500
using namespace std;

extern FILE *yyout;
void yyerror(const char *s);
	long long ebp = 100;
	long long esp = ebp;
		
	struct cell {
		 long long address;
		char * name;
		long long min;
		long long max;
		bool tab;
		
	};

	struct cmd{
		char * oper;
		long long int arg;
		char * comment;
	};
	struct jmp_info{
		long long jmp_false;
		long long jmp_true;
		long long jmp_end;
		long long jmp_prestart;
	};


	cell memory[999999];
	cmd output[999999];
	long long output_offset=0;
	long long data_offset = 0;
	long long next_address = DATA_START;
	jmp_info *  new_jmp_info(){
		jmp_info * j =  (jmp_info *)malloc(sizeof(jmp_info));
		return j;
	}

	long long gen_code(const char * code){
		printf("%s\n",code);
		output[output_offset].oper = strdup(code);
		output[output_offset].arg = -1;
		return output_offset++;
	}
	long long gen_code(const char * code,long long arg){
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



	void numberToP0(long long number){
		gen_code("SUB",EAX);
		if(number==0)
		{
			return;
		}
		gen_code("INC");
		bool neg =0;
		if(number > 0);
		
		else if (number < 0){
			neg=1;
			number=-number;
			
		}

		bool opers[100];// 0 - (+1); 1 - (*2)
		long long oper_number = 0;
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
		for(long long i=oper_number-1;i>=0;i--){
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
	void push_number(long long number){
		gen_code("LOAD",ESP);
		gen_code("INC");
		gen_code("STORE",ESP);
	
		
		numberToP0(number);
		// teraz w p0 jest number
		gen_code("STOREI",ESP);

	}


	long long findVar(char * var_name){
		for(long long i=0;i<data_offset;i++){
			printf("%s\n",memory[i].name);
			if(strcmp(var_name,memory[i].name)==0)return memory[i].address;
			
		}
		
		yyerror("Variable not found");
		return -1;
	}
	long long findVar(char * var_name,long long index){
		cell m;
		bool x = 0;
		printf("\n%s\n%d\n",var_name,index);
		for(long long i=0;i<data_offset;i++){
			printf("%s\n",memory[i].name);

			if(strcmp(var_name,memory[i].name)==0){
				m = memory[i];
				x =1;
				break;
			}
		}
		if(x == 0){
				yyerror("Array not found");
				return -1;
		}
		if(m.tab == 0){
			yyerror("variable cant be accessed as array");
		}
		if(m.max < index || m.min > index){
			printf("%d\n",m.max);
			yyerror("index ouf of range");
		}
		long long a = m.address + index - m.min;
		return a;
	
	}
	void assign(long long var_addr){
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

	void pushIdValue(long long addr  ){
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
	void read(long long v){
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
		long long jmp_pos = gen_code("JPOS",-1);
		gen_code("SUB",EAX);
		gen_code("INC");
		gen_code("STORE",EDI);
		gen_code("SUB",EAX);
		gen_code("SUB",EBX);
		output[jmp_pos].arg = 1 + gen_code("STORE",EBX); 
		pop();
		gen_code("LOADI",ESP);
		gen_code("STORE",ECX);
		long long again =  gen_code("LOAD",EDX);
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
		long long loop = gen_code("LOAD",EBX);
		gen_code("SUB",EEX);
		long long jumpneg = gen_code("JNEG",-1);
		// tutaj program wchodzi jeśli jest nieujemne, tzn da sie odjac potege dwojki
		gen_code("LOAD",ECX);
		gen_code("SHIFT",EDX);
		gen_code("ADD",ESI);
		gen_code("STORE",ESI); // dodajemy 2^EDX * ECX do ESI
		gen_code("LOAD",EBX);
		gen_code("SUB",EEX);	
		gen_code("STORE",EBX);

		long long neg_target = gen_code("LOAD",EEX); // tu sobie skaczemu jak jest negatywne
		output[jumpneg].arg = neg_target;
		gen_code("SHIFT",MINUS_ONE);
		gen_code("STORE",EEX);
		//debug
		gen_code("LOAD",EDX);
		gen_code("DEC");
		gen_code("STORE",EDX);
		gen_code("LOAD",EBX);
		long long jump_end = gen_code("JZERO",-1);
		gen_code("JUMP", loop);
		long long end_target = gen_code("LOAD",ESP);
		output[jump_end].arg=end_target;
		
		// gen_code("INC");
		// gen_code("STORE",ESP);
		gen_code("LOAD",EDI);
		long long no_minus = gen_code("JZERO",-1);
		gen_code("SUB",EAX);
		gen_code("SUB",ESI);
		long long finish =  gen_code("JUMP",-1);
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
		long long jmp_zero_2 = gen_code("JZERO",-1);
		long long jmp_non_zero_2 = gen_code("JUMP",-1);
		
		long long jmp_neg1 = output[jmp_non_zero_2].arg = gen_code("JPOS",-1);
		gen_code("SUB",EAX);
		gen_code("INC");
		gen_code("STORE",EDI);
		gen_code("SUB",EAX);
		gen_code("SUB",EBX); // jesli dzielnik ujemny to robimy z niego dodatni
		gen_code("STORE",EBX);
		output[jmp_neg1].arg = gen_code("LOADI",ESP);
		gen_code("STORE",ECX); // ECX - dzielna
		long long jmp_neg2 = gen_code("JPOS",-1);
		gen_code("SUB",EAX);
		gen_code("SUB",ECX); // jesli dzielna ujemna to niech bedzie dodatnia
		gen_code("STORE",ECX);
		gen_code("LOAD",EDI);
		gen_code("DEC");
		gen_code("STORE",EDI);
		output[jmp_neg2].arg = gen_code("SUB",EAX);
		long long m = gen_code("LOAD",EDX); // wykladnik potegi
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
		long long again = gen_code("LOAD",ECX);
		gen_code("SUB",EEX);
		long long jmp_lower = gen_code("JNEG",-1); // skok jeśli EEX > ECX
		
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
		long long jmp_koniec = gen_code("JZERO",-1);
			gen_code("JUMP",again);
		output[jmp_koniec].arg = gen_code("LOAD",EDI);

		long long jmp_pos_out = gen_code("JZERO",-1);
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
		long long jmp_zero_2 = gen_code("JZERO",-1);
		long long jmp_non_zero_2 = gen_code("JUMP",-1);
		long long jmp_neg1 = output[jmp_non_zero_2].arg = gen_code("JPOS",-1);
		gen_code("SUB",EAX);
		gen_code("INC");
		gen_code("STORE",EDI);
		gen_code("SUB",EAX);
		gen_code("SUB",EBX); // jesli dzielnik ujemny to robimy z niego dodatni
		gen_code("STORE",EBX);
		output[jmp_neg1].arg = gen_code("LOADI",ESP);
		gen_code("STORE",ECX); // ECX - dzielna
		long long jmp_neg2 = gen_code("JPOS",-1);
		gen_code("SUB",EAX);
		gen_code("SUB",ECX); // jesli dzielna ujemna to niech bedzie dodatnia
		gen_code("STORE",ECX);
		output[jmp_neg2].arg = gen_code("SUB",EAX);
		long long m = gen_code("LOAD",EDX); // wykladnik potegi
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
		long long again = gen_code("LOAD",ECX);
		gen_code("SUB",EEX);
		long long jmp_lower = gen_code("JNEG",-1); // skok jeśli EEX > ECX
		
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
		long long jmp_koniec = gen_code("JZERO",-1);
			gen_code("JUMP",again);
		output[jmp_koniec].arg = gen_code("LOAD",EDI);

		long long jmp_pos_out = gen_code("JZERO",-1);
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
		long long jmp_true = gen_code("JZERO",-1);
		long long jmp_false = gen_code("JUMP",false);
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
		long long jmp_false = gen_code("JZERO",-1);
		long long jmp_true = gen_code("JUMP",false);
		//output[jmp_true].arg = jmp_false + 1; 
			output[jmp_true].arg=jmp_true+1;
		j->jmp_true = jmp_true+1;
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
		long long jmp_false = gen_code("JPOS",-1);
		long long jmp_true = gen_code("JUMP",false);
		//output[jmp_true].arg = jmp_false + 1; 
		output[jmp_true].arg=jmp_true+1;
		j->jmp_true = jmp_true+1;
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
		long long jmp_false = gen_code("JNEG",-1);
		long long jmp_true = gen_code("JUMP",false);
		//output[jmp_true].arg = jmp_false + 1; 
			output[jmp_true].arg=jmp_true+1;
		j->jmp_true = jmp_true+1;
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
		long long jmp_false = gen_code("JPOS",-1);
		long long jmp_true = gen_code("JUMP",false);
		//output[jmp_true].arg = jmp_false + 1; 
			output[jmp_true].arg=jmp_true+1;
		j->jmp_true = jmp_true+1;
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
		long long jmp_false = gen_code("JNEG",-1);
		long long jmp_true = gen_code("JUMP",false);
		//output[jmp_true].arg = jmp_false + 1; 
			output[jmp_true].arg=jmp_true+1;
		j->jmp_true = jmp_true+1;
		j->jmp_false = jmp_false;
	}
}

	

	
	
	long long make_variable(char * temps){
		printf("%s",temps);
		cout << next_address << endl;
		memory[data_offset].name = strdup(temps);
		memory[data_offset].address = next_address;
		printf("asd\n\n%d\n",next_address);
		memory[data_offset].tab = 0;
		printf("%s %d\n",temps,data_offset);
			printf("%d\n",next_address);
		next_address +=(long long)1;
		return data_offset++ + DATA_START;
	}
	long long make_variable(char * temps,long long min, long long max){
		long long size = max - min + 1;
	
		memory[data_offset].name = strdup(temps);
		
		memory[data_offset].min = min;
		memory[data_offset].max = max;
		memory[data_offset].tab = 1;
		long long x = data_offset;
		memory[data_offset].address = next_address;
		next_address += (long long) 1 + max - min;
		printf("\nXXXX\n%d %d %d %d\n",memory[data_offset].address,max,min,memory[data_offset].address+max-min+1);
		cout << endl << endl << next_address << endl << endl;
		data_offset+=1;	
		printf("%s %d\n",temps,x);
		return x + DATA_START;
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
|				declarations ',' PIDENTIFIER '(' NUM ':' NUM ')' {make_variable($3,$5,$7);}
|				PIDENTIFIER										{make_variable($1);}
|				PIDENTIFIER '(' NUM ':' NUM ')'					{make_variable($1,$3,$5);}
;
commands:		commands command {printf("tas");}
|				command {printf("te");}
;
command:		identifier ASSIGN expression ';'									
				{
					if($1 == -1){
						gen_code("LOADI",ESP);
						gen_code("STORE",EBX); // wartosc
						pop();
						gen_code("LOADI",ESP);
						gen_code("STORE",ECX); // indeks docelowy
						gen_code("LOAD",EBX);
						gen_code("STOREI",ECX);
						pop();
					}
					else
					assign($1);			}
|				IF condition THEN commands											
				{$2->jmp_end= gen_code("JUMP",-1);
				output[$2->jmp_end].comment = strdup("JUMP TO IF END");
				} 
				ELSE 
				{output[$2->jmp_false].arg = output_offset;}
				commands ENDIF
				{output[$2->jmp_end].arg=output_offset;
				output[output_offset].comment = strdup("IF END");
				}

|				IF  condition THEN commands ENDIF 							
				{output[$2->jmp_false].arg  = output_offset;}
|				WHILE 
				{$1 = new_jmp_info();
				$1->jmp_prestart = output_offset;;
				output[output_offset].comment = strdup("WHILESTART");
				}
				condition DO commands ENDWHILE		
				{gen_code("JUMP",$1->jmp_prestart); 
				printf("%d",$3->jmp_false);
				output[$3->jmp_false].arg  = output_offset;}						

| 				DO 
				{$1 = new_jmp_info();
				$1->jmp_prestart = output_offset;}

				commands WHILE condition ENDDO
				{
					gen_code("JUMP",$1->jmp_prestart); 
					output[$5->jmp_false].arg =output_offset;
				}

|				FOR PIDENTIFIER FROM value
				{
					$1 = new_jmp_info();
					make_variable($2);
					gen_code("LOADI",ESP);
					gen_code("STORE",next_address-1);
					pop();

				}

				TO value DO
				{

					$1->jmp_prestart = gen_code("LOADI",ESP);
					gen_code("SUB",findVar($2));
					$1->jmp_false =  gen_code("JNEG",-1);
				}
			
				commands ENDFOR
				{	
					gen_code("LOAD",findVar($2));
					gen_code("INC");
					gen_code("STORE",findVar($2));
					gen_code("JUMP",$1->jmp_prestart);
					output[$1->jmp_false].arg = output_offset;
					pop();
					data_offset--;
				}


|				FOR PIDENTIFIER FROM value // down to
				{
						$1 = new_jmp_info();
					make_variable($2);
					gen_code("LOADI",ESP);
					gen_code("STORE",next_address-1);
					pop();

				}

				DOWNTO value DO
				{
					printf("Test");
					$1->jmp_prestart = 3;
					printf("\n%d",$1->jmp_prestart);
					$1->jmp_prestart = gen_code("LOADI",ESP);
					gen_code("STORE",EBX);
					gen_code("LOAD",findVar($2));
					gen_code("SUB",EBX);
					$1->jmp_false =  gen_code("JNEG",-1);
				}
			
				commands ENDFOR
				{	
					gen_code("LOAD",findVar($2));
					gen_code("DEC");
					gen_code("STORE",findVar($2));
					gen_code("LOAD",ESP);
					
					gen_code("JUMP",$1->jmp_prestart);
					output[$1->jmp_false].arg = output_offset;
					pop();
					data_offset--;
				}

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
value:			NUM 							{	push_number(yylval.ival);	
												}
|				identifier						{	if($1 == -1){
														gen_code("LOADI",ESP);
														gen_code("LOADI",EAX);
														gen_code("STOREI",ESP);
													}
													else
													pushIdValue($1);					
																					}
;
identifier:		PIDENTIFIER 					{	$$ = findVar($1);}
|				PIDENTIFIER'('PIDENTIFIER')'	{	
													numberToP0(findVar($1));
													gen_code("STORE",EEX);
													numberToP0(-memory[findVar($1)-DATA_START].min);

													gen_code("ADD",findVar($3)); // teraz tu jest adres
													gen_code("ADD",EEX);
													gen_code("STORE",EDX);
													gen_code("LOAD",ESP);
													gen_code("INC");
													gen_code("STORE",ESP);
													gen_code("LOAD",EDX);
													gen_code("STOREI",ESP);
													$$=-1;
												}
|				PIDENTIFIER'('NUM')'			{	$$ = findVar($1,$3);}
;
%%

int main( long long argc, char *argv[] ){ 
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
	printf("\n\n");
	for(long long i=0;i<data_offset;i++){
		cout << memory[i].name << " " << memory[i].address << endl;
	}

	for(long long i=0;i<output_offset;i++){
		if(output[i].arg!=-1){
			fprintf(yyout,"%s %lld\n",output[i].oper,output[i].arg);
		}
		else fprintf(yyout,"%s\n",output[i].oper);
	}

}
void yyerror (const char *s) 
{
	printf ("Error: %s\n", s);

}
 