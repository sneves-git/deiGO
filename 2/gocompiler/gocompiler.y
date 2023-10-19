%{
    /* ____________________________________________________________________
    |   Universidade de Coimbra - Licenciatura em Engenharia Informática    |
    |                Projeto de Compiladores 2021/22                       |
    |               Compilador para a linguagem deiGo                      |
    |                                                                      |
    | - Sofia Santos Neves nº2019220082                                    |
    | - Tatiana Silva Almeida nº2019219581                                 |
    |______________________________________________________________________|
    */
    
   
// Libraries

#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#include "y.tab.h"

int lexFlag = 0;

#ifdef DEBUG
  #define debug_print(...) fprintf(stderr, __VA_ARGS__);
#else
  #define debug_print(...)
#endif 

extern const char* types;
Node *program;
Node *auxNode;
Node *auxNode2;
Node *a;
Node *b;
 
int syntaxErrorFlag = 0;
extern int lexicalErrorFlag;
extern int strlitFlag;

// Functions 
int yylex(void);
void yyerror(const char *str);
int yylex_destroy(void); 
%}

%union{
    char *token;
    Node *node;
}

// Terminal Token
%token <token> ID STRLIT INTLIT REALLIT
%token <token> INT FLOAT32 BOOL STRING
%token <token> IF ELSE FOR WHILE RETURN RESERVED
%token <token> SEMICOLON COMMA BLANKID ASSIGN 
%token <token> STAR DIV MINUS PLUS MOD LBRACE LPAR RBRACE RPAR RSQ
%token <token> LSQ LT EQ GE GT NE NOT AND OR LE  
%token <token> VAR PRINT PARSEINT FUNC CMDARGS PACKAGE 
%token <token> error


%left COMMA
%right ASSIGN 
%left OR 
%left AND
%left EQ NE GT GE LT LE 
%left PLUS MINUS
%left STAR DIV MOD
%right NOT
%left LPAR RPAR LSQ RSQ LBRACE RBRACE

%nonassoc ELSE
%nonassoc UNARY



// Non-Terminal Token

%type <node> Program 
%type <node> Declarations 
%type <node> VarDeclaration 
%type <node> VarSpec
%type <node> VarSpecs 
%type <node> Type 
%type <node> FuncDeclaration
%type <node> Parameters
%type <node> ParameterList 
%type <node> FuncBody 
%type <node> VarsAndStatements 
%type <node> Statement 
%type <node> StatementList 
%type <node> ParseArgs 
%type <node> FuncInvocation
%type <node> FuncInv 
%type <node> Expr 
%type <node> FuncHeader
%type <node> ParamDecl
%type <node> BlockProduction

// Free Yacc Stack properly when recovering from errors
// Warning: Not POSIX Yacc compliant works well with bison 
// Throws warning -Wyacc on compilation to disable run yacc with -Wno-yacc flag.
%destructor { } Program
%destructor { if($$) {freeNode($$);} } <node>
%destructor { if($$) {free($$);} } ID REALLIT INTLIT STRLIT

%%
Program: PACKAGE ID SEMICOLON Declarations                          {debug_print("Program 1: %s %s %s Declarations\n", $1, $2, $3);$$ = program = createNode(Program, NULL); appendChild($$, $4); free($2);}
       ;

Declarations: /* epsilon */                                         {debug_print("Declarations 1: NULL\n");$$ = NULL;}
            | VarDeclaration SEMICOLON Declarations                 {debug_print("Declarations 2: VarDeclaration %s Declarations\n",  $2);$$ = $1; appendSibling($$, $3);}
            | FuncDeclaration SEMICOLON Declarations                {debug_print("Declarations 3: FuncDeclaration %s Declarations\n",  $2);$$ = $1; appendSibling($$, $3);}
            ;


VarDeclaration: VAR VarSpec                                         {debug_print("VarDeclaration 1: %s VarSpec\n", $1);$$ = $2;}
              | VAR LPAR VarSpec SEMICOLON RPAR                     {debug_print("VarDeclaration 2: %s %s VarSpec %s %s\n", $1, $2, $4, $5);$$ = $3;}
              ;

VarSpec: ID VarSpecs Type                                           {debug_print("VarSpec 1: %s VarSpecs Type\n", $1);$$ = createNode(VarDecl, NULL); appendChild($$, $3); auxNode = createNode(Id, $1); appendSibling($3, auxNode); 
                                                                     for(b = $2; b; b = b->nextSibling) {
                                                                        a = createNode($3->type, NULL);
                                                                        a->nextSibling = b->child;
                                                                        b->child = a;
                                                                     }
                                                                     appendSibling($$, $2);}
       ;

VarSpecs: COMMA ID VarSpecs                                         {debug_print("VarSpecs 1: %s %s VarSpecs\n", $1, $2);$$ = createNode(VarDecl, NULL); auxNode = createNode(Id, $2); appendChild($$, auxNode); appendSibling($$, $3);}
        | /* epsilon */                                             {debug_print("VarSpecs 2: NULL\n");$$ = NULL;}
        ;

Type: INT                                                           {debug_print("Type 1: %s\n", $1);$$ = createNode(Int, NULL);}
    | FLOAT32                                                       {debug_print("Type 2: %s\n", $1);$$ = createNode(Float32, NULL);}
    | BOOL                                                          {debug_print("Type 3: %s\n", $1);$$ = createNode(Bool, NULL);}
    | STRING                                                        {debug_print("Type 4: %s\n", $1);$$ = createNode(String, NULL);}
    ;

FuncDeclaration: FUNC FuncHeader FuncBody                           {debug_print("FuncDeclaration 1: %s FuncHeader FuncBody\n", $1);$$ = createNode(FuncDecl, NULL); appendChild($$, $2); if($3){appendSibling($2, $3);}} 
               ;

FuncHeader: ID LPAR Parameters RPAR Type                            {debug_print("FuncHeader 1: %s %s Parameters %s Type\n", $1, $2, $4);$$ = createNode(FuncHeader, NULL);auxNode = createNode(Id, $1); appendChild($$, auxNode); appendSibling(auxNode, $5); if($3){appendSibling(auxNode, $3);} }
          | ID LPAR Parameters RPAR                                 {debug_print("FuncHeader 2: %s %s Parameters %s\n", $1, $2, $4);$$ = createNode(FuncHeader, NULL);auxNode = createNode(Id, $1); appendChild($$, auxNode);if($3){ appendSibling(auxNode, $3);} }
          ;

Parameters: ParamDecl ParameterList                                 {debug_print("Parameters 1\n"); $$ = createNode(FuncParams, NULL); appendChild($$, $1); appendSibling($1, $2);}
          | /* epsilon */                                           {debug_print("Parameters 2\n"); $$ = createNode(FuncParams, NULL);}
          ;

ParameterList: COMMA ParamDecl ParameterList                        {debug_print("ParameterList 1\n");$$ = $2; appendSibling($$, $3);}
         | /* epsilon */                                            {debug_print("ParameterList 2\n");$$ = NULL;}
         ;

ParamDecl: ID Type                                                  {debug_print("ParamDecl 1\n"); $$ = createNode(ParamDecl, NULL); appendChild($$, $2); appendSibling($2, createNode(Id, $1));}
         ;

FuncBody: LBRACE VarsAndStatements RBRACE                           {debug_print("FuncBody 1\n"); $$ = createNode(FuncBody, NULL); if($2){appendChild($$, $2);}}
        ;

VarsAndStatements: /* epsilon */                                    {debug_print("VarsAndStatements 1\n");$$ = NULL;}
                 |  SEMICOLON VarsAndStatements                     {debug_print("VarsAndStatements 2\n");$$ = $2;}
                 |  VarDeclaration SEMICOLON VarsAndStatements      {debug_print("VarsAndStatements 3\n");$$ = $1; appendSibling($$, $3);}
                 |  Statement SEMICOLON VarsAndStatements           {debug_print("VarsAndStatements 4\n");if($1){$$ = $1; appendSibling($$, $3);} else{$$ = $3;}}
                 ;

Statement: ID ASSIGN Expr                                           {debug_print("statement 1\n"); $$ = createNode(Assign, NULL);  auxNode = createNode(Id, $1); appendChild($$, auxNode); appendSibling(auxNode, $3);}
         | LBRACE StatementList RBRACE                              {debug_print("statement 2\n"); if( statements($2) ){ $$ = createNode(Block, NULL); appendChild($$, $2); } else{$$ = $2;}}
         | IF Expr BlockProduction                                  {debug_print("statement 3\n");$$ = createNode(If, NULL); appendChild($$, $2);   appendSibling($2, $3); auxNode = createNode(Block, NULL); appendSibling($3, auxNode);}
         | IF Expr BlockProduction ELSE BlockProduction             {debug_print("statement 4\n");$$ = createNode(If, NULL); appendChild($$, $2);  appendSibling($2, $3); appendSibling($3, $5);}
         | FOR Expr BlockProduction                                 {debug_print("statement 5\n");$$ = createNode(For, NULL); appendChild($$, $2);  appendSibling($2, $3);}
         | FOR BlockProduction                                      {debug_print("statement 6\n"); $$ = createNode(For, NULL); appendChild($$, $2);}
         | RETURN Expr                                              {debug_print("statement 7\n");$$ = createNode(Return, NULL); appendChild($$, $2);}
         | RETURN                                                   {debug_print("statement 8\n");$$ = createNode(Return, NULL);}
         | FuncInvocation                                           {debug_print("statement 9: FuncInvocation\n");$$ = $1;}
         | ParseArgs                                                {debug_print("statement 10: ParseArgs\n");$$ = $1;}
         | PRINT LPAR Expr RPAR                                     {debug_print("statement 11: %s %s Expr %s\n", $1, $2, $4);$$ = createNode(Print, NULL); appendChild($$, $3);}
         | PRINT LPAR STRLIT RPAR                                   {debug_print("statement 12: %s %s %s %s\n", $1, $2, $3, $4);$$ = createNode(Print, NULL); appendChild($$, createNode(StrLit, $3));}
         | error                                                    {debug_print("statement 13: error\n");$$ = createNode(Error, NULL);}
         ;

BlockProduction: LBRACE StatementList RBRACE                        {$$ = createNode(Block, NULL); if($2){appendChild($$, $2);}}
               ;

StatementList: Statement SEMICOLON StatementList                    {debug_print("statementList 1: %s\n", $2); if($1){$$ = $1; appendSibling($$, $3);} else{$$ = $3;}}
             | /* epsilon */                                        {debug_print("statementList 2\n");$$ = NULL;}
             ;

ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR          {debug_print("ParseArgs 1: %s %s %s %s %s %s %s %s Expr %s %s\n", $1, $2, $3, $4, $5, $6, $7, $8, $10, $11); $$ = createNode(ParseArgs, NULL); auxNode = createNode(Id, $1); appendChild($$, auxNode);   appendSibling(auxNode, $9);}
         | ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR                         {debug_print("ParseArgs 2: %s %s %s %s %s %s error %s\n", $1, $2, $3, $4, $5, $6, $8);$$ = createNode(Error, NULL); free($1); }  /* Erro */
         ;

FuncInvocation: ID LPAR RPAR                                        {debug_print("FuncInvocation 1: %s %s %s\n", $1, $2, $3); $$ = createNode(Call, NULL); appendChild($$, createNode(Id, $1));}
              | ID LPAR error RPAR                                  {debug_print("FuncInvocation 2: %s %s error %s\n", $1, $2, $4); $$ = createNode(Call, NULL); auxNode = createNode(Id, $1); appendChild($$, auxNode); auxNode2 = createNode(Error, NULL); appendSibling(auxNode, auxNode2);} /* Erro */
              | ID LPAR Expr FuncInv RPAR                           {debug_print("FuncInvocation 3: %s %s Expr FuncInv %s\n", $1, $2, $5); $$ = createNode(Call, NULL); auxNode = createNode(Id, $1); appendChild($$, auxNode); appendSibling(auxNode, $3); if($4){appendSibling(auxNode, $4);} }
              ;

FuncInv: COMMA Expr FuncInv                                         {debug_print("FuncInv 1: %s Expr FuncInv\n", $1); $$ = $2; appendSibling($$, $3);}
       | /* epsilon */                                              {debug_print("FuncInv 2: NULL\n"); $$ = NULL;}
       ;

Expr: Expr OR Expr                                                  {debug_print("Expr 1: Expr %s Expr\n", $2); $$ = createNode(Or, NULL); appendChild($$, $1); appendSibling($1, $3);}
    | Expr AND Expr                                                 {debug_print("Expr 2: Expr %s Expr\n", $2);$$ = createNode(And, NULL); appendChild($$, $1); appendSibling($1, $3);}
    | Expr LT Expr                                                  {debug_print("Expr 3: Expr %s Expr\n", $2);$$ = createNode(Lt, NULL); appendChild($$, $1); appendSibling($1, $3);}    
    | Expr GT Expr                                                  {debug_print("Expr 4: Expr %s Expr\n", $2);$$ = createNode(Gt, NULL); appendChild($$, $1); appendSibling($1, $3);}
    | Expr EQ Expr                                                  {debug_print("Expr 5: Expr %s Expr\n", $2);$$ = createNode(Eq, NULL); appendChild($$, $1); appendSibling($1, $3);}
    | Expr NE Expr                                                  {debug_print("Expr 6: Expr %s Expr\n", $2);$$ = createNode(Ne, NULL); appendChild($$, $1); appendSibling($1, $3);}
    | Expr LE Expr                                                  {debug_print("Expr 7: Expr %s Expr\n", $2);$$ = createNode(Le, NULL); appendChild($$, $1); appendSibling($1, $3);}
    | Expr GE Expr                                                  {debug_print("Expr 8: Expr %s Expr\n", $2);$$ = createNode(Ge, NULL); appendChild($$, $1); appendSibling($1, $3);}
    | Expr PLUS Expr                                                {debug_print("Expr 9: Expr %s Expr\n", $2);$$ = createNode(Add, NULL); appendChild($$, $1); appendSibling($1, $3);}
    | Expr MINUS Expr                                               {debug_print("Expr 10: Expr %s Expr\n", $2);$$ = createNode(Sub, NULL); appendChild($$, $1); appendSibling($1, $3);}
    | Expr STAR Expr                                                {debug_print("Expr 11: Expr %s Expr\n", $2);$$ = createNode(Mul, NULL); appendChild($$, $1); appendSibling($1, $3);}
    | Expr DIV Expr                                                 {debug_print("Expr 12: Expr %s Expr\n", $2);$$ = createNode(Div, NULL); appendChild($$, $1); appendSibling($1, $3);}
    | Expr MOD Expr                                                 {debug_print("Expr 13: Expr %s Expr\n", $2);$$ = createNode(Mod, NULL); appendChild($$, $1); appendSibling($1, $3);}
    | NOT Expr                                                      {debug_print("Expr 14: %s Expr\n", $1);$$ = createNode(Not, NULL); appendChild($$, $2);}
    | MINUS Expr %prec UNARY                                        {debug_print("Expr 15: %s Expr\n", $1);$$ = createNode(Minus, NULL); appendChild($$, $2);}
    | PLUS Expr %prec UNARY                                         {debug_print("Expr 16: %s Expr\n", $1);$$ = createNode(Plus, NULL); appendChild($$, $2);}
    | INTLIT                                                        {debug_print("Expr 17: %s\n", $1);$$ = createNode(IntLit, $1);}
    | REALLIT                                                       {debug_print("Expr 18: %s\n", $1);$$ = createNode(RealLit, $1);}
    | ID                                                            {debug_print("Expr 19: %s\n", $1);$$ = createNode(Id, $1);}
    | FuncInvocation                                                {debug_print("Expr 20: FuncInvocation\n");$$ = $1;}
    | LPAR Expr RPAR                                                {debug_print("Expr 21: %s Expr %s\n", $1, $3);$$ = $2;}
    | LPAR error RPAR                                               {debug_print("Expr 22: %s error %s\n", $1, $3);$$ = createNode(Error, NULL);}
    ;

%%
/*
O analisador deverá chamar-se gocompiler, ler o ficheiro a processar através do stdin e emitir
todos os resultados para o stdout. Quando invocado com a opção -t deve imprimir a árvore de
sintaxe tal como se especifica nas secções seguintes. Para manter a compatibilidade com a fase
anterior, se o analisador for invocado com a opção -l deverá realizar apenas a análise lexical,
emitir os tokens e as mensagens de erro para o stdout e terminar.
Se não for passada qualquer opção, o analisador deve apenas escrever no stdout as mensagens
de erro correspondentes aos erros lexicais e de sintaxe.
*/
int tree_flag = 0;

void flagCheck(int argc, char* argv[]){
    for (int i = 1; i < argc; ++i){
        if(strcmp(argv[i], "-t") == 0){ //Tree print
            tree_flag = 1;
            break;
        }
        else if(strcmp(argv[i], "-l") == 0){ //Only Lexical Analises
            lexFlag = 1;
            break;
        }
    }
}

int main(int argc, char *argv[]) {
    
    flagCheck(argc, argv);

    if(lexFlag == 1){
        return yylex();
    } else{
        yyparse();
        if(tree_flag == 1 && syntaxErrorFlag == 0){
            printAST(program,0); 
        }
        freeNode(program);
    } 
    yylex_destroy(); 
    
    return 0;
}





