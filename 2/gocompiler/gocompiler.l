%X MULTI_COMMENT STRLIT_STATE 
%{
    /* ____________________________________________________________________
    |   Universidade de Coimbra - Licenciatura em Engenharia Informática   |
    |                Projeto de Compiladores 2021/22                       |
    |               Compilador para a linguagem deiGo                      |
    |                                                                      |
    | - Sofia Santos Neves nº2019220082                                    |
    | - Tatiana Silva Almeida nº2019219581                                 |
    |______________________________________________________________________|
    */

    #include <stdio.h>
    #include <string.h>
    #include "ast.h"
    #include "y.tab.h"

    extern int lexFlag;
    int strlitFlag = 0;


    bool add_semicolon();
    void verification_octal(char*, int);

    #define illegal_char_error(line_num, column_num, yytext) printf("Line %d, column %d: illegal character (%s)\n", line_num, column_num, yytext); 
    #define unterminated_string_literal_error(aux_line, aux_column) printf("Line %d, column %d: unterminated string literal\n", aux_line, aux_column);
    #define unterminated_comment_error(aux_line, aux_column) printf("Line %d, column %d: unterminated comment\n", aux_line, aux_column);
    #define invalid_escape_sequence_error(line_num, column_num, yytext) printf("Line %d, column %d: invalid escape sequence (%s)\n", line_num, column_num, yytext); 
    #define invalid_octal_constant(line_num, column_num, number) printf("Line %d, column %d: invalid octal constant (%s)\n", line_num, column_num, number); 
 
    #define printLex(...) strlitFlag = 0; if (lexFlag==1){ printf(__VA_ARGS__);} 
    #define returnLex(...) if(lexFlag==0) return __VA_ARGS__; 

    bool aux = false;
    extern int syntaxErrorFlag;
    
    int newlineFlag = 0;
    int line_num = 1, column_num = 1, aux_column, aux_line, flag=0, flag_str_validation = 0;
    char quotationMark[3] = "\"";
    int lineStart=0, columnStart=0;
    
%}


CHAR                                                            [a-zA-Z]
NUMBER                                                          [0-9]
ALPHANUMERIC                                                    ({CHAR}|{NUMBER})

/* ID */
ID                                                              ({CHAR}|_)({ALPHANUMERIC}|_)*

/* STRLIT */
STRLIT_DELIMITER                                                \"
STRLIT_INVALID                                                  (\r|\n|\"\")
ESQ_SEQ                                                         (\\f|\\n|\\r|\\t|\\\\|\\\")
STRLIT                                                          ({ESQ_SEQ}|[^\\\"\r\n])*

/* INTLIT */
OCTAL_BASE                                                      (0)
HEX_BASE                                                        (0x|0X)
HEX_LETTERS                                                     [a-fA-F]
INTLIT                                                          (({OCTAL_BASE}?[0-7]+)|({HEX_BASE}({HEX_LETTERS}|{NUMBER})+))

/* REALLIT */
EXPONENT                                                        [eE][+-]?{NUMBER}+
NUMBERS                                                         {NUMBER}+
REALLIT                                                         ({NUMBERS}(("."(({NUMBERS}?{EXPONENT}?))|{EXPONENT}))|("."({NUMBERS}{EXPONENT}?)))


IGNORE                                                          (" "|\t)
NEWLINE                                                         (\r\n|\n|\r)
SEMICOLON                                                       ";"
COMMA                                                           ","
BLANKID                                                         "_"
ASSIGN                                                          "="
STAR                                                            "*"
DIV                                                             "/"
MINUS                                                           "-"
PLUS                                                            "+"
EQ                                                              "=="
GE                                                              ">="  
GT                                                              ">"
LBRACE                                                          "{"
LE                                                              "<="
LPAR                                                            "("
LSQ                                                             "["
LT                                                              "<"
MOD                                                             "%"
NE                                                              "!="
NOT                                                             "!"
AND                                                             "&&"
OR                                                              "||"
RBRACE                                                          "}"
RPAR                                                            ")"
RSQ                                                             "]"
PACKAGE                                                         "package"
RETURN                                                          "return"
ELSE                                                            "else"
FOR                                                             "for"
IF                                                              "if"
VAR                                                             "var"
INT                                                             "int"
FLOAT32                                                         "float32"
BOOL                                                            "bool"
STRING                                                          "string"  
PRINT                                                           "fmt.Println"
PARSEINT                                                        "strconv.Atoi"
FUNC                                                            "func"
CMDARGS                                                         "os.Args"
COMMENT_BARS                                                    "//".*
COMMENT                                                         "/*"

RESERVED                                                        ("break"|"default"|"func"|"interface"|"select"|"case"|"defer"|"go"|"map"|"struct"|"chan"|"else"|"goto"|"package"|"switch"|"const"|"fallthrough"|"if"|"range"|"type"|"continue"|"for"|"import"|"return"|"var"|"++"|"--")



%%
    /* MULTILINE COMMENT */
{COMMENT}                                                       {BEGIN MULTI_COMMENT; aux_line = line_num; aux_column = column_num; column_num += yyleng;}
<MULTI_COMMENT><<EOF>>                                          {unterminated_comment_error(aux_line, aux_column);  column_num += yyleng; flag = 0; BEGIN 0;}
<MULTI_COMMENT>"*/"                                             {BEGIN 0; column_num += yyleng; } 
<MULTI_COMMENT>{NEWLINE}                                        {line_num++; column_num = 1;}
<MULTI_COMMENT>.                                                {column_num += yyleng; }


    /* STRLIT */
{STRLIT_DELIMITER}                                              {BEGIN STRLIT_STATE; flag_str_validation = 0; aux_line = line_num; aux_column = column_num; column_num += yyleng; flag = 0;}
<STRLIT_STATE>\\                                                {invalid_escape_sequence_error(line_num, column_num, yytext); column_num += yyleng; flag_str_validation = 1;}
<STRLIT_STATE>\\([^\"fnrt\\\r\n])                               {invalid_escape_sequence_error(line_num, column_num, yytext); column_num += yyleng; flag_str_validation = 1;}
<STRLIT_STATE>{STRLIT}?{NEWLINE}                                {unterminated_string_literal_error(aux_line, aux_column); column_num = 1; line_num++; flag_str_validation = 1; BEGIN 0; }
<STRLIT_STATE>{STRLIT}?{STRLIT_DELIMITER}                       {if(flag_str_validation == 0){ printLex("STRLIT(\"%s)\n", yytext); flag = 1; yylval.token = strdup( yytext); strlitFlag = 1;column_num += yyleng; BEGIN 0; returnLex(STRLIT);} else{column_num += yyleng; BEGIN 0;} }
<STRLIT_STATE>{STRLIT}?                                         {column_num += yyleng; flag_str_validation = 1;}
<STRLIT_STATE><<EOF>>                                           {unterminated_string_literal_error(aux_line, aux_column); flag_str_validation = 1; column_num += yyleng; BEGIN 0;}


    /* INTLIT */
{OCTAL_BASE}{NUMBER}+                                           {verification_octal(yytext, yyleng); column_num += yyleng; if(flag == 1){ newlineFlag = 0; yylval.token = strdup(yytext); returnLex(INTLIT);} }
{HEX_BASE}({HEX_LETTERS}|{NUMBER})+                             {printLex("INTLIT(%s)\n", yytext); column_num += yyleng; flag = 1; newlineFlag = 0; yylval.token = strdup(yytext); returnLex(INTLIT);}
{NUMBER}+                                                       {printLex("INTLIT(%s)\n", yytext); column_num += yyleng; flag = 1; newlineFlag = 0; yylval.token = strdup(yytext); returnLex(INTLIT);}



    /*TOKENS */
{SEMICOLON}                                                     {printLex("SEMICOLON\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(SEMICOLON);}
{COMMA}                                                         {printLex("COMMA\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(COMMA);}
{BLANKID}                                                       {printLex("BLANKID\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(BLANKID);}
{ASSIGN}                                                        {printLex("ASSIGN\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(ASSIGN);}
{STAR}                                                          {printLex("STAR\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(STAR);}
{DIV}                                                           {printLex("DIV\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(DIV);}
{MINUS}                                                         {printLex("MINUS\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(MINUS);}
{PLUS}                                                          {printLex("PLUS\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(PLUS);} 
{EQ}                                                            {printLex("EQ\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(EQ);}
{GE}                                                            {printLex("GE\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(GE);}   
{GT}                                                            {printLex("GT\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(GT);}
{LBRACE}                                                        {printLex("LBRACE\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(LBRACE);}
{LE}                                                            {printLex("LE\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(LE);}
{LPAR}                                                          {printLex("LPAR\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(LPAR);}
{LSQ}                                                           {printLex("LSQ\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(LSQ);}
{LT}                                                            {printLex("LT\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(LT);}
{MOD}                                                           {printLex("MOD\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(MOD);}
{NE}                                                            {printLex("NE\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(NE);}
{NOT}                                                           {printLex("NOT\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(NOT);}
{AND}                                                           {printLex("AND\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(AND);}
{OR}                                                            {printLex("OR\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(OR);}
{RBRACE}                                                        {printLex("RBRACE\n"); column_num += yyleng; flag = 1; newlineFlag = 0; returnLex(RBRACE);}
{RPAR}                                                          {printLex("RPAR\n"); column_num += yyleng; flag = 1; newlineFlag = 0; returnLex(RPAR);}
{RSQ}                                                           {printLex("RSQ\n"); column_num += yyleng; flag = 1; newlineFlag = 0; returnLex(RSQ);}
{PACKAGE}                                                       {printLex("PACKAGE\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(PACKAGE);}
{ELSE}                                                          {printLex("ELSE\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(ELSE);}
{FOR}                                                           {printLex("FOR\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(FOR);}
{IF}                                                            {printLex("IF\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(IF);}
{VAR}                                                           {printLex("VAR\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(VAR);}
{INT}                                                           {printLex("INT\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(INT);}
{FLOAT32}                                                       {printLex("FLOAT32\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(FLOAT32);}
{RETURN}                                                        {printLex("RETURN\n"); column_num += yyleng; flag = 1; newlineFlag = 0; returnLex(RETURN);}
{BOOL}                                                          {printLex("BOOL\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(BOOL);}
{STRING}                                                        {printLex("STRING\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(STRING);}  
{PRINT}                                                         {printLex("PRINT\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(PRINT);}
{PARSEINT}                                                      {printLex("PARSEINT\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(PARSEINT);}
{FUNC}                                                          {printLex("FUNC\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(FUNC);}
{CMDARGS}                                                       {printLex("CMDARGS\n"); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(CMDARGS); }

{NEWLINE}                                                       { newlineFlag = 1; lineStart = line_num; columnStart = column_num; line_num++; column_num = 1; aux = add_semicolon(); if(aux){returnLex(SEMICOLON);}}
{IGNORE}                                                        {column_num += yyleng; newlineFlag = 0;}
{COMMENT_BARS}                                                  {aux = add_semicolon(); column_num += yyleng; if(aux){returnLex(SEMICOLON);}}  

{RESERVED}                                                      {printLex("RESERVED(%s)\n", yytext); column_num += yyleng; flag = 0; newlineFlag = 0; returnLex(RESERVED);}
{ID}                                                            {printLex("ID(%s)\n", yytext); column_num += yyleng; flag = 1; yylval.token = strdup(yytext); newlineFlag = 0; returnLex(ID);}
{REALLIT}                                                       {printLex("REALLIT(%s)\n", yytext); column_num += yyleng; flag = 1; yylval.token = strdup(yytext); newlineFlag = 0; returnLex(REALLIT);}

.                                                               {illegal_char_error( line_num, column_num, yytext); column_num += yyleng; flag = 0; }
<<EOF>>                                                         {aux = add_semicolon(); if(aux){returnLex(SEMICOLON);}  newlineFlag = 0; column_num += yyleng; return 0;} 

%%


int yywrap(){
    return 1;
}

bool add_semicolon(){
    if(flag == 1){ 
        printLex("SEMICOLON\n");
        flag = 0;
        return true; 
    }
    return false;
}


void verification_octal(char* number, int tam){

    for(int i = 0; i < tam; ++i){
        if(number[i] == '9' || number[i] == '8'){
          invalid_octal_constant(line_num, column_num, number);
          flag = 0;
          return;
        }
    }
    printLex("INTLIT(%s)\n", number); 
    flag = 1;
    return;
}

void yyerror (const char *s) { 
    if(strlitFlag == 1){
        printf("Line %d, column %d: %s: \"%s\n", line_num, column_num - yyleng - 1, s, yytext);
        strlitFlag = 0;
    }else{ 
        if(newlineFlag == 1){
            printf("Line %d, column %d: %s: %s\n", lineStart, columnStart, s, yytext);
        }else {
            printf("Line %d, column %d: %s: %s\n", line_num, column_num - yyleng, s, yytext);
        }
    }
    syntaxErrorFlag = 1;
}
