%{
#include "parser.tab.h"
#include <string.h>
%}
%option noyywrap
%option yylineno
num [-]?[0-9]+
ID [_a-z]+
%x COMMENT
%%
\[					{BEGIN(COMMENT); }
<COMMENT>\]			{ BEGIN(INITIAL);}
<COMMENT>\n 		{}
<COMMENT>.			{}
{ID} 				{yylval.sval = strdup(yytext);
						return PIDENTIFIER	;			}
{num} 				{	yylval.ival = atoll(yytext);
						return NUM;						}


"BEGIN"				{ 	return BGN;		 				}						
DECLARE				{	return DECLARE;					}

WRITE 				{	return WRITE;					}
ASSIGN 				{	return ASSIGN;	 				}
IF 					{	return IF;						}
THEN 				{	return THEN;					}
ELSE 				{	return ELSE;					}
ENDIF 				{	return ENDIF;					}
FOR 				{	return FOR;						}
TO 					{	return TO;						}
DOWNTO 				{	return DOWNTO;					}
WHILE 				{	return WHILE;					}
ENDWHILE 			{	return ENDWHILE;				}
ENDDO 				{	return ENDDO;					}
ENDFOR 				{	return ENDFOR;					}
FROM 				{	return FROM;					}
READ 				{	return READ;					}
DO 					{	return DO;						}
PLUS 				{	return PLUS;					}
END					{	return END;						}
MINUS 				{	return MINUS;					}
TIMES 				{	return TIMES;					}
DIV 				{	return DIV;						}
MOD 				{	return MOD;						}

EQ 					{	return EQ;						}
NEQ 				{	return NEQ;						}
LE 					{	return LE;						}
GE 					{	return GE;						}
LEQ 				{	return LEQ;						}
GEQ 				{	return GEQ;						}
[:;,\(\)]			{	return yytext[0];				}
[ \t\n]+			{	;				}
.|\n  				{ }



%%	

