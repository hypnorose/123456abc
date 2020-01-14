%{
#include "parser.tab.h"
#include <stdlib.h>

%}
%option debug
%option noyywrap
num [0-9]+
ID [_a-z]+
%%
{ID} 			{	printf("found id\n");
return (PIDENTIFIER)	;				}
{num} 			{
	printf("found number\n");
	return 		(NUM);				}
[ \t\n]$		{printf("xd");}
"ASSIGN" 			{	\
	printf("found assign\n");
	return (ASSIGN);						}

%%	

