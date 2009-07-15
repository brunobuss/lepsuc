/* LEPSUC (LEPSUC Era Para Ser Um Compilador) - 2008/1 */

DELIM			[ \t\n]
NUMERO			[0-9]
LETRA			[A-Za-z_]

ID			{LETRA}({LETRA}|{NUMERO})*

CTE_INTEIRO		{NUMERO}+
CTE_REAL		{NUMERO}+("."{NUMERO}+)?
CTE_CHAR		"\'"."\'"
CTE_STRING		"\"".*"\""
CTE_B_V			"verdadeiro"
CTE_B_F			"falso"

COMENTARIO		"#".*"#\n"

TIPO_INTEIRO		"inteiro"
TIPO_REAL		"real"
TIPO_CHAR		"caractere"
TIPO_STRING		"caracteres"
TIPO_BOOL		"logico"
TIPO_VOID		"nada"

ATRIBUICAO		"<-"

FUNCAO_PRINCIPAL	"bigbang()!"
INICIA_BLOCO		"daqui"
ENCERRA_BLOCO		"ate aqui"
FACA			"faca!"
PORFAVOR		"por favor"
OBRIGADO		", obrigado"

SE			"SE"
SENAO			"SENAO"
FOR			"PARA"
WHILE			"ENQUANTO"
RETORNA			"retorna"

LER			"leia"
ESCREVER		"escreva"

OR			"OU"
AND			"E"
NOT			"~"

CMP_MAIOR		">"
CMP_MENOR		"<"
CMP_MAIOR_IGUAL		">="
CMP_MENOR_IGUAL		"<="
CMP_IGUAL		"=="
CMP_DIFF		"<>"

ADIC			"+"
SUBT			"-"
MULT			"*"
DIV			"/"

PROT			"prototype"
%%
	
{DELIM}			{ }
{COMENTARIO}		{ }



{CTE_INTEIRO}		{ yylval.v = yytext; return TK_CTE_INTEIRO; }
{CTE_REAL}		{ yylval.v = yytext; return TK_CTE_REAL; }
{CTE_CHAR}		{ yylval.v = yytext; return TK_CTE_CHAR; }
{CTE_STRING}		{ yylval.v = yytext; return TK_CTE_STRING; }

{CTE_B_V}		{ yylval.v = yytext; return TK_CTE_B_VERDADEIRO; }
{CTE_B_F}		{ yylval.v = yytext; return TK_CTE_B_FALSO; }

{TIPO_INTEIRO}		{ yylval.v = yytext; return TK_INTEIRO; }
{TIPO_REAL}		{ yylval.v = yytext; return TK_REAL; }
{TIPO_CHAR}		{ yylval.v = yytext; return TK_CHAR; }
{TIPO_STRING}		{ yylval.v = yytext; return TK_STRING; }
{TIPO_BOOL}		{ yylval.v = yytext; return TK_BOOL; }
{TIPO_VOID}		{ yylval.v = yytext; return TK_VOID; }

{ATRIBUICAO}		{ yylval.v = yytext; return TK_ATRIBUICAO; }

{FUNCAO_PRINCIPAL}	{ yylval.v = yytext; return TK_FUNCAO_PRINCIPAL; }
{INICIA_BLOCO}		{ yylval.v = yytext; return TK_INICIA_BLOCO; }
{ENCERRA_BLOCO}		{ yylval.v = yytext; return TK_ENCERRA_BLOCO; }
{FACA}			{ yylval.v = yytext; return TK_FACA; }
{PORFAVOR}		{ yylval.v = yytext; return TK_PORFAVOR; }
{OBRIGADO}		{ yylval.v = yytext; return TK_OBRIGADO; }

{SE}			{ yylval.v = yytext; return TK_SE; }
{SENAO}			{ yylval.v = yytext; return TK_SENAO; }
{FOR}			{ yylval.v = yytext; return TK_FOR; }
{WHILE}			{ yylval.v = yytext; return TK_WHILE; }
{RETORNA}		{ yylval.v = yytext; return TK_RETORNA; }

{LER}			{ yylval.v = yytext; return TK_LER; }
{ESCREVER}		{ yylval.v = yytext; return TK_ESCREVER; }

{OR}			{ yylval.v = yytext; return TK_OR; }
{AND}			{ yylval.v = yytext; return TK_AND; }
{NOT}			{ yylval.v = yytext; return TK_NOT; }

{CMP_MAIOR}		{ yylval.v = yytext; return TK_CMP_MAIOR; }
{CMP_MENOR}		{ yylval.v = yytext; return TK_CMP_MENOR; }
{CMP_MAIOR_IGUAL}	{ yylval.v = yytext; return TK_CMP_MAIOR_IGUAL; }
{CMP_MENOR_IGUAL}	{ yylval.v = yytext; return TK_CMP_MENOR_IGUAL; }
{CMP_IGUAL}		{ yylval.v = yytext; return TK_CMP_IGUAL; }
{CMP_DIFF}		{ yylval.v = yytext; return TK_CMP_DIFF; }


{ADIC}			{ yylval.v = yytext; return TK_ADIC; }
{SUBT}			{ yylval.v = yytext; return TK_SUBT; }
{MULT}			{ yylval.v = yytext; return TK_MULT; }
{DIV}			{ yylval.v = yytext; return TK_DIV; }

{PROT}			{ yylval.v = yytext; return TK_PROT; }

{ID}			{ yylval.v = yytext; return TK_ID; }

.			{ return *yytext; }

%%
