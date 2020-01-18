
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton implementation for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "2.4.1"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1

/* Using locations.  */
#define YYLSP_NEEDED 0



/* Copy the first part of user declarations.  */


/* Line 189 of yacc.c  */
#line 73 "parser.tab.c"

/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* Enabling the token table.  */
#ifndef YYTOKEN_TABLE
# define YYTOKEN_TABLE 0
#endif


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     ASSIGN = 258,
     IF = 259,
     THEN = 260,
     ELSE = 261,
     ENDIF = 262,
     FOR = 263,
     TO = 264,
     DOWNTO = 265,
     ENDFOR = 266,
     READ = 267,
     WRITE = 268,
     WHILE = 269,
     DO = 270,
     ENDWHILE = 271,
     ENDDO = 272,
     FROM = 273,
     DECLARE = 274,
     END = 275,
     BGN = 276,
     PLUS = 277,
     MINUS = 278,
     TIMES = 279,
     DIV = 280,
     MOD = 281,
     EQ = 282,
     NEQ = 283,
     LE = 284,
     GE = 285,
     LEQ = 286,
     GEQ = 287,
     NUM = 288,
     PIDENTIFIER = 289
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 214 of yacc.c  */
#line 3 "parser.y"

	char * sval;
	int ival;
	struct jmp_info * jval;



/* Line 214 of yacc.c  */
#line 151 "parser.tab.c"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif


/* Copy the second part of user declarations.  */

/* Line 264 of yacc.c  */
#line 22 "parser.y"

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

	


/* Line 264 of yacc.c  */
#line 705 "parser.tab.c"

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#elif (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
typedef signed char yytype_int8;
#else
typedef short int yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(e) ((void) (e))
#else
# define YYUSE(e) /* empty */
#endif

/* Identity function, used to suppress warnings about constant conditions.  */
#ifndef lint
# define YYID(n) (n)
#else
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static int
YYID (int yyi)
#else
static int
YYID (yyi)
    int yyi;
#endif
{
  return yyi;
}
#endif

#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#     ifndef _STDLIB_H
#      define _STDLIB_H 1
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (YYID (0))
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined _STDLIB_H \
       && ! ((defined YYMALLOC || defined malloc) \
	     && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef _STDLIB_H
#    define _STDLIB_H 1
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
	 || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  YYSIZE_T yyi;				\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (YYID (0))
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)				\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack_alloc, Stack, yysize);			\
	Stack = &yyptr->Stack_alloc;					\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (YYID (0))

#endif

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  16
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   234

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  40
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  12
/* YYNRULES -- Number of rules.  */
#define YYNRULES  38
/* YYNRULES -- Number of states.  */
#define YYNSTATES  103

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   289

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      36,    38,     2,     2,    35,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    37,    39,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint8 yyprhs[] =
{
       0,     0,     3,     9,    13,    17,    26,    28,    35,    38,
      40,    45,    46,    47,    57,    63,    64,    71,    77,    87,
      99,   103,   107,   109,   113,   117,   121,   125,   129,   133,
     137,   141,   145,   149,   153,   155,   157,   159,   164
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int8 yyrhs[] =
{
      41,     0,    -1,    19,    42,    21,    43,    20,    -1,    21,
      43,    20,    -1,    42,    35,    34,    -1,    42,    35,    34,
      36,    33,    37,    33,    38,    -1,    34,    -1,    34,    36,
      33,    37,    33,    38,    -1,    43,    44,    -1,    44,    -1,
      51,     3,    48,    39,    -1,    -1,    -1,     4,    49,     5,
      43,    45,     6,    46,    43,     7,    -1,     4,    49,     5,
      43,     7,    -1,    -1,    14,    47,    49,    15,    43,    16,
      -1,    15,    43,    14,    49,    17,    -1,     8,    34,    18,
      50,     9,    50,    15,    43,    11,    -1,     8,    34,    18,
      50,     9,    50,    10,    50,    15,    43,    11,    -1,    12,
      51,    39,    -1,    13,    50,    39,    -1,    50,    -1,    50,
      22,    50,    -1,    50,    23,    50,    -1,    50,    24,    50,
      -1,    50,    25,    50,    -1,    50,    26,    50,    -1,    50,
      27,    50,    -1,    50,    28,    50,    -1,    50,    29,    50,
      -1,    50,    30,    50,    -1,    50,    31,    50,    -1,    50,
      32,    50,    -1,    33,    -1,    51,    -1,    34,    -1,    34,
      36,    34,    38,    -1,    34,    36,    33,    38,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   564,   564,   565,   568,   569,   570,   571,   573,   574,
     576,   578,   580,   577,   584,   587,   586,   594,   595,   596,
     597,   598,   600,   601,   602,   603,   604,   605,   608,   611,
     614,   617,   620,   623,   627,   628,   631,   632,   633
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "ASSIGN", "IF", "THEN", "ELSE", "ENDIF",
  "FOR", "TO", "DOWNTO", "ENDFOR", "READ", "WRITE", "WHILE", "DO",
  "ENDWHILE", "ENDDO", "FROM", "DECLARE", "END", "BGN", "PLUS", "MINUS",
  "TIMES", "DIV", "MOD", "EQ", "NEQ", "LE", "GE", "LEQ", "GEQ", "NUM",
  "PIDENTIFIER", "','", "'('", "':'", "')'", "';'", "$accept", "program",
  "declarations", "commands", "command", "$@1", "$@2", "$@3", "expression",
  "condition", "value", "identifier", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,    44,    40,    58,    41,    59
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    40,    41,    41,    42,    42,    42,    42,    43,    43,
      44,    45,    46,    44,    44,    47,    44,    44,    44,    44,
      44,    44,    48,    48,    48,    48,    48,    48,    49,    49,
      49,    49,    49,    49,    50,    50,    51,    51,    51
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     5,     3,     3,     8,     1,     6,     2,     1,
       4,     0,     0,     9,     5,     0,     6,     5,     9,    11,
       3,     3,     1,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     1,     1,     1,     4,     4
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       0,     0,     0,     0,     6,     0,     0,     0,     0,     0,
      15,     0,    36,     0,     9,     0,     1,     0,     0,     0,
      34,     0,     0,    35,     0,     0,     0,     0,     0,     0,
       3,     8,     0,     0,     0,     4,     0,     0,     0,     0,
       0,     0,     0,     0,    20,    21,     0,     0,     0,     0,
       0,    22,     0,     2,     0,    11,    28,    29,    30,    31,
      32,    33,     0,     0,     0,    38,    37,    10,     0,     0,
       0,     0,     0,     0,     0,    14,     0,     0,     0,    17,
      23,    24,    25,    26,    27,     7,     0,    12,     0,    16,
       0,     0,     0,     0,     5,     0,     0,     0,    13,     0,
      18,     0,    19
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
      -1,     3,     5,    13,    14,    76,    91,    27,    50,    21,
      22,    23
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -27
static const yytype_int16 yypact[] =
{
     -14,   -24,   188,    15,    -9,   -17,   -20,   -12,    -1,   -20,
     -27,   188,    23,    16,   -27,    22,   -27,     2,   188,    13,
     -27,    43,    11,   -27,    33,    21,    24,   -20,   200,    12,
     -27,   -27,   -20,    25,   110,    29,   188,   -20,   -20,   -20,
     -20,   -20,   -20,   -20,   -27,   -27,    37,   -20,    28,    30,
      31,    32,    36,   -27,    38,   127,   -27,   -27,   -27,   -27,
     -27,   -27,    64,   188,    57,   -27,   -27,   -27,   -20,   -20,
     -20,   -20,   -20,    47,    50,   -27,    69,   -20,   139,   -27,
     -27,   -27,   -27,   -27,   -27,   -27,    55,   -27,    -7,   -27,
      58,   188,   -20,   188,   -27,   152,    83,   164,   -27,   188,
     -27,   176,   -27
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
     -27,   -27,   -27,     1,   -11,   -27,   -27,   -27,   -27,   -26,
      40,    -2
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -1
static const yytype_uint8 yytable[] =
{
      15,    46,    31,    92,    18,     1,    25,     2,    93,    15,
       4,    15,    28,    20,    12,    16,    15,    31,    19,    34,
       6,    64,    24,    31,     7,    32,    15,    17,     8,     9,
      10,    11,    15,    12,    15,    33,    30,    55,    37,    38,
      39,    40,    41,    42,    31,    48,    49,    35,    36,    26,
      12,    43,    63,    15,    68,    69,    70,    71,    72,    29,
      44,    15,    52,    45,    78,    54,    65,    31,    66,    73,
      67,    74,    51,    77,    79,    87,    15,    56,    57,    58,
      59,    60,    61,    62,    31,    85,    31,    86,    90,    15,
      31,    15,    95,    15,    97,    15,    94,    15,    99,    15,
     101,     0,     0,     0,     0,     0,     0,     0,    80,    81,
      82,    83,    84,     0,     6,     0,     0,    88,     7,     0,
       0,     0,     8,     9,    10,    11,     0,     0,     0,     0,
      53,     6,    96,     0,    75,     7,     0,     0,     0,     8,
       9,    10,    11,     6,    12,     0,     0,     7,     0,     0,
       0,     8,     9,    10,    11,    89,     6,     0,     0,    98,
       7,    12,     0,     0,     8,     9,    10,    11,     6,     0,
       0,     0,     7,    12,     0,   100,     8,     9,    10,    11,
       6,     0,     0,     0,     7,     0,    12,   102,     8,     9,
      10,    11,     6,     0,     0,     0,     7,     0,    12,     0,
       8,     9,    10,    11,     6,     0,     0,     0,     7,     0,
      12,     0,     8,     9,    47,    11,     0,     0,     0,     0,
       0,     0,    12,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    12
};

static const yytype_int8 yycheck[] =
{
       2,    27,    13,    10,    21,    19,     8,    21,    15,    11,
      34,    13,    11,    33,    34,     0,    18,    28,    35,    18,
       4,    47,    34,    34,     8,     3,    28,    36,    12,    13,
      14,    15,    34,    34,    36,    33,    20,    36,    27,    28,
      29,    30,    31,    32,    55,    33,    34,    34,     5,     9,
      34,    18,    15,    55,    22,    23,    24,    25,    26,    36,
      39,    63,    37,    39,    63,    36,    38,    78,    38,    33,
      39,    33,    32,     9,    17,     6,    78,    37,    38,    39,
      40,    41,    42,    43,    95,    38,    97,    37,    33,    91,
     101,    93,    91,    95,    93,    97,    38,    99,    15,   101,
      99,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    68,    69,
      70,    71,    72,    -1,     4,    -1,    -1,    77,     8,    -1,
      -1,    -1,    12,    13,    14,    15,    -1,    -1,    -1,    -1,
      20,     4,    92,    -1,     7,     8,    -1,    -1,    -1,    12,
      13,    14,    15,     4,    34,    -1,    -1,     8,    -1,    -1,
      -1,    12,    13,    14,    15,    16,     4,    -1,    -1,     7,
       8,    34,    -1,    -1,    12,    13,    14,    15,     4,    -1,
      -1,    -1,     8,    34,    -1,    11,    12,    13,    14,    15,
       4,    -1,    -1,    -1,     8,    -1,    34,    11,    12,    13,
      14,    15,     4,    -1,    -1,    -1,     8,    -1,    34,    -1,
      12,    13,    14,    15,     4,    -1,    -1,    -1,     8,    -1,
      34,    -1,    12,    13,    14,    15,    -1,    -1,    -1,    -1,
      -1,    -1,    34,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    34
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,    19,    21,    41,    34,    42,     4,     8,    12,    13,
      14,    15,    34,    43,    44,    51,     0,    36,    21,    35,
      33,    49,    50,    51,    34,    51,    50,    47,    43,    36,
      20,    44,     3,    33,    43,    34,     5,    27,    28,    29,
      30,    31,    32,    18,    39,    39,    49,    14,    33,    34,
      48,    50,    37,    20,    36,    43,    50,    50,    50,    50,
      50,    50,    50,    15,    49,    38,    38,    39,    22,    23,
      24,    25,    26,    33,    33,     7,    45,     9,    43,    17,
      50,    50,    50,    50,    50,    38,    37,     6,    50,    16,
      33,    46,    10,    15,    38,    43,    50,    43,     7,    15,
      11,    43,    11
};

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK (1);						\
      goto yybackup;						\
    }								\
  else								\
    {								\
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;							\
    }								\
while (YYID (0))


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (YYID (N))                                                    \
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (YYID (0))
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
	      (Loc).first_line, (Loc).first_column,	\
	      (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (YYLEX_PARAM)
#else
# define YYLEX yylex ()
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (YYID (0))

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)			  \
do {									  \
  if (yydebug)								  \
    {									  \
      YYFPRINTF (stderr, "%s ", Title);					  \
      yy_symbol_print (stderr,						  \
		  Type, Value); \
      YYFPRINTF (stderr, "\n");						  \
    }									  \
} while (YYID (0))


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# else
  YYUSE (yyoutput);
# endif
  switch (yytype)
    {
      default:
	break;
    }
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_stack_print (yytype_int16 *yybottom, yytype_int16 *yytop)
#else
static void
yy_stack_print (yybottom, yytop)
    yytype_int16 *yybottom;
    yytype_int16 *yytop;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (YYID (0))


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_reduce_print (YYSTYPE *yyvsp, int yyrule)
#else
static void
yy_reduce_print (yyvsp, yyrule)
    YYSTYPE *yyvsp;
    int yyrule;
#endif
{
  int yynrhs = yyr2[yyrule];
  int yyi;
  unsigned long int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
	     yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr, yyrhs[yyprhs[yyrule] + yyi],
		       &(yyvsp[(yyi + 1) - (yynrhs)])
		       		       );
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, Rule); \
} while (YYID (0))

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static YYSIZE_T
yystrlen (const char *yystr)
#else
static YYSIZE_T
yystrlen (yystr)
    const char *yystr;
#endif
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static char *
yystpcpy (char *yydest, const char *yysrc)
#else
static char *
yystpcpy (yydest, yysrc)
    char *yydest;
    const char *yysrc;
#endif
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
	switch (*++yyp)
	  {
	  case '\'':
	  case ',':
	    goto do_not_strip_quotes;

	  case '\\':
	    if (*++yyp != '\\')
	      goto do_not_strip_quotes;
	    /* Fall through.  */
	  default:
	    if (yyres)
	      yyres[yyn] = *yyp;
	    yyn++;
	    break;

	  case '"':
	    if (yyres)
	      yyres[yyn] = '\0';
	    return yyn;
	  }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into YYRESULT an error message about the unexpected token
   YYCHAR while in state YYSTATE.  Return the number of bytes copied,
   including the terminating null byte.  If YYRESULT is null, do not
   copy anything; just return the number of bytes that would be
   copied.  As a special case, return 0 if an ordinary "syntax error"
   message will do.  Return YYSIZE_MAXIMUM if overflow occurs during
   size calculation.  */
static YYSIZE_T
yysyntax_error (char *yyresult, int yystate, int yychar)
{
  int yyn = yypact[yystate];

  if (! (YYPACT_NINF < yyn && yyn <= YYLAST))
    return 0;
  else
    {
      int yytype = YYTRANSLATE (yychar);
      YYSIZE_T yysize0 = yytnamerr (0, yytname[yytype]);
      YYSIZE_T yysize = yysize0;
      YYSIZE_T yysize1;
      int yysize_overflow = 0;
      enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
      char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
      int yyx;

# if 0
      /* This is so xgettext sees the translatable formats that are
	 constructed on the fly.  */
      YY_("syntax error, unexpected %s");
      YY_("syntax error, unexpected %s, expecting %s");
      YY_("syntax error, unexpected %s, expecting %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s");
# endif
      char *yyfmt;
      char const *yyf;
      static char const yyunexpected[] = "syntax error, unexpected %s";
      static char const yyexpecting[] = ", expecting %s";
      static char const yyor[] = " or %s";
      char yyformat[sizeof yyunexpected
		    + sizeof yyexpecting - 1
		    + ((YYERROR_VERBOSE_ARGS_MAXIMUM - 2)
		       * (sizeof yyor - 1))];
      char const *yyprefix = yyexpecting;

      /* Start YYX at -YYN if negative to avoid negative indexes in
	 YYCHECK.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;

      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yycount = 1;

      yyarg[0] = yytname[yytype];
      yyfmt = yystpcpy (yyformat, yyunexpected);

      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	  {
	    if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
	      {
		yycount = 1;
		yysize = yysize0;
		yyformat[sizeof yyunexpected - 1] = '\0';
		break;
	      }
	    yyarg[yycount++] = yytname[yyx];
	    yysize1 = yysize + yytnamerr (0, yytname[yyx]);
	    yysize_overflow |= (yysize1 < yysize);
	    yysize = yysize1;
	    yyfmt = yystpcpy (yyfmt, yyprefix);
	    yyprefix = yyor;
	  }

      yyf = YY_(yyformat);
      yysize1 = yysize + yystrlen (yyf);
      yysize_overflow |= (yysize1 < yysize);
      yysize = yysize1;

      if (yysize_overflow)
	return YYSIZE_MAXIMUM;

      if (yyresult)
	{
	  /* Avoid sprintf, as that infringes on the user's name space.
	     Don't have undefined behavior even if the translation
	     produced a string with the wrong number of "%s"s.  */
	  char *yyp = yyresult;
	  int yyi = 0;
	  while ((*yyp = *yyf) != '\0')
	    {
	      if (*yyp == '%' && yyf[1] == 's' && yyi < yycount)
		{
		  yyp += yytnamerr (yyp, yyarg[yyi++]);
		  yyf += 2;
		}
	      else
		{
		  yyp++;
		  yyf++;
		}
	    }
	}
      return yysize;
    }
}
#endif /* YYERROR_VERBOSE */


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
#else
static void
yydestruct (yymsg, yytype, yyvaluep)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
#endif
{
  YYUSE (yyvaluep);

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {

      default:
	break;
    }
}

/* Prevent warnings from -Wmissing-prototypes.  */
#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */


/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;



/*-------------------------.
| yyparse or yypush_parse.  |
`-------------------------*/

#ifdef YYPARSE_PARAM
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void *YYPARSE_PARAM)
#else
int
yyparse (YYPARSE_PARAM)
    void *YYPARSE_PARAM;
#endif
#else /* ! YYPARSE_PARAM */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void)
#else
int
yyparse ()

#endif
#endif
{


    int yystate;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus;

    /* The stacks and their tools:
       `yyss': related to states.
       `yyvs': related to semantic values.

       Refer to the stacks thru separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* The state stack.  */
    yytype_int16 yyssa[YYINITDEPTH];
    yytype_int16 *yyss;
    yytype_int16 *yyssp;

    /* The semantic value stack.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs;
    YYSTYPE *yyvsp;

    YYSIZE_T yystacksize;

  int yyn;
  int yyresult;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;

#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  yytoken = 0;
  yyss = yyssa;
  yyvs = yyvsa;
  yystacksize = YYINITDEPTH;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY; /* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */
  yyssp = yyss;
  yyvsp = yyvs;

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack.  Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	yytype_int16 *yyss1 = yyss;

	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),
		    &yystacksize);

	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	yytype_int16 *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyexhaustedlab;
	YYSTACK_RELOCATE (yyss_alloc, yyss);
	YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token.  */
  yychar = YYEMPTY;

  yystate = yyn;
  *++yyvsp = yylval;

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:

/* Line 1455 of yacc.c  */
#line 564 "parser.y"
    {printf("\nkoniecprogramu\n");;}
    break;

  case 3:

/* Line 1455 of yacc.c  */
#line 565 "parser.y"
    {printf("\nkoniecprogramu\n");;}
    break;

  case 4:

/* Line 1455 of yacc.c  */
#line 568 "parser.y"
    {make_variable((yyvsp[(3) - (3)].sval));;}
    break;

  case 6:

/* Line 1455 of yacc.c  */
#line 570 "parser.y"
    {make_variable((yyvsp[(1) - (1)].sval));;}
    break;

  case 8:

/* Line 1455 of yacc.c  */
#line 573 "parser.y"
    {printf("tas");;}
    break;

  case 9:

/* Line 1455 of yacc.c  */
#line 574 "parser.y"
    {printf("te");;}
    break;

  case 10:

/* Line 1455 of yacc.c  */
#line 576 "parser.y"
    {assign((yyvsp[(1) - (4)].ival));			;}
    break;

  case 11:

/* Line 1455 of yacc.c  */
#line 578 "parser.y"
    {(yyvsp[(2) - (4)].jval)->jmp_end= gen_code("JUMP",-1);;}
    break;

  case 12:

/* Line 1455 of yacc.c  */
#line 580 "parser.y"
    {output[(yyvsp[(2) - (6)].jval)->jmp_false].arg = output_offset;;}
    break;

  case 13:

/* Line 1455 of yacc.c  */
#line 582 "parser.y"
    {output[(yyvsp[(2) - (9)].jval)->jmp_end].arg=output_offset;;}
    break;

  case 14:

/* Line 1455 of yacc.c  */
#line 585 "parser.y"
    {output[(yyvsp[(2) - (5)].jval)->jmp_false].arg  = output_offset;;}
    break;

  case 15:

/* Line 1455 of yacc.c  */
#line 587 "parser.y"
    {(yyvsp[(1) - (1)].jval) = new_jmp_info();
				(yyvsp[(1) - (1)].jval)->jmp_prestart = output_offset;;}
    break;

  case 16:

/* Line 1455 of yacc.c  */
#line 590 "parser.y"
    {gen_code("JUMP",(yyvsp[(1) - (6)].jval)->jmp_prestart); 
				printf("%d",(yyvsp[(3) - (6)].jval)->jmp_false);
				output[(yyvsp[(3) - (6)].jval)->jmp_false].arg  = output_offset;;}
    break;

  case 20:

/* Line 1455 of yacc.c  */
#line 597 "parser.y"
    {read((yyvsp[(2) - (3)].ival));;}
    break;

  case 21:

/* Line 1455 of yacc.c  */
#line 598 "parser.y"
    {write();;}
    break;

  case 22:

/* Line 1455 of yacc.c  */
#line 600 "parser.y"
    {;}
    break;

  case 23:

/* Line 1455 of yacc.c  */
#line 601 "parser.y"
    { math::plus();;}
    break;

  case 24:

/* Line 1455 of yacc.c  */
#line 602 "parser.y"
    { math::minus();;}
    break;

  case 25:

/* Line 1455 of yacc.c  */
#line 603 "parser.y"
    { math::times();;}
    break;

  case 26:

/* Line 1455 of yacc.c  */
#line 604 "parser.y"
    { math::div();;}
    break;

  case 27:

/* Line 1455 of yacc.c  */
#line 605 "parser.y"
    { math::modulo();;}
    break;

  case 28:

/* Line 1455 of yacc.c  */
#line 608 "parser.y"
    {jmp_info* j = new_jmp_info();
													logic::eq(j);
												(yyval.jval) = j;								;}
    break;

  case 29:

/* Line 1455 of yacc.c  */
#line 611 "parser.y"
    {jmp_info* j = new_jmp_info();
												logic::neq(j);
												(yyval.jval) = j;								;}
    break;

  case 30:

/* Line 1455 of yacc.c  */
#line 614 "parser.y"
    {jmp_info* j = new_jmp_info();
												logic::le(j);
												(yyval.jval) = j;								;}
    break;

  case 31:

/* Line 1455 of yacc.c  */
#line 617 "parser.y"
    {jmp_info* j = new_jmp_info();
												logic::ge(j);
												(yyval.jval) = j;								;}
    break;

  case 32:

/* Line 1455 of yacc.c  */
#line 620 "parser.y"
    {jmp_info* j = new_jmp_info();
												logic::leq(j);
												(yyval.jval) = j;								;}
    break;

  case 33:

/* Line 1455 of yacc.c  */
#line 623 "parser.y"
    {jmp_info* j = new_jmp_info();
												logic::geq(j);
												(yyval.jval) = j;								;}
    break;

  case 34:

/* Line 1455 of yacc.c  */
#line 627 "parser.y"
    {	push_number(yylval.ival);		;}
    break;

  case 35:

/* Line 1455 of yacc.c  */
#line 628 "parser.y"
    {	pushIdValue((yyvsp[(1) - (1)].ival));					
																					;}
    break;

  case 36:

/* Line 1455 of yacc.c  */
#line 631 "parser.y"
    {	(yyval.ival) = findVar((yyvsp[(1) - (1)].sval));;}
    break;

  case 37:

/* Line 1455 of yacc.c  */
#line 632 "parser.y"
    {	(yyval.ival) = 0;;}
    break;

  case 38:

/* Line 1455 of yacc.c  */
#line 633 "parser.y"
    {	(yyval.ival) = 0;;}
    break;



/* Line 1455 of yacc.c  */
#line 2239 "parser.tab.c"
      default: break;
    }
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;

  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
      {
	YYSIZE_T yysize = yysyntax_error (0, yystate, yychar);
	if (yymsg_alloc < yysize && yymsg_alloc < YYSTACK_ALLOC_MAXIMUM)
	  {
	    YYSIZE_T yyalloc = 2 * yysize;
	    if (! (yysize <= yyalloc && yyalloc <= YYSTACK_ALLOC_MAXIMUM))
	      yyalloc = YYSTACK_ALLOC_MAXIMUM;
	    if (yymsg != yymsgbuf)
	      YYSTACK_FREE (yymsg);
	    yymsg = (char *) YYSTACK_ALLOC (yyalloc);
	    if (yymsg)
	      yymsg_alloc = yyalloc;
	    else
	      {
		yymsg = yymsgbuf;
		yymsg_alloc = sizeof yymsgbuf;
	      }
	  }

	if (0 < yysize && yysize <= yymsg_alloc)
	  {
	    (void) yysyntax_error (yymsg, yystate, yychar);
	    yyerror (yymsg);
	  }
	else
	  {
	    yyerror (YY_("syntax error"));
	    if (yysize != 0)
	      goto yyexhaustedlab;
	  }
      }
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
	{
	  /* Return failure if at end of input.  */
	  if (yychar == YYEOF)
	    YYABORT;
	}
      else
	{
	  yydestruct ("Error: discarding",
		      yytoken, &yylval);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule which action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;


      yydestruct ("Error: popping",
		  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  *++yyvsp = yylval;


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#if !defined(yyoverflow) || YYERROR_VERBOSE
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  /* Make sure YYID is used.  */
  return YYID (yyresult);
}



/* Line 1675 of yacc.c  */
#line 635 "parser.y"


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

