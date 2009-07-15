/* LEPSUC (LEPSUC Era Para Ser Um Compilador) - 2008/1 			    	*/
		


%{
#include <string>
#include <iostream>
using namespace std;

/* Tamanhos máximos */
#define TAM_MAX_OPERADORES 128
#define TAM_MAX_VARS 1024
#define TAM_MAX_PARAMS 1024
#define TAM_MAX_FUNCOES 1024
#define MAX_WARN_EUCACAO 10

/* Tipos auxiliares, para a construcao do compilador */
typedef struct _TIPO
{
	string tipo_base;
	int ndim;
	int tam_dim[2];
} TIPO;

typedef struct _ATRIBUTOS
{
	string v, c;
	TIPO t;
	string p;
} ATRIBUTOS;

typedef struct _TIPO_OPER
{
	string operador, op1, op2, resultado;
} TIPO_OPER;

typedef struct _SIMBOLO_VAR
{
	string nome;
	TIPO t;
} SIMBOLO_VAR;

typedef struct _PARAM
{
	string nome;
	TIPO t;
} PARAM;

typedef struct _SIMBOLO_FUNCAO
{
	string nome;
	TIPO retorno;
	int nparam;
	PARAM parametro[TAM_MAX_PARAMS];
	string lista_parametros;
} SIMBOLO_FUNCAO;

struct _NTEMP
{
	int i, r, c, s, b; //int, real, char, string, boolean
} NTEMP = {0, 0, 0, 0, 0};

struct _NTEMP_GLOBAL
{
	int i, r, c, s, b; //int, real, char, string, boolean
} NTEMP_GLOBAL = {0, 0, 0, 0, 0};


/* Variaveis de controle, globais */
SIMBOLO_VAR TS_varlocal[TAM_MAX_VARS];
SIMBOLO_VAR TS_varglobal[TAM_MAX_VARS];
SIMBOLO_FUNCAO TS_funcao[TAM_MAX_FUNCOES];

int nrotulos = 0;
int nvarlocal = 0;
int nvarglobal = 0;
int nfuncao = 0;
int ir = 0;
int nparams = 0;

int compilador_educado = 0;

string inic;


/* Operacoes validas */
TIPO_OPER tipo_operador[TAM_MAX_OPERADORES] = {
						{"+", "I", "I", "I"},
						{"+", "I", "R", "R"},
						{"+", "R", "R", "R"},
						{"+", "R", "I", "R"},
						{"+", "C", "C", "S"},
						{"+", "S", "C", "S"},
						{"+", "S", "S", "S"},
						{"+", "C", "I", "C"},

						{"-", "I", "I", "I"},
						{"-", "I", "R", "R"},
						{"-", "R", "R", "R"},
						{"-", "R", "I", "R"},

						{"*", "I", "I", "I"},
						{"*", "I", "R", "R"},
						{"*", "R", "I", "R"},
						{"*", "R", "R", "R"},

						{"/", "I", "I", "I"},
						{"/", "I", "R", "R"},
						{"/", "R", "I", "R"},
						{"/", "R", "R", "R"},

						{"==", "I", "I", "B"},
						{"==", "I", "R", "B"},
						{"==", "R", "I", "B"},
						{"==", "R", "R", "B"},
						{"==", "C", "C", "B"},
						{"==", "C", "S", "B"},
						{"==", "S", "C", "B"},
						{"==", "S", "S", "B"},
						{"==", "S", "S", "B"},

						{"<>", "I", "I", "B"},
						{"<>", "I", "R", "B"},
						{"<>", "R", "I", "B"},
						{"<>", "R", "R", "B"},
						{"<>", "C", "C", "B"},
						{"<>", "C", "S", "B"},
						{"<>", "S", "C", "B"},
						{"<>", "S", "S", "B"},
						{"<>", "S", "S", "B"},

						{">", "I", "I", "B"},
						{">", "I", "R", "B"},
						{">", "R", "I", "B"},
						{">", "R", "R", "B"},
						{">", "C", "C", "B"},
						{">", "C", "S", "B"},
						{">", "S", "C", "B"},
						{">", "S", "S", "B"},
						{">", "S", "S", "B"},

						{"<", "I", "I", "B"},
						{"<", "I", "R", "B"},
						{"<", "R", "I", "B"},
						{"<", "R", "R", "B"},
						{"<", "C", "C", "B"},
						{"<", "C", "S", "B"},
						{"<", "S", "C", "B"},
						{"<", "S", "S", "B"},
						{"<", "S", "S", "B"},

						{">=", "I", "I", "B"},
						{">=", "I", "R", "B"},
						{">=", "R", "I", "B"},
						{">=", "R", "R", "B"},
						{">=", "C", "C", "B"},
						{">=", "C", "S", "B"},
						{">=", "S", "C", "B"},
						{">=", "S", "S", "B"},
						{">=", "S", "S", "B"},

						{"<=", "I", "I", "B"},
						{"<=", "I", "R", "B"},
						{"<=", "R", "I", "B"},
						{"<=", "R", "R", "B"},
						{"<=", "C", "C", "B"},
						{"<=", "C", "S", "B"},
						{"<=", "S", "C", "B"},
						{"<=", "S", "S", "B"},
						{"<=", "S", "S", "B"},

						{"<-", "I", "I", "I"},
						{"<-", "R", "I", "R"},
						{"<-", "R", "R", "R"},
						{"<-", "C", "C", "C"},
						{"<-", "S", "C", "S"},
						{"<-", "S", "S", "S"},
						{"<-", "B", "B", "B"},

						{"OU", "B", "B", "B"},
						{"OU", "B", "I", "B"},
						{"OU", "I", "I", "B"},
						{"OU", "B", "C", "B"},
						{"OU", "C", "C", "B"},
						{"OU", "B", "R", "B"},
						{"OU", "R", "R", "B"},
						{"OU", "I", "B", "B"},
						{"OU", "C", "B", "B"},
						{"OU", "R", "B", "B"},
						{"E", "B", "B", "B"},
						{"E", "B", "I", "B"},
						{"E", "I", "I", "B"},
						{"E", "B", "C", "B"},
						{"E", "C", "C", "B"},
						{"E", "B", "R", "B"},
						{"E", "R", "R", "B"},
						{"E", "I", "B", "B"},
						{"E", "C", "B", "B"},
						{"E", "R", "B", "B"}
					  };


void yyerror(const char*);
int yylex();
int yyparse();

void erro(string msg);
void tipo_resultado(string operador, ATRIBUTOS op1, ATRIBUTOS op2, ATRIBUTOS &resultado);
void gera_codigo_operador(ATRIBUTOS &ss, ATRIBUTOS &s1, ATRIBUTOS &s2, ATRIBUTOS &s3);
void insere_varglobal (string nome, TIPO t);
void insere_varlocal (string nome, TIPO t);
void inclui_funcao(string nome, TIPO retorno, string lista_parametros);
void inclui_parametro(string nome, TIPO t);

void compilador_maleducado();

int string_inteiro(string s);

bool busca_variavelglobal (string nome, TIPO *t);
bool pode_inserir_varglobal (string nome);
bool busca_varlocal (string nome, TIPO *t);
bool busca_varparametro(string nome, TIPO *t);
bool pode_inserir_varlocal (string nome);
bool existe_funcao(string nome);
bool existe_parametro(string nome);
bool busca_funcao(string nome, TIPO *tr);
bool compara_parametros(string nome, string parametros);
bool compara_resultado(string resultado);

string inteiro_string(int n);
string gera_temp(string tipo);
string gera_rotulo();
string gera_decl_temp(string tipo, string tipo_base, int &n);
string gera_varglobal_temp();
string gera_variavellocal_temp();
string parte_vetor(TIPO t);
string quebra_codigo_lista(string vetorid, string lsttemp , string lstcodtemp);
string quebra_codigo_parametro(string nometemp, string vetorid, string lsttemp, string lstcodtemp, string tiporet);

#define YYSTYPE ATRIBUTOS

%}


%token TK_ID TK_CTE_INTEIRO TK_CTE_REAL TK_CTE_CHAR TK_CTE_STRING TK_CTE_B_VERDADEIRO TK_CTE_B_FALSO
%token TK_INTEIRO TK_REAL TK_CHAR TK_STRING TK_BOOL TK_VOID
%token TK_ATRIBUICAO
%token TK_FUNCAO_PRINCIPAL TK_INICIA_BLOCO TK_ENCERRA_BLOCO TK_FACA TK_PORFAVOR TK_OBRIGADO
%token TK_SE TK_SENAO TK_FOR TK_WHILE TK_RETORNA
%token TK_LER TK_ESCREVER
%token TK_OR TK_AND TK_NOT TK_CMP_MAIOR TK_CMP_MENOR TK_CMP_MAIOR_IGUAL TK_CMP_MENOR_IGUAL TK_CMP_IGUAL TK_CMP_DIFF
%token TK_ADIC TK_SUBT TK_MULT TK_DIV TK_PROT

%left TK_DIV TK_MULT
%left TK_ADIC TK_SUBT

%start SL

%%

SL		: S
		{
			cout << "#include <string>\n#include <iostream>\n\nusing namespace std;\n\n" +  $1.c << endl;
		}
		;

S		: VARS_GLOBAIS PROTOTIPOS BLOCO_PRIN FUNCOES 	{ $$.c = $1.c + $2.c + $3.c + $4.c; 	}
		;

PROTOTIPOS	:  PROTOTIPOS PROTOTIPO ';'	{ $$.c += $2.c; }
			|						{ $$.c = ""; }
			;

PROTOTIPO	 : TK_PROT TIPORETORNO TK_ID '('  PARAMETROS ')'
			{
				string aux;
				if (nparams >= 1)
				{
					if ($2.v == "nada")
					{
						aux = "";
						$$.c = "void " + $3.v + "(" + $5.c + ");\n";
					}
					else
					{
						aux = " &RI";
						$$.c = "void " + $3.v + "(" + $5.c + "," + $2.c + aux + ");\n";
					}
					ir = ir + 1;
				}
				else
				{
					if($2.v == "nada")
					{
						$$.c = "void " + $3.v + "();\n";
					}
					else
					{
						aux = " &RI";
						$$.c = "void " + $3.v + "(" + $2.c + aux  + ");\n";
					}
					ir = ir + 1;
				}

				inclui_funcao($3.v,$2.t, $5.p);
				nfuncao++;
				nparams = 0;
			}
			|	{ }
			;

PARAMETROS	: LISTAPARAMETROS
			|					{ $$.p = ""; }
			;

LISTAPARAMETROS	: LISTAPARAMETROS ',' PARAMETRO	{ $$.p += "#" + $3.t.tipo_base; $$.c = $$.c + "," + $3.c; }
				| PARAMETRO					{ $$.p = "#" + $1.t.tipo_base; }
				;

PARAMETRO : 	TIPORETORNO TK_ID
			{
				nparams++;
				$$.t = $1.t;
				$$.c = $1.c + " " + $2.v;
				inclui_parametro($2.v, $1.t);
				$$.p = "#" + $1.t.tipo_base;
			}
			;

VARS_GLOBAIS	: VAR_GLOBAL ';' VARS_GLOBAIS 	{ $$.c = gera_varglobal_temp(); + "\n" + $3.c; }
			|							{ $$.c = ""; }
			;

VAR_GLOBAL	: VAR_GLOBAL ',' TK_ID ARRAY
			{
				$$.t = $1.t;
				$3.t = $1.t;
				$3.t.ndim = $4.t.ndim;
				$3.t.tam_dim[0] = $4.t.tam_dim[0];
				$3.t.tam_dim[1] = $4.t.tam_dim[1];
				insere_varglobal($3.v , $1.t);
			}
			| TIPO TK_ID ARRAY
			{
				$$.t = $1.t;
				$2.t = $1.t;
				$1.t.ndim = $3.t.ndim;
				$1.t.tam_dim[0] = $3.t.tam_dim[0];
				$1.t.tam_dim[1] = $3.t.tam_dim[1];
				insere_varglobal($2.v , $1.t);
			}
			;

TIPO		: TK_INTEIRO	{ $$.t.tipo_base =  "I"; $$.v = $1.v; $$.c = "int"; }
		| TK_REAL		{ $$.t.tipo_base = "R"; $$.v = $1.v; $$.c = "float"; }
		| TK_BOOL		{ $$.t.tipo_base = "B"; $$.v = $1.v; $$.c = "char"; }
		| TK_CHAR		{ $$.t.tipo_base = "C"; $$.v = $1.v; $$.c = "char"; }
		| TK_STRING	{ $$.t.tipo_base = "S"; $$.v = $1.v; $$.c = "char *"; }
		;

ARRAY:	 '{' TK_CTE_INTEIRO '}' //TODO: Arrumar arrays
				{ $$.t.ndim = 1; $$.t.tam_dim[0] = atoi(($3.v).c_str()); $$.t.tam_dim[1] = 0; } 
		| '{' TK_CTE_INTEIRO '}' '{' TK_CTE_INTEIRO '}'
				{ $$.t.ndim = 2; $$.t.tam_dim[0] = atoi(($3.v).c_str()); $$.t.tam_dim[1] = atoi(($5.v).c_str()); }
		|
				{ $$.t.ndim = 0; $$.t.tam_dim[0] = 0; $$.t.tam_dim[1] = 0; }
		;

BLOCO_PRIN 	: TK_FUNCAO_PRINCIPAL CORPO { $$.c = "int main ()\n" + $2.c; }
			;

CORPO 	: TK_INICIA_BLOCO VARS_LOCAIS COMANDOS TK_ENCERRA_BLOCO
			{ $$.c = "{\n" + gera_variavellocal_temp() +  $3.c + "\n}\n"; }
		;

VARS_LOCAIS	: VAR_LOCAL ';' VARS_LOCAIS {}
			| {}
			;

VAR_LOCAL	: VAR_LOCAL ',' TK_ID ARRAY INICIO
			{
				$$.t = $1.t;
				$3.t = $1.t;
				$1.t.ndim = $4.t.ndim;
				$1.t.tam_dim[0] = $4.t.tam_dim[0];
				$1.t.tam_dim[1] = $4.t.tam_dim[1];
				insere_varlocal($3.v , $1.t);

				if($5.v != "")
				{
					inic +=$5.c + $3.v + "=" + $5.v + ";\n";
				}
			}
			| TIPO TK_ID ARRAY INICIO
			{
				$$.t = $1.t;
				$2.t = $1.t;
				$1.t.ndim = $3.t.ndim;
				$1.t.tam_dim[0] = $3.t.tam_dim[0];
				$1.t.tam_dim[1] = $3.t.tam_dim[1];

				insere_varlocal($2.v , $1.t);
	
				if ($4.v != "")
				{
					if (($4.v).c_str()[0] == '#')
					{
						inic += quebra_codigo_lista($2.v, $4.v , $4.c);
					}
					else
					{
						inic += $4.c;
						ATRIBUTOS ss, s1, s2, s3;
						s1 = $2;
						s2.v = "<-";
						s3 = $4;
						gera_codigo_operador(ss, s1,s2 ,s3 );
						inic += ss.c;
					}
				}
			}
			;

INICIO	: TK_ATRIBUICAO E 				{ $$.v = $2.v; $$.t = $2.t; $$.c = $2.c; }
		| TK_ATRIBUICAO  '{' LST_E '}'		{ $$.v = $3.v; $$.c = $3.c; }
		| TK_ATRIBUICAO  '{' LST_LST_E '}'	{ }
		|							{ $$.v = ""; $$.c = ""; }
		;

LST_LST_E	: LST_LST_E ',' '{' LST_E '}'		{ }
		| '{' LST_E '}'				{ }
		;

COMANDOS:	COMANDOS COMANDO	{ $$.c = $1.c + $2.c; }
			|					{ $$.c = ""; }
			;

COMANDO		: CMD_E ';'			{ }
			| CMD_FOR		{ }
			| CMD_WHILE		{ }
			| CMD_IF			{ }
			| CMD_RETURN		{ }
			| CMD_READ ';'		{ }
			| CMD_WRITE ';'		{ }
			;

CMD_READ	: TK_LER F			{ $$.c = $2.c + "cin >>" + $2.v + " ;\n"; } //TODO:Mudar para scanf?
			;

CMD_WRITE	: TK_ESCREVER  E //TODO: Mudar para printf?
			{
				if (($2.t.ndim != 0) && ($2.t.tipo_base == "S"))
				{
					$$.c = $2.c + "cout << &" + $2.v  + "<< endl;\n ";
				}
				else
				{
					$$.c = $2.c + "cout << " + $2.v  + "<< endl;\n ";
				}
			}
			;

CMD_RETURN	: TK_RETORNA E ';'
			{
				$$.c = $2.c + "RI = " + $2.v + ";\nreturn;\n";
				compara_resultado($2.t.tipo_base);
			}
			| TK_RETORNA  ';'
			;

CMD_WHILE	: TK_WHILE '(' E ')' PORFAVOR TK_FACA BLOCO OBRIGADO
			{
				string rotulo = gera_rotulo();
				string rotulo_aux = gera_rotulo();
				string teste = gera_temp("B");
				string codigo;
				codigo += $3.c;
				codigo += teste + " =" + $3.v + ";\n";

				codigo += "if (!(" + teste + ")) \n";
				codigo += "goto " + rotulo_aux + ";\n";				

				codigo += rotulo + ": ";
				codigo += $7.c;

				codigo += $3.c;
				codigo += teste + " =" + $3.v + ";\n";

				codigo += "if (" + teste + " ) \n";
				codigo += "goto " + rotulo + ";\n";
				codigo += rotulo_aux + ": ";
				$$.c = codigo;
			}
			;

CMD_FOR		: TK_FOR '(' TK_CTE_INTEIRO ',' TK_CTE_INTEIRO ')' PORFAVOR TK_FACA BLOCO OBRIGADO
			{
				string inicio = gera_temp("I");
				string fim = gera_temp("I");
				string teste = gera_temp("I");
				string rotulo = gera_rotulo();
				string codigo;

				codigo = inicio + " = " + $3.v +";\n";
				codigo += fim + " = " + $5.v +";\n";
				codigo += rotulo + " : " + $9.c;
				codigo += inicio + " = " + inicio + " + 1" + ";\n";
				codigo += teste + " = "+ inicio + " <= " + fim +";\n";
				codigo += "if(" + teste +")\n";
				codigo += "goto " + rotulo + ";\n";

				$$.c = codigo;
			}
			;


CMD_IF	: TK_SE '(' E ')' PORFAVOR TK_FACA BLOCO OBRIGADO
		{
			string codigo;
			string rotulo = gera_rotulo();
			string teste = gera_temp("B");

			codigo += $3.c;
			codigo += teste +" =  ! " + $3.v + " ;\n";
			codigo += "if("  +  teste  +   ")\n";
			codigo += "goto " + rotulo + ";\n";
			codigo += $7.c;
			codigo += rotulo + ": ;\n";

			$$.c = codigo;
		}
		| TK_SE '(' E ')' PORFAVOR TK_FACA BLOCO OBRIGADO TK_SENAO PORFAVOR TK_FACA BLOCO OBRIGADO
		{
			string codigo;
			string rotulo = gera_rotulo();
			string teste = gera_temp("B");
			string rotulo2 = gera_rotulo();

			codigo += $3.c;
			codigo += teste +" =  ! " + $3.v + " ;\n";
			codigo += "if("  +  teste  +   ")\n";
			codigo += "goto " + rotulo + ";\n";
			codigo += $7.c;
			codigo += "goto " + rotulo2 + ";\n";
			codigo += rotulo + ": ;\n";
			codigo += $12.c;
			codigo += rotulo2 + ": ;\n";

			$$.c = codigo;
		}
		;

BLOCO	: TK_INICIA_BLOCO COMANDOS TK_ENCERRA_BLOCO { $$.c = $2.c; }
		;

CMD_E	: E	{ }
		|	{ }
		;

E		: E TK_ATRIBUICAO E1 	{ $$.c = $1.c;  $2.v = "<-"; gera_codigo_operador($$,$1,$2,$3); }
		| E1					{ }
		;

E1		: E1 TK_OR E2 			{ gera_codigo_operador($$,$1,$2,$3); }
		| E1 TK_AND E2			{ gera_codigo_operador($$,$1,$2,$3); }
		| E2					{ }
		;

E2		: E2 TK_CMP_MAIOR E3			{ gera_codigo_operador($$,$1,$2,$3); }
		| E2 TK_CMP_MENOR E3			{ gera_codigo_operador($$,$1,$2,$3); }
		| E2 TK_CMP_MAIOR_IGUAL E3		{ gera_codigo_operador($$,$1,$2,$3); }
		| E2 TK_CMP_MENOR_IGUAL E3		{ gera_codigo_operador($$,$1,$2,$3); }
		| E2 TK_CMP_IGUAL E3			{ gera_codigo_operador($$,$1,$2,$3); }
		| E2 TK_CMP_DIFF E3			{ gera_codigo_operador($$,$1,$2,$3); }
		| E3							{ }
		;

E3		: E3 TK_ADIC E4		{ gera_codigo_operador($$,$1,$2,$3); }
		| E3 TK_SUBT E4		{ gera_codigo_operador($$,$1,$2,$3); }
		| E4					{ }
		;

E4		: E4 TK_MULT E5		{ gera_codigo_operador($$,$1,$2,$3); }
		| E4 TK_DIV E5			{ gera_codigo_operador($$,$1,$2,$3); }
		| F					{ }
		;

E5		: TK_NOT F	{ }
		| F			{ }
		;

F		: TK_ID
		{
			busca_variavelglobal($1.v, & $1.t);
			busca_varlocal($1.v, & $1.t);
			busca_varparametro($1.v, & $1.t);

			$$.t = $1.t;
		}
		| TK_ID '(' ')'
		{
			busca_funcao($1.v, & $1.t);
			$$ = $1;
			$$.v = gera_temp($1.t.tipo_base);
			$$.c = quebra_codigo_parametro($$.v, $1.v,  "" , "", $1.t.tipo_base);
			compara_parametros($1.v, "");
		}
		| TK_ID '(' LST_E ')'
		{

			busca_funcao($1.v, & $1.t);
			$$ = $1;

			if ($1.t.tipo_base =="V")
			{
				$$.v = "";
			}
			else
			{
				$$.v = gera_temp($1.t.tipo_base);
			}

			$$.c = quebra_codigo_parametro($$.v, $1.v,  $3.v , $3.c, $1.t.tipo_base);

			compara_parametros($1.v, $3.p);
		}
		| TK_ID '{' E '}' 
		{
			busca_variavelglobal($1.v, & $1.t);
			busca_varlocal($1.v, & $1.t);

			$$.t = $1.t;

			$$.c = $3.c;

			string aux = gera_temp($3.t.tipo_base);

			if ($3.t.ndim !=0 )
			{
				$$.c += aux + " = " + $3.v + ";\n";
				$3.v = aux;
			}

			if ($1.t.tipo_base == "S")
			{
				$$.c += aux + " = " + $3.v + "* 256" + ";\n";
				$3.v = aux;

				$$.v =  $1.v + "[" + $3.v + "]";
			}
			else
			{
				$$.v =  $1.v + "[" + $3.v + "]";
			}
		}
		| TK_ID '{' E '}' '{' E '}'
		{
			busca_variavelglobal($1.v, & $1.t);
			busca_varlocal($1.v, & $1.t);
			$$.t = $1.t;

			string codigo;

			string i = gera_temp("I");
			codigo += i	+ " = " + $3.v + ";\n";
			codigo += i + " = " + i + " * " + inteiro_string($1.t.tam_dim[1]) + ";\n";

			ATRIBUTOS ss, s1, s2, s3;
			s1.v = i;
			s1.t.tipo_base = "I";
			s2.v = "+";
			s3 = $6;
			gera_codigo_operador(ss,s1,s2,s3);

			codigo += ss.c;

			$$.c = $3.c + $6.c + codigo; 

			string aux = gera_temp($3.t.tipo_base);

			if ($1.t.tipo_base == "S")
			{
				$$.c += aux + " = " + ss.v + "* 256" + ";\n";
				$3.v = aux;

				$$.v =  $1.v + "[" + aux + "]";
			}
			else
			{
				$$.v =  $1.v + "[" + ss.v + "]";
			}

		}
		| '(' E ')'
		{
			$$.t.tipo_base = $2.t.tipo_base;
			$$.v = $2.v;
			$$.c =  $2.c;
		}
		| TK_CTE_INTEIRO 			{ $$.t.tipo_base = "I";  }	
		| TK_CTE_REAL				{ $$.t.tipo_base = "R"; }
		| TK_CTE_B_VERDADEIRO			{ $$.v = inteiro_string(1); $$.t.tipo_base = "B"; }
		| TK_CTE_B_FALSO			{ $$.v = inteiro_string(0);	$$.t.tipo_base = "B"; }
		| TK_CTE_CHAR				{ $$.t.tipo_base = "C"; }
		| TK_CTE_STRING				{ $$.t.tipo_base = "S"; }
		;

LST_E	: LST_E ',' E
		{
			$$.v += "#" + $3.v;
			$$.c += "#" + $3.c;
			$$.p += "#" + $3.t.tipo_base;
		}
		| E
		{
			$$.v = "#" + $1.v;
			$$.c = "#" + $1.c;
			$$.p += "#" + $1.t.tipo_base;
		}
		;

FUNCOES	: FUNCOES FUNCAO		{ $$.c = $1.c + $2.c; }
		|					{ $$.c = ""; }
		;

FUNCAO	: TIPORETORNO TK_ID '(' PARAMETROS ')' CORPO
		{
			string retorno;
			string aux;
			if (nparams >= 1)
			{
				if ($1.v == "nada")
				{
					aux = "";
					$$.c = "void " + $2.v + "(" + $4.c + ")\n" + $6.c;
				}
				else
				{
					aux = " &RI";
					$$.c = "void " + $2.v + "(" + $4.c + "," + $1.c + aux + ")\n" + $6.c;
				}
				ir = ir + 1;
			}
			else
			{
				if($1.v == "nada")
				{
					$$.c = "void " + $2.v + "()\n" + $6.c;
				}
				else
				{
					aux = " &RI";
					$$.c = "void " + $2.v + "(" + $1.c + aux  + ")\n" + $6.c;
				}
				ir = ir + 1;
			}
			if(busca_funcao($2.v, &$2.t) == false)
			{
				inclui_funcao($2.v, $1.t, $4.p);
				nfuncao++;
			}

			nparams = 0;
		}
		;

TIPORETORNO	: TIPO	{ $$.t = $1.t; $$.c = $1.c; }
		| TK_VOID		{ $$.t.tipo_base = "V"; }
		;

PORFAVOR	: TK_PORFAVOR		{ }
			|				{ compilador_maleducado(); }
			;

OBRIGADO		: TK_OBRIGADO		{ }
			|				{ compilador_maleducado(); }
			;

%%

#include "lex.yy.c"


/* **** FUNCOES AUXILIARES **** */
int main(int argc, char* argv[])
{
	yyparse();
}

string gera_rotulo()
{
	char rotulo[200];

	sprintf(rotulo,"ROT%d", nrotulos++);

	return rotulo;
}

string gera_varglobal_temp()
{
	int i, aux;
	string c;

	for (i = 0; i < nvarglobal; i++)
	{
		if (TS_varglobal[i].t.tipo_base == "B" || TS_varglobal[i].t.tipo_base == "I")
		{
			c += "int " + TS_varglobal[i].nome + parte_vetor(TS_varglobal[i].t) + ";\n";
		}
		else if (TS_varglobal[i].t.tipo_base == "S" )
		{
			c += "char " + TS_varglobal[i].nome + parte_vetor(TS_varglobal[i].t) + ";\n";
		}
		else if (TS_varglobal[i].t.tipo_base == "C" )
		{
			c+= "char " + TS_varglobal[i].nome +  parte_vetor(TS_varglobal[i].t) + ";\n";
		}
		else if (TS_varglobal[i].t.tipo_base == "R" )
		{
			c+= "float " + TS_varglobal[i].nome + parte_vetor(TS_varglobal[i].t) +";\n";
		}
		else
		{
			erro("Erro na gramatica");
		}
	}

	c += gera_decl_temp("int", "I", NTEMP_GLOBAL.i);
	c += gera_decl_temp("float", "R", NTEMP_GLOBAL.r);
	c += gera_decl_temp("int", "B", NTEMP_GLOBAL.b);

	aux = NTEMP_GLOBAL.s;
	c += gera_decl_temp("char", "S", NTEMP_GLOBAL.s);

	for (i = 0; i < aux; i++)
	{
		c += "TS" + inteiro_string(i) + "[255] = '\\0';\n";
	}
	
	return c;
}

void compilador_maleducado()
{
	
	if(compilador_educado > MAX_WARN_EUCACAO) erro("Programador mal educado detected!\n");
	compilador_educado++;
}

bool pode_inserir_varglobal (string nome)
{
	if (nvarglobal > TAM_MAX_VARS)
	{
		erro("Numero de variaveis globais maximo atingido.");
	}
	
	if (busca_variavelglobal(nome, NULL))
	{
		erro("Variavel global ja definida.");
	}

	return true;
}

void tipo_resultado(string operador, ATRIBUTOS op1, ATRIBUTOS op2, ATRIBUTOS &resultado)
{
	int i;
	for(i = 0; i < TAM_MAX_OPERADORES; i++)
	{
		if (tipo_operador[i].operador == operador && op1.t.tipo_base == tipo_operador[i].op1 && op2.t.tipo_base == tipo_operador[i].op2)
		{
					resultado.t.tipo_base = tipo_operador[i].resultado;
					return;
		}
	}
	resultado.t.tipo_base = "ERRO";
}

bool busca_varlocal (string nome, TIPO *t)
{
	int i;
	for(i = 0 ; i < nvarlocal; i++)
	{
		if(TS_varlocal[i].nome == nome)
		{
			if (t != NULL)
			{
				*t = TS_varlocal[i].t;
			}
			return true;
		}
	}
	return false;
}

bool busca_varparametro(string nome, TIPO *t)
{
	if (nfuncao != 0)
	{
		int i, j;
		i = nfuncao - 1;
		for(j = 0 ; j < TS_funcao[i].nparam; j++)
		{
			if (TS_funcao[i].parametro[j].nome == nome )
			{
				if (t != NULL)
				{
					*t = TS_funcao[i].parametro[j].t;
				}
				return true;
			}
		}
		return false;
	}
}

void insere_varlocal (string nome, TIPO t)
{
	if (pode_inserir_varlocal(nome) )
	{
		TS_varlocal[nvarlocal].nome = nome;
		TS_varlocal[nvarlocal].t = t;
		nvarlocal++;
	}
	else
	{
		erro("Nao foi possivel declarar a variavel local" +  nome + ".");
	}
}

string gera_decl_temp(string tipo, string tipo_base, int &n)
{
	string c;
	int i;
	for (i = 0; i < n; i++)
	{
		if(tipo_base == "S")
		{
			c += tipo + " " + "T" + tipo_base +  inteiro_string(i) + "[256];\n";
		}
		else
		{
			c += tipo + " " + "T" + tipo_base +  inteiro_string(i) + ";\n";
		}
	}
	n = 0;
	return c;
}

string quebra_codigo_lista(string vetorid, string lsttemp , string lstcodtemp)
{
	string saida;
	string a;
	string b;

	int i = 0;
	int j = 0;
	int contador = 0;
	
	getchar();
	
	while(1)
	{
		a = "";
		b = "";
		
		while(lsttemp[i] != '#' && lsttemp[i] != '\0')
		{
			a += lsttemp[i];
			i++;
		}
		
		while(lstcodtemp[j] != '#' && lstcodtemp[j] != '\0')
		{
			b += lstcodtemp[j];
			j++;
		}

		if (a[0] != '\0' || b[0] != '\0')
		{
			saida += b  + vetorid + "[" + inteiro_string(contador)+ "]" + "=" + a + ";\n";
			contador++;
		}

		if (lstcodtemp[j] == '\0')
		{
			break;
		}
		i++;
		j++;

	}
	return saida;
}

string parte_vetor(TIPO t)
{
	string codigo;

	int ehString = 1;

	if(t.tipo_base == "S")
	{
		ehString = 256;
	}

	if (t.ndim == 0)
	{
		if(ehString == 1)
		{
			codigo = "";
		}
		else
		{
			codigo = "[256]";
		}
	}
	else if (t.ndim == 1)
	{
		codigo = "[" + inteiro_string(t.tam_dim[0] * ehString) + "]";

	}
	else if (t.ndim == 2)
	{
		codigo = "[" + inteiro_string(t.tam_dim[0] * t.tam_dim[1] * ehString ) + "]";
	}
	return codigo;
}

bool busca_variavelglobal (string nome, TIPO *t)
{
	int i;
	for(i = 0; i < nvarglobal; i++)
	{
		if(TS_varglobal[i].nome == nome)
		{
			if (t != NULL)
			{
				*t = TS_varglobal[i].t;
			}
			return true;
		}
	}
	return false;
}

void inclui_parametro(string nome, TIPO t)
{
	int p;
	if(existe_parametro(nome))
	{
		erro("Parametro ja declarado.");
	}
	p = TS_funcao[nfuncao].nparam;
	TS_funcao[nfuncao].parametro[p].nome = nome;
	TS_funcao[nfuncao].parametro[p].t = t;
	TS_funcao[nfuncao].nparam++;
}

bool busca_funcao(string nome, TIPO *tr)
{
	int i;
	for(i = 0 ; i < nfuncao; i++)
	{
		if(TS_funcao[i].nome == nome)
		{
			if(tr != NULL)
			{
				*tr = TS_funcao[i].retorno;
			}
			
			return true;
		}
	}
	return false;
}

bool existe_parametro(string nome)
{
	int i;
	int j;

	for (i = 0; i < nfuncao; i++)
	{
		if (TS_funcao[i].nome == nome)
		{

			for (j = 0; j < TS_funcao[i].nparam; j++)
			{
				if (TS_funcao[i].parametro[j].nome == nome)
				{
					return true;
				}
			}

		}

	}
	return false;
}

void inclui_funcao(string nome, TIPO retorno, string lista_parametros)
{
	if(existe_funcao(nome))
	{
		erro("Funcao ja declarada.");
	}
	TS_funcao[nfuncao].nome = nome;
	TS_funcao[nfuncao].retorno = retorno;
	TS_funcao[nfuncao].lista_parametros = lista_parametros;

}

string quebra_codigo_parametro(string nometemp, string vetorid, string lsttemp, string lstcodtemp, string tiporet)
{
	string saida;
	string a;
	string b;
	string lista;
	string lista_completa;

	int i = 0, j = 0, contador = 0;

	getchar();

	while(1)
	{
		a = "";
		b = "";

		while (lsttemp[i] != '#' && lsttemp[i] != '\0')
		{
			a += lsttemp[i];
			i++;
		}

		while (lstcodtemp[j] != '#' && lstcodtemp[j] != '\0')
		{
			b += lstcodtemp[j];
			j++;
		}

		if(a[0] != '\0' || b[0] != '\0')
		{
			saida += b;
			if (a != "")
			{
				lista += a + ", ";
			}
			contador++;
		}

		if (lstcodtemp[j] == '\0')
		{
			break;
		}
		i++;
		j++;
	}
	

	if(tiporet != "V")
	{
		lista_completa = vetorid + "(" + lista + nometemp + ");\n";
		saida+= lista_completa;
		return saida;
	}
	else
	{

		int len = lista.length();
		lista[len - 2] = ' ';
		string saida = vetorid + "("+  lista + ");\n";
		return saida;
	}

}

bool pode_inserir_varlocal (string nome)
{
	if (nvarlocal > TAM_MAX_VARS)
	{
		erro("Numero de variaveis maximo atingido.");
	}
	if (busca_varlocal(nome, NULL) )
	{
		erro("Variavel ja definida.");
	}
	return true;
}

bool compara_resultado(string resultado)
{
	if (TS_funcao[nfuncao - 1].retorno.tipo_base == resultado)
	{
		return true;
	}
	else
	{
		erro("Valor retornado invalido");
		cout << nvarlocal << endl;
	}
}

bool existe_funcao(string nome)
{
	int i;
	for (i = 0; i < nfuncao; i++)
	{
		if (TS_funcao[i].nome == nome)
		{
			return true;
		}

	}
	return false;

}

bool compara_parametros(string nome, string parametros)
{
	int i;
	for(i = 0; i < nfuncao; i++)
	{
		if (TS_funcao[i].nome == nome && TS_funcao[i].lista_parametros == parametros)
		{
			return true;
		}
	}
	
	erro("Parametros invalidos.");
	return false;
}

string inteiro_string(int n)
{
	char linha[20];
	sprintf(linha, "%d", n);
	return linha;
}

string gera_temp(string tipo)
{
	char variavel[200];

	if (tipo == "I")
	{
		sprintf(variavel, "TI%d", NTEMP.i++);
	}
	else if (tipo == "R")
	{
		sprintf(variavel, "TR%d", NTEMP.r++);
	}
	else if (tipo == "C")
	{
		sprintf(variavel, "TC%d", NTEMP.c++);
	}
	else if (tipo == "S")
	{
		sprintf(variavel, "TS%d", NTEMP.s++);
	}
	else if (tipo == "B")
	{
		sprintf(variavel, "TB%d", NTEMP.b++);
	}
	return variavel;
}

int string_inteiro(string s)
{
	int n;
	sscanf(s.c_str(), "%d", &n);
	return n;
}

void yyerror (const char * st)
{
	printf("%s\n", st);
}

string gera_variavellocal_temp()
{
	int i, aux;
	string c;

	for (i = 0; i < nvarlocal; i++)
	{

		if (TS_varlocal[i].t.tipo_base == "B" || TS_varlocal[i].t.tipo_base == "I")
		{
			c += "int " + TS_varlocal[i].nome + parte_vetor(TS_varlocal[i].t) + ";\n";
		}
		else if (TS_varlocal[i].t.tipo_base == "S" )
		{
			c += "char " + TS_varlocal[i].nome + parte_vetor(TS_varlocal[i].t) + ";\n";
		}
		else if (TS_varlocal[i].t.tipo_base == "C" )
		{
			c+= "char " + TS_varlocal[i].nome + parte_vetor(TS_varlocal[i].t) + ";\n";
		}
		else if (TS_varlocal[i].t.tipo_base == "R" )
		{
			c+= "float " + TS_varlocal[i].nome + parte_vetor(TS_varlocal[i].t) + ";\n";
		}
		else
		{
			erro("Erro na gramatica");
		}

	}

	c += gera_decl_temp("int", "I", NTEMP.i);
	c += gera_decl_temp("float", "R", NTEMP.r);
	c += gera_decl_temp("int", "B", NTEMP.b);
	
	aux = NTEMP.s;
	c += gera_decl_temp("char", "S", NTEMP.s);
	
	for (i = 0; i < aux; i++)
	{
		c += "TS" + inteiro_string(i) + "[255] = '\\0';\n";
	}
	
	nvarlocal = 0;
	
	c+= inic;
	inic = "";
	
	return c;
}

void erro(string msg)
{
	cout << msg << endl;
	exit(-1);
}

void insere_varglobal (string nome, TIPO t)
{
	if (pode_inserir_varglobal(nome))
	{
		TS_varglobal[nvarglobal].nome = nome;
		TS_varglobal[nvarglobal].t = t;
		nvarglobal++;
	}
	else
	{
		erro("Nao foi possivel declarar a variavel global" +  nome + ".");
	}
}

void gera_codigo_operador(ATRIBUTOS &ss, ATRIBUTOS &s1, ATRIBUTOS &s2, ATRIBUTOS &s3)
{
	tipo_resultado(s2.v,s1,s3,ss);
	if (ss.t.tipo_base == "ERRO")
	{
		if(s1.t.tipo_base == "")
		{
			erro("'" + s1.v + "'" + " nao foi declarada.");
		}
		else if (s3.t.tipo_base == "")
		{
			erro("'" + s3.v + "'" + " nao foi declarada.");
		}
		else
		{
			erro("O operador " + s2.v + " nao se aplica a " + s1.t.tipo_base + " e " + s3.t.tipo_base + ".");
		}
	}
	else
	{
		if (s2.v == "<-")
		{
			if (s3.t.ndim != 0)
			{
				string aux = gera_temp(s3.t.tipo_base);
				ss.c = s1.c + s3.c + aux + " = " + s3.v + ";\n"+  s1.v + " = " + aux + ";\n";

				if (s1.t.tipo_base == "S")
				{
				        string aux = gera_temp(s1.t.tipo_base);
					ss.c = s1.c + s3.c;
					if (s1.t.ndim != 0)
					{
						ss.c += "strncpy(" + aux + ", &" + s3.v + ", 256);\n";
						ss.c += "strncpy(&" + s1.v+", " + aux + ", 256);\n";
					}
					else
					{
						ss.c += "strncpy(" + aux + ", &" + s3.v + ", 256);\n";
						ss.c += "strncpy(" + s1.v + "," + aux + ", 256);\n";
					}
				}
			}
			else
			{
				if (s3.t.tipo_base == "S")
				{
					string aux = gera_temp(s3.t.tipo_base);
					ss.c = s1.c + s3.c + "strncpy(" + aux + "," + s3.v + ", 256);\n";
					if (s1.t.ndim != 0)
					{
						ss.c += "strncpy(&" + s1.v + ", " + aux + ", 256);\n";
					}
					else
					{
						ss.c += "strncpy(" + s1.v + ", " + aux + ", 256);\n";
					}
				}
				else
				{
					ss.c = s1.c + s3.c + s1.v + " = " + s3.v + ";\n";
				}
			}
		}
		else
		{
			if ((s1.t.ndim != 0) && (s3.t.ndim != 0))
			{
				ss.v = gera_temp(ss.t.tipo_base);
				string aux1 = gera_temp(s3.t.tipo_base);
				string aux2 = gera_temp(s3.t.tipo_base);
				ss.c = s1.c + s3.c + aux1 + " = " + s1.v + ";\n" + aux2 + " = " + s3.v + ";\n"+ ss.v + " = " + aux1 + s2.v + aux2 + ";\n"; 
			}
			else if (s1.t.ndim != 0)
			{
				ss.v = gera_temp(ss.t.tipo_base);
				string aux1 = gera_temp(s1.t.tipo_base);
				ss.c = s1.c + s3.c + aux1 + " = " + s1.v + ";\n" + ss.v + " = " + aux1 + s2.v + s3.v + ";\n";
			}
			else if (s3.t.ndim != 0)
			{
				ss.v = gera_temp(ss.t.tipo_base);
				string aux1 = gera_temp(s3.t.tipo_base);
				ss.c = s1.c + s3.c + aux1 + " = " + s3.v + ";\n" + ss.v + " = " + s1.v + s2.v + aux1 + ";\n";
			}
			else
			{
				if (( s1.t.tipo_base == "S") || ( s3.t.tipo_base == "S"))
				{
					if (s2.v == "+")
					{
						ss.v = gera_temp(ss.t.tipo_base);
						ss.c = s1.c + s3.c + "strncpy(" + ss.v + "," + s1.v + ",256);\n" + "strcat(" + ss.v + "," + s3.v + ");\n";
						ss.t.tipo_base = "S";
					}
				}
				else
				{
					ss.v = gera_temp(ss.t.tipo_base);
					if(s2.v == "<>")
						ss.c = s1.c + s3.c + ss.v + " = " + s1.v + "==" + s3.v + ";\n";
					else if(s2.v == "OU")
						ss.c = s1.c + s3.c + ss.v + " = " + s1.v + "||" + s3.v + ";\n";
					else if(s2.v == "E")
						ss.c = s1.c + s3.c + ss.v + " = " + s1.v + "&&" + s3.v + ";\n";
					else
						ss.c = s1.c + s3.c + ss.v + " = " + s1.v + s2.v + s3.v + ";\n";
				}
			}
		}
	}
}
