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
#include "symbol_table.h"
#include "y.tab.h"
#include "semantics.h"
int lexFlag = 0;

#ifdef DEBUG
  #define debug_print(...) fprintf(stderr, __VA_ARGS__);
#else
  #define debug_print(...)
#endif 


extern sym_table *sym_head;

Node *program;
Node *auxNode;
Node *auxNode2;
Node *a;
Node *b;
 
int syntaxErrorFlag = 0;
extern int semantic_error;
extern int lexicalErrorFlag;
extern int strlitFlag;



// Functions 
int yylex(void);
void yyerror(const char *str);
int yylex_destroy(void); 
Data NULL_VALUE = {.value = NULL, .line = -1, .column = -1};
Data auxData;
%}

%union{
    Data token;
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
/*
%destructor { } Program
%destructor { if($$) {freeNode($$);} } <node>
%destructor { free($$.value); } ID REALLIT INTLIT STRLIT
*/


%%
Program: PACKAGE ID SEMICOLON Declarations                          {$$ = program = createNode(Program, NULL_VALUE); appendChild($$, $4); free($2.value);}
       ;

Declarations: /* epsilon */                                         {$$ = NULL;}
            | VarDeclaration SEMICOLON Declarations                 {$$ = $1; appendSibling($$, $3);}
            | FuncDeclaration SEMICOLON Declarations                {$$ = $1; appendSibling($$, $3);}
            ;

VarDeclaration: VAR VarSpec                                         {$$ = $2;}
              | VAR LPAR VarSpec SEMICOLON RPAR                     {$$ = $3;}
              ;

VarSpec: ID VarSpecs Type                                           {$$ = createNode(VarDecl, NULL_VALUE);  appendChild($$, $3); auxNode = createNode(Id, $1); appendSibling($3, auxNode); 
                                                                     for(b = $2; b; b = b->nextSibling) {
                                                                        a = createNode($3->type, NULL_VALUE);
                                                                        a->nextSibling = b->child;
                                                                        b->child = a;
                                                                     }
                                                                     appendSibling($$, $2);}
       ;

VarSpecs: COMMA ID VarSpecs                                         {$$ = createNode(VarDecl, NULL_VALUE); auxNode = createNode(Id, $2); appendChild($$, auxNode); appendSibling($$, $3);}
        | /* epsilon */                                             {$$ = NULL;}
        ;

Type: INT                                                           {$$ = createNode(Int, $1);}
    | FLOAT32                                                       {$$ = createNode(Float32, $1);}
    | BOOL                                                          {$$ = createNode(Bool, $1);}
    | STRING                                                        {$$ = createNode(String, $1);}
    ;

FuncDeclaration: FUNC FuncHeader FuncBody                           {$$ = createNode(FuncDecl, NULL_VALUE); appendChild($$, $2); if($3){appendSibling($2, $3);}} 
               ;

FuncHeader: ID LPAR Parameters RPAR Type                            {$$ = createNode(FuncHeader, NULL_VALUE);auxNode = createNode(Id, $1); appendChild($$, auxNode); appendSibling(auxNode, $5); if($3){appendSibling(auxNode, $3);} }
          | ID LPAR Parameters RPAR                                 {$$ = createNode(FuncHeader, NULL_VALUE);auxNode = createNode(Id, $1); appendChild($$, auxNode);if($3){ appendSibling(auxNode, $3);} }
          ;

Parameters: ParamDecl ParameterList                                 {$$ = createNode(FuncParams, NULL_VALUE); appendChild($$, $1); appendSibling($1, $2);}
          | /* epsilon */                                           {$$ = createNode(FuncParams, NULL_VALUE);}
          ;

ParameterList: COMMA ParamDecl ParameterList                        {$$ = $2; appendSibling($$, $3);}
         | /* epsilon */                                            {$$ = NULL;}
         ;

ParamDecl: ID Type                                                  {$$ = createNode(ParamDecl, NULL_VALUE); appendChild($$, $2); appendSibling($2, createNode(Id, $1));}
         ;

FuncBody: LBRACE VarsAndStatements RBRACE                           {$$ = createNode(FuncBody, NULL_VALUE); if($2){appendChild($$, $2);}}
        ;

VarsAndStatements: /* epsilon */                                    {$$ = NULL;}
                 |  SEMICOLON VarsAndStatements                     {$$ = $2;}
                 |  VarDeclaration SEMICOLON VarsAndStatements      {$$ = $1; appendSibling($$, $3);}
                 |  Statement SEMICOLON VarsAndStatements           {if($1){$$ = $1; appendSibling($$, $3);} else{$$ = $3;}}
                 ;

Statement: ID ASSIGN Expr                                           {$$ = createNode(Assign, $2);  auxNode = createNode(Id, $1); auxNode->is_expr = true; appendChild($$, auxNode); appendSibling(auxNode, $3);}
         | LBRACE StatementList RBRACE                              {if( statements($2) ){ $$ = createNode(Block, NULL_VALUE); appendChild($$, $2); } else{$$ = $2;}}
         | IF Expr BlockProduction                                  {$$ = createNode(If, $1); appendChild($$, $2);   appendSibling($2, $3); auxNode = createNode(Block, NULL_VALUE); appendSibling($3, auxNode);}
         | IF Expr BlockProduction ELSE BlockProduction             {$$ = createNode(If, $1); appendChild($$, $2);  appendSibling($2, $3); appendSibling($3, $5);}
         | FOR Expr BlockProduction                                 {$$ = createNode(For, $1); appendChild($$, $2);  appendSibling($2, $3);}
         | FOR BlockProduction                                      {$$ = createNode(For, $1); appendChild($$, $2);}
         | RETURN Expr                                              {$$ = createNode(Return, $1); appendChild($$, $2);}
         | RETURN                                                   {$$ = createNode(Return, $1);}
         | FuncInvocation                                           {$$ = $1;}
         | ParseArgs                                                {$$ = $1;}
         | PRINT LPAR Expr RPAR                                     {$$ = createNode(Print, $1); appendChild($$, $3);}
         | PRINT LPAR STRLIT RPAR                                   {$$ = createNode(Print, $1); appendChild($$, createNode(StrLit, $3));}
         | error                                                    {$$ = createNode(Error, $1);}
         ;

BlockProduction: LBRACE StatementList RBRACE                        {$$ = createNode(Block, NULL_VALUE); if($2){appendChild($$, $2);}}
               ;

StatementList: Statement SEMICOLON StatementList                    {if($1){$$ = $1; appendSibling($$, $3);} else{$$ = $3;}}
             | /* epsilon */                                        {$$ = NULL;}
             ;

ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR          {$$ = createNode(ParseArgs, $5); auxNode = createNode(Id, $1);  auxNode->is_expr = true; appendChild($$, auxNode); appendSibling(auxNode, $9);}
         | ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR                         {$$ = createNode(Error, $5); free($1.value); }  /* Erro */
         ;

FuncInvocation: ID LPAR RPAR                                        {$$ = createNode(Call, $2); auxNode = createNode(Id, $1); auxNode->is_expr = true; appendChild($$, auxNode);}
              | ID LPAR error RPAR                                  {$$ = createNode(Call, $2); auxNode = createNode(Id, $1); auxNode->is_expr = true; appendChild($$, auxNode); auxNode2 = createNode(Error, NULL_VALUE); appendSibling(auxNode, auxNode2);} /* Erro */
              | ID LPAR Expr FuncInv RPAR                           {$$ = createNode(Call, $2); auxNode = createNode(Id, $1); auxNode->is_expr = true; appendChild($$, auxNode); appendSibling(auxNode, $3); if($4){appendSibling(auxNode, $4);} }
              ;

FuncInv: COMMA Expr FuncInv                                         {$$ = $2; appendSibling($$, $3);}
       | /* epsilon */                                              {$$ = NULL;}
       ;

Expr: Expr OR Expr                                                  {$$ = createNode(Or, $2); appendChild($$, $1); appendSibling($1, $3);}
    | Expr AND Expr                                                 {$$ = createNode(And, $2); appendChild($$, $1); appendSibling($1, $3);}
    | Expr LT Expr                                                  {$$ = createNode(Lt, $2); appendChild($$, $1); appendSibling($1, $3);}    
    | Expr GT Expr                                                  {$$ = createNode(Gt, $2); appendChild($$, $1); appendSibling($1, $3);}
    | Expr EQ Expr                                                  {$$ = createNode(Eq, $2); appendChild($$, $1); appendSibling($1, $3);}
    | Expr NE Expr                                                  {$$ = createNode(Ne, $2); appendChild($$, $1); appendSibling($1, $3);}
    | Expr LE Expr                                                  {$$ = createNode(Le, $2); appendChild($$, $1); appendSibling($1, $3);}
    | Expr GE Expr                                                  {$$ = createNode(Ge, $2); appendChild($$, $1); appendSibling($1, $3);}
    | Expr PLUS Expr                                                {$$ = createNode(Add, $2); appendChild($$, $1); appendSibling($1, $3);}
    | Expr MINUS Expr                                               {$$ = createNode(Sub, $2); appendChild($$, $1); appendSibling($1, $3);}
    | Expr STAR Expr                                                {$$ = createNode(Mul, $2); appendChild($$, $1); appendSibling($1, $3);}
    | Expr DIV Expr                                                 {$$ = createNode(Div, $2); appendChild($$, $1); appendSibling($1, $3);}
    | Expr MOD Expr                                                 {$$ = createNode(Mod, $2); appendChild($$, $1); appendSibling($1, $3);}
    | NOT Expr                                                      {$$ = createNode(Not, $1); appendChild($$, $2);}
    | MINUS Expr %prec UNARY                                        {$$ = createNode(Minus, $1); appendChild($$, $2);}
    | PLUS Expr %prec UNARY                                         {$$ = createNode(Plus, $1); appendChild($$, $2);}
    | INTLIT                                                        {$$ = createNode(IntLit, $1);}
    | REALLIT                                                       {$$ = createNode(RealLit, $1);}
    | ID                                                            {$$ = createNode(Id, $1); $$->is_expr = true;}
    | FuncInvocation                                                {$$ = $1;}
    | LPAR Expr RPAR                                                {$$ = $2;}
    | LPAR error RPAR                                               {$$ = createNode(Error, NULL_VALUE);}
    ;

%%

/*
================================================================================================================
*/
int tree_flag = 0;
int table_flag = 0;

void flagCheck(int argc, char* argv[]){
    for (int i = 1; i < argc; ++i){
        if(strcmp(argv[i], "-t") == 0){ //Tree print
            tree_flag = 1;
            break;
        }
        else if(strcmp(argv[i], "-l") == 0){ //Only Lexical Analises
            lexFlag = 1;
            break;
        }else if(strcmp(argv[i], "-s") == 0){ //print symbol tables and abstract tree 
            table_flag = 1;
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
            printAST(program, 0, 0); 
        }
        if(syntaxErrorFlag == 0){
            //build table analise semantica
            create_symbol_table(program);
            semantic_analysis(program);
            check_if_unused();

            //verificar se semantic error = 0
            if(table_flag == 1 && semantic_error == 0){ 
                print_symbol_table(sym_head);
                printAST(program, 0, 1); 
            }
        }
        freeNode(program);
        free_symbol_table_list(sym_head);
    } 
    yylex_destroy(); 
    return 0;
}





