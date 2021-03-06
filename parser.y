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
#define EBX 1 // reszta rejestrów
#define ECX 2
#define EDX 3
#define ESI 4
#define EDI 5
#define ONE 6
#define MINUS_ONE 8
#define EEX 7
#define EFX 9
#define ESP 11 // przechowuje adres ostatniego elementu na stosie
#define EBP 100 // początek stosu

#define DATA_START 1500 // początek przechowywania zmiennych
using namespace std;
extern int yylineno;
extern FILE *yyout;
void yyerror(const char *s);
	long long ebp = 100;
	long long esp = ebp;
		
	struct cell { // przechowuje informacje o zmiennej / tablicy
		 long long address;
		char * name;
		long long min;
		long long max;
		bool tab;
		bool iterator;
		bool init;
		int used;
	};

	struct cmd{ // pojedyncza operacja, np LOAD 3
		char * oper;
		long long int arg;
		char * comment;
	};
	struct jmp_info{ // informacje na temat skoku
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
	jmp_info *  new_jmp_info(){ // tworzenie nowej informacji o skoku
		jmp_info * j =  (jmp_info *)malloc(sizeof(jmp_info));
		return j;
	}

	long long gen_code(const char * code){ // generowanie kodu DEC INC
		//printf("%s\n",code);
		output[output_offset].oper = strdup(code);
		output[output_offset].arg = -1;
		return output_offset++;
	}
	long long gen_code(const char * code,long long arg){ // generowanie reszty słów np STORE 9
		//printf("%s %d\n",code,arg);
		output[output_offset].oper = strdup(code);
		output[output_offset].arg = arg;
		return output_offset++;
	}


	void pop(){ // zdejmowanie wartości ze stosu
		gen_code("LOAD",ESP);
		gen_code("DEC");
		gen_code("STORE",ESP);
	}



	void numberToP0(long long number){ // wrzucenie stałej do P0 -- następuje ona przez najoptymalniejszą kombinację
		//printf("%lld",number); // mnożeń przez 2 i inkrementacji
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

		bool opers[9999];// 0 - (+1); 1 - (*2)
		long long oper_number = 0;
			while(number>1){
		//		printf("%lld\n",number);
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
	void push_number(long long number){ //wrzucenie liczby na stos
		gen_code("LOAD",ESP);
		gen_code("INC");
		gen_code("STORE",ESP);
	
		
		numberToP0(number);
		// teraz w p0 jest number
		gen_code("STOREI",ESP); 

	}


	long long findVar(char * var_name){ // szukanie adresu zmiennej 
		for(long long i=0;i<data_offset;i++){
			//printf("%s\n",memory[i].name);
			if(strcmp(var_name,memory[i].name)==0)return memory[i].address;
			
		}
		
		yyerror("Variable not found");
		return -1;
	}
	long long findVar(char * var_name,long long index){ // szukanie adresu elementu w tablicy
		cell m;
		bool x = 0;
	//	printf("\n%s\n%d\n",var_name,index);
		for(long long i=0;i<data_offset;i++){
	//		printf("%s\n",memory[i].name);

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
	//		printf("%d\n",m.max);
			yyerror("index ouf of range");
		}
		long long a = m.address + index - m.min;
		return a;
	
	}
	void assign(long long var_addr){ // przypisanie wartości do zmiennej lub tablicy o stałym indexie
		for(int i=0;i<data_offset;i++){
			if(var_addr == memory[i].address){
				if(memory[i].iterator==1){
					yyerror("iterator can't be changed");
				}
				else{
					memory[i].init = 1;
					break;
				}
			}

		}

		gen_code("LOADI",ESP);
		gen_code("STORE",var_addr);
		pop();
	}
	
	void setup(){ // inicjalizacja
		gen_code("SUB",EAX);
		gen_code("INC");
		gen_code("STORE",ONE);
		numberToP0(EBP); 
		gen_code("STORE",ESP); // linijka wyżej wrzuca EBP=100 na EAX, po czym zapisuje go pod ESP=11.
		gen_code("SUB",EAX); 
		gen_code("DEC");
		gen_code("STORE",MINUS_ONE);

	}

	void pushIdValue(long long addr  ){ // wrzucenie na stos wartości pod adresem

		for(int i=0;i<data_offset;i++){
			if(addr == memory[i].address){
					memory[i].used = yylineno; // do obsługi błędów inicjalizacji, zapisujemy linijke na której była użyta
			}

		}
		gen_code("LOAD",ESP);
		gen_code("INC");
		gen_code("STORE",ESP);

		gen_code("LOAD",addr);
		gen_code("STOREI",ESP);
		

	}
	void write(){
		gen_code("LOADI",ESP); // wypisywanie na ekran ze stosu
		gen_code("PUT");
		pop();

	}
	void read(long long v){ // zczytywanie do adresu v 
		gen_code("GET");
		gen_code("STORE",v);
		for(int i=0;i<data_offset;i++){
			if(memory[i].address==v){
				memory[i].init = 1;
				break;
			}
		}

	}
namespace math { // wszystkie operacje zdejmują 2 liczby ze stosu i wrzucają 1
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
	void times(){ // mnożenie to jest mocarz.


		gen_code("SUB",EAX);
		gen_code("STORE",ESI); // zerujemy esi, tu będzie wynik na końcu
		gen_code("STORE",EDI); 
		gen_code("STORE",EDX);
		gen_code("LOADI",ESP);
		gen_code("STORE",EBX); // EBX - drugi czynnik
		long long jmp_pos = gen_code("JPOS",-1);
		gen_code("SUB",EAX);
		gen_code("INC");
		gen_code("STORE",EDI);
		gen_code("SUB",EAX);
		gen_code("SUB",EBX); // na minus jeśli EBX ujemne
		output[jmp_pos].arg = 1 + gen_code("STORE",EBX); 
		pop();				// zdejmujemy ze stosu tylko raz. wynik nadpisuje pierwszy czynnik
		gen_code("LOADI",ESP);
		gen_code("STORE",ECX); // ECX - pierwszy czynnik
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
		//  w ECX pierwszy czynnik, w EBX drugi
		// w EDX wykładnik, w EEX wartosc
		long long loop = gen_code("LOAD",EBX);
		gen_code("SUB",EEX); // sprawdzamy czy to co jest w EEX miesci sie w EBX
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


		/*
		Przykład jak to działa
		powiedzmy że mamy 5 * 6

		program znajduje potęgę 2 większą od 6 => 8
		wykładnik = 3
		sprawdzamy czy 6-8 < 0, oczywiście nie więc dzielimy 8 na 2 => 4
		a od wykładnika odejmujemy 1
		i sprawdzamy 2^2 = 4
		6 - 4 >= 0, więc do wyniku dodajemy 4 * 5(pierwszy czynnik), od 6 odejmujemy 4.
		wykładnik-=1 => 1
		wartosc 4 /= 2 => 2
		drugi czynnik 6-=4 =? 2
		2 - 2 >= 0, więc do wyniku dodajemy 2 * 5, od 2 odejmujemy 2.
		W wyniku czyli bodajże ESI mamy teraz 4*5 + 2*5

		Tl;dr: 
		Odejmujemy od drugiego czynnika kolejne potęgi dwójki, jeśli da się
		odjąć to dodajemy tą potęgę razy pierwszy czynnik do wyniku
		*/
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
		gen_code("LOAD",ECX);
		long long zero =gen_code("JZERO",-1);
		gen_code("LOAD",ESI);
		gen_code("DEC");
		gen_code("STORE",ESI);
		output[zero].arg = output[jmp_zero_2].arg = output[jmp_pos_out].arg = gen_code("LOAD",ESI);
		gen_code("STOREI",ESP);

		/*
			Tu jest dużo do tłumaczenia. Zasadniczo kod tutaj to jest syf,
			i musiałaaam bardzo kombinować żeby uwzględnić niżej operację modulo, a nie klasyczną resztę z dzielenia
			(o ile mnie wiedza matematyczna nie myli).
			Zasadniczo patent jest podobny jak w mnożeniu:
			Jeśli da się od dzielnej odjąć potęgę dwójki razy dzielnik to dodaję wartość tej potęgi dwójki do wyniku.
			No, w sumie tyle. Modulo jest podobne, na koniec coś zostanie i to wypisujemy w modulo.
			Te przypadki z operacji modulo która sprawiała problemy zwyczajnie wyifowałem, czyli np
			33 % -7 daje niżej najpierw wynik 5, potem dopiero odejmuję od tego 7.
		*/
	}


	void modulo(){
		gen_code("SUB",EAX);
		gen_code("STORE",ESI); // zerujemy esi, tu będzie wynik na końcu
		gen_code("STORE",EDI); 
		gen_code("STORE",EDX);
		gen_code("STORE",ECX);
		gen_code("STORE",EFX);
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
		gen_code("LOAD",EFX);
		gen_code("INC");
		gen_code("STORE",EFX);	
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
		gen_code("ADD",ECX);
		long long zero = gen_code("JZERO",-1);
		gen_code("SUB",EBX);

		
		output[zero].arg = gen_code("STORE",ECX);
		
 		output[jmp_zero_2].arg = output[jmp_pos_out].arg = output_offset;
 		gen_code("LOAD",EFX);
		long long aminus = gen_code("JZERO",-1);																																																																	//ale mi sie nie chce
		gen_code("SUB",EAX);
		gen_code("SUB",ECX);
		gen_code("STORE",ECX);

		output[aminus].arg = output_offset;
		 gen_code("LOAD",ECX);
		gen_code("STOREI",ESP);
	}
}

namespace logic { // podobnie jak w operacjach - zdejmujemy rzeczy ze stosu, tym razem nic nie dodając.
	// tutaj kod jest chyba dosyc self explanatory albo inne trudne angielskie słówko
	// w sensie no widać

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

	
	bool isFree(char * temps){ // czy jest zadeklarowana taka zmienna
		for(int i=0;i<data_offset;i++){
			if(strcmp(temps,memory[i].name)==0)return false;
		}
		return true;
	}
	
	
	long long make_variable(char * temps){ // tworzenie zmiennej
		//printf("%s",temps);
	//	cout << next_address << endl;
		if(!isFree(temps)){
			yyerror("variable already declared");
		}
		memory[data_offset].name = strdup(temps);
		memory[data_offset].address = next_address;
		memory[data_offset].iterator = 0;
		memory[data_offset].init = 0;
		memory[data_offset].used = -1;
		//printf("asd\n\n%d\n",next_address);
		memory[data_offset].tab = 0;
		//printf("%s %d\n",temps,data_offset);
		//	printf("%d\n",next_address);
		next_address +=(long long)1;
		return data_offset++ + DATA_START;
	}
	long long make_variable(char * temps,long long min, long long max){ // tworzenie tablicy
		long long size = max - min + 1;
		if(min>max){
			yyerror("Negative array size");
		}
		if(!isFree(temps)){
			yyerror("variable already declared");
		}
		memory[data_offset].name = strdup(temps);
		memory[data_offset].iterator = 0;
		memory[data_offset].min = min;
		memory[data_offset].max = max;
		memory[data_offset].init = 0;
		memory[data_offset].tab = 1;
		memory[data_offset].used = -1;
		long long x = data_offset;
		memory[data_offset].address = next_address;
		next_address += (long long) 1 + max - min;
		//printf("\nXXXX\n%d %d %d %d\n",memory[data_offset].address,max,min,memory[data_offset].address+max-min+1);
	//	cout << endl << endl << next_address << endl << endl;
		data_offset+=1;	
		//printf("%s %d\n",temps,x);
		return x + DATA_START;
	}
	

	using namespace std; // chyba z pięć razy to tutaj piszę tą linijkę podobnie jak te niżej
	extern int yylex();  // ale wolę nie ryzykować, pod koniec pisania nie usuwałam nawet komentarzy
	extern int yyparse();// w obawie że to runie
	extern FILE *yyin;

	
%}

%%
program: 		DECLARE declarations BGN commands END {printf("\nfinished\n");}
|		 		BGN commands END {printf("\finished\n");}
;

declarations:   declarations ',' PIDENTIFIER					{make_variable($3);}
|				declarations ',' PIDENTIFIER '(' NUM ':' NUM ')' {make_variable($3,$5,$7);}
|				PIDENTIFIER										{make_variable($1);}
|				PIDENTIFIER '(' NUM ':' NUM ')'					{make_variable($1,$3,$5);}
;
commands:		commands command {}
|				command {}
;
command:		identifier ASSIGN expression ';'									
				{
					if($1 == -1){ // identifier zwraca -1 jeśli mamy doczynienia z elementem tablicy indeksowanym zmienną
						gen_code("LOADI",ESP); // pod EBX jest wartosc ktora wrzucamy
						gen_code("STORE",EBX); // wartosc // pod ECX adres
						pop();
						gen_code("LOADI",ESP);
						gen_code("STORE",ECX); // o tutaj przypisujemy ten adres do ECX
						gen_code("LOAD",EBX);
						gen_code("STOREI",ECX);
						pop();
					}
					else
					assign($1);			}
|				IF condition THEN commands			// od tego momentu radzę wziąć ibuprom							
				{$2->jmp_end= gen_code("JUMP",-1);  // bo skoki warunkowe są bardzo migrenogenne
				
				} 
				ELSE 
				{output[$2->jmp_false].arg = output_offset;} // tu już nie będe za wiele tłumaczył
				commands ENDIF 						// konstrukcja jak linijkę wyżej oznacza,
				// że jeśli warunek będzie niespełniony, to ma skoczyć do tego miejsca 
				{output[$2->jmp_end].arg=output_offset;
				
				}

|				IF  condition THEN commands ENDIF 		 // TUTAJ JEST PROSTSZA wersja tego co u góry			
				{output[$2->jmp_false].arg  = output_offset;}
|				WHILE  								// do tokenu while przypisuje wartosci o skoku
				{$1 = new_jmp_info();
				$1->jmp_prestart = output_offset;;
				
				}
				condition DO commands ENDWHILE		
				{gen_code("JUMP",$1->jmp_prestart); // domyślnie skaczemu do początku
			//	printf("%d",$3->jmp_false);
				output[$3->jmp_false].arg  = output_offset;}			// no chyba że nie, to skaczemu tu i lecimy dalej

| 				DO 
				{$1 = new_jmp_info();
				$1->jmp_prestart = output_offset;}

				commands WHILE condition ENDDO
				{
					gen_code("JUMP",$1->jmp_prestart); 
					output[$5->jmp_false].arg =output_offset; // w sumie podobnie ale warunek dopiero sprawdzamy pod koniec
				}

|				FOR PIDENTIFIER FROM value
				{
					$1 = new_jmp_info(); // do FOR dodajemy info o skokach
					make_variable($2); // tworzymy iteratora
					memory[data_offset-1].iterator = 1; // krzyczymy jeśli iterator będzie zmieniony
					memory[data_offset-1].init = 1;
					gen_code("LOADI",ESP);
					gen_code("STORE",next_address-1);
					pop();

				}

				TO value DO
				{
					// tutaj już są obroty pętli
					$1->jmp_prestart = gen_code("LOADI",ESP);
					gen_code("SUB",findVar($2));
					$1->jmp_false =  gen_code("JNEG",-1); // warunek
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
					memory[data_offset-1].init = 1;
					memory[data_offset-1].iterator = 1;
					gen_code("LOADI",ESP);
					gen_code("STORE",next_address-1);
					pop();

				}

				DOWNTO value DO
				{
			//		printf("Test");
					$1->jmp_prestart = 3;
			//		printf("\n%d",$1->jmp_prestart);
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
expression:		value 							{} // UWAGA, następne 5 linijek w kodzie jest przejrzyste
|				value PLUS value 				{ math::plus();} 
|				value MINUS value 				{ math::minus();} 
|				value TIMES value 				{ math::times();}
|				value DIV value 				{ math::div();}
|				value MOD value 				{ math::modulo();}
													// dobra wystarczy
;
condition:		value EQ value 					{jmp_info* j = new_jmp_info(); 			// tworzymy info o skoku w warunku
													logic::eq(j);						// zasadniczo to tylko dla if to działa, bo for while mają już własny sposó” na przechowanie
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
value:			NUM 							{	push_number(yylval.ival);	// wrzucamy liczbe na stos																																																	// na stos, rzuciliśmy, swój życia los na stos na stos
												}
|				identifier						{	if($1 == -1){ // -1 jeśli to np. tab(a), indeksowanie zmienną
														gen_code("LOADI",ESP); // to jest mocne - wczytujemy adres spod ESP, czyli wierzchołek stosu
														gen_code("LOADI",EAX); // a potem wczytujemy to, co jest pod tym adresem.
														gen_code("STOREI",ESP);// 
													}
													else
													pushIdValue($1);					
																					}
;
identifier:		PIDENTIFIER 					{	$$ = findVar($1); // szukamy sobie liczby
													int j=0;
													for(int i=0;i<data_offset;i++){ // do spradzania błedów
														if(strcmp(memory[i].name,$1)==0){
															j=i;
															break;
														}
													}
													if(memory[j].tab==1){
														yyerror("bad array accessing");
													}
																				}
|				PIDENTIFIER'('PIDENTIFIER')'	{	// jest i nasz nicwoń
													// 
													numberToP0(findVar($1)); 
													gen_code("STORE",EEX);
													int j=0;
													for(int i=0;i<data_offset;i++){
														if(strcmp(memory[i].name,$1)==0){
															j=i;
															break;
														}
													}
													if(memory[j].tab==0){
														yyerror("variable is not an array");
													}
												//	numberToP0(-memory[findVar($1)-DATA_START].min);
													numberToP0(-memory[j].min); // dodajemy -minimum

													gen_code("ADD",findVar($3)); // teraz tu jest adres
													gen_code("ADD",EEX);		// dodajemy o ile przesunąć
													// na koniec adres czegoś w tablicy to
													// ADRES_BAZOWY - MIN + INDEX
													gen_code("STORE",EDX);
													gen_code("LOAD",ESP);
													gen_code("INC");
													gen_code("STORE",ESP);
													gen_code("LOAD",EDX);
													gen_code("STOREI",ESP);
													$$=-1;
												}
|				PIDENTIFIER'('NUM')'			{	$$ = findVar($1,$3);} // pobranie wartosci z tablicy o stałym indexie
;
%%
																																																																																							//ide spać
int main( int argc, char *argv[] ){ 
	extern FILE *yyin;
	FILE *yyout2;
	
	if(argc>0){
		yyin = fopen( argv[1], "r" );
	}
	if(argc>1){
		yyout2 = fopen( argv[2], "w" );
	}
	setup();
	yyparse();
	gen_code("HALT");
	for(int i=0;i<data_offset;i++){
		if(memory[i].init == 0 && memory[i].used != -1){
				printf ("Error: variable uninitialized::: Line: %d\n", memory[i].used);
				exit(0);

		}
	}
	for(long long i=0;i<output_offset;i++){
		if(output[i].arg!=-1){
			fprintf(yyout2,"%s %lld\n",output[i].oper,output[i].arg);
		}
		else fprintf(yyout2,"%s\n",output[i].oper);
	}

}

void yyerror (const char *s) 
{
	printf ("Error: %s::: Line: %d\n", s,yylineno);
	exit(0);

}
 