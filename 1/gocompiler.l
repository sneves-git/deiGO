%X MULTI_COMMENT STRLIT_STATE 
%{
    /* ____________________________________________________________________
    |   Universidade de Coimbra -Licenciatura em Engenharia Informática    |
    |                Projeto de Compiladores 2021/22                       |
    |               Compilador para a linguagem deiGo                      |
    |                                                                      |
    | - Sofia Santos Neves nº2019220082                                    |
    | - Tatiana Silva Almeida nº2019219581                                 |
    |______________________________________________________________________|
    */
    
    #include <stdio.h>
    #include <string.h>
    void add_semicolon();
    void verification_octal(char*, int);

    int line_num = 1, column_num = 1, aux_column, aux_line, flag=0, flag_str_validation = 0;
  
 
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
<MULTI_COMMENT><<EOF>>                                          {printf("Line %d, column %d: unterminated comment\n", aux_line, aux_column); BEGIN 0;}
<MULTI_COMMENT>"*/"                                             {BEGIN 0; column_num += yyleng;}
<MULTI_COMMENT>{NEWLINE}                                        {line_num++; column_num = 1; }
<MULTI_COMMENT>.                                                {column_num += yyleng; }


    /* STRLIT */
{STRLIT_DELIMITER}                                              {BEGIN STRLIT_STATE;flag_str_validation = 0; aux_line = line_num; aux_column = column_num; column_num += yyleng; flag = 0;}
<STRLIT_STATE>\\                                                {printf("Line %d, column %d: invalid escape sequence (%s)\n", line_num, column_num, yytext); column_num += yyleng; flag_str_validation = 1;}
<STRLIT_STATE>\\([^\"fnrt\\\r\n])                               {printf("Line %d, column %d: invalid escape sequence (%s)\n", line_num, column_num, yytext); column_num += yyleng; flag_str_validation = 1;}
<STRLIT_STATE>{STRLIT}?{NEWLINE}                                {printf("Line %d, column %d: unterminated string literal\n", aux_line, aux_column); column_num = 1; line_num++; BEGIN 0;}
<STRLIT_STATE>{STRLIT}?{STRLIT_DELIMITER}                       {if(flag_str_validation == 0){ printf("STRLIT(\"%s)\n", yytext); flag = 1;} column_num += yyleng; BEGIN 0; }
<STRLIT_STATE>{STRLIT}?                                         {column_num += yyleng; }
<STRLIT_STATE><<EOF>>                                           {printf("Line %d, column %d: unterminated string literal\n", aux_line, aux_column); column_num = 1; line_num++; BEGIN 0;}



    /* INTLIT */
{OCTAL_BASE}{NUMBER}+                                           {verification_octal(yytext, yyleng); column_num += yyleng;}
{HEX_BASE}({HEX_LETTERS}|{NUMBER})+                             {printf("INTLIT(%s)\n", yytext); column_num += yyleng; flag = 1;}
{NUMBER}+                                                       {printf("INTLIT(%s)\n", yytext); column_num += yyleng; flag = 1;}



    /*TOKENS */
{SEMICOLON}                                                     {printf("SEMICOLON\n"); column_num += yyleng; flag = 0;}
{COMMA}                                                         {printf("COMMA\n"); column_num += yyleng; flag = 0;}
{BLANKID}                                                       {printf("BLANKID\n"); column_num += yyleng; flag = 0;}
{ASSIGN}                                                        {printf("ASSIGN\n"); column_num += yyleng; flag = 0;}
{STAR}                                                          {printf("STAR\n"); column_num += yyleng; flag = 0;}
{DIV}                                                           {printf("DIV\n"); column_num += yyleng; flag = 0;}
{MINUS}                                                         {printf("MINUS\n"); column_num += yyleng; flag = 0;}
{PLUS}                                                          {printf("PLUS\n"); column_num += yyleng; flag = 0;}
{EQ}                                                            {printf("EQ\n"); column_num += yyleng; flag = 0;}
{GE}                                                            {printf("GE\n"); column_num += yyleng; flag = 0;}  
{GT}                                                            {printf("GT\n"); column_num += yyleng; flag = 0;}
{LBRACE}                                                        {printf("LBRACE\n"); column_num += yyleng; flag = 0;}
{LE}                                                            {printf("LE\n"); column_num += yyleng; flag = 0;}
{LPAR}                                                          {printf("LPAR\n"); column_num += yyleng; flag = 0;}
{LSQ}                                                           {printf("LSQ\n"); column_num += yyleng; flag = 0;}
{LT}                                                            {printf("LT\n"); column_num += yyleng; flag = 0;}
{MOD}                                                           {printf("MOD\n"); column_num += yyleng; flag = 0;}
{NE}                                                            {printf("NE\n"); column_num += yyleng; flag = 0;}
{NOT}                                                           {printf("NOT\n"); column_num += yyleng; flag = 0;}
{AND}                                                           {printf("AND\n"); column_num += yyleng; flag = 0;}
{OR}                                                            {printf("OR\n"); column_num += yyleng; flag = 0;}
{RBRACE}                                                        {printf("RBRACE\n"); column_num += yyleng; flag = 1; }
{RPAR}                                                          {printf("RPAR\n"); column_num += yyleng; flag = 1; }
{RSQ}                                                           {printf("RSQ\n"); column_num += yyleng; flag = 1; }
{PACKAGE}                                                       {printf("PACKAGE\n"); column_num += yyleng; flag = 0;}
{ELSE}                                                          {printf("ELSE\n"); column_num += yyleng; flag = 0;}
{FOR}                                                           {printf("FOR\n"); column_num += yyleng; flag = 0;}
{IF}                                                            {printf("IF\n"); column_num += yyleng; flag = 0;}
{VAR}                                                           {printf("VAR\n"); column_num += yyleng; flag = 0;}
{INT}                                                           {printf("INT\n"); column_num += yyleng; flag = 0;}
{FLOAT32}                                                       {printf("FLOAT32\n"); column_num += yyleng; flag = 0;}
{RETURN}                                                        {printf("RETURN\n"); column_num += yyleng; flag = 1;}
{BOOL}                                                          {printf("BOOL\n"); column_num += yyleng; flag = 0;}
{STRING}                                                        {printf("STRING\n"); column_num += yyleng; flag = 0;}  
{PRINT}                                                         {printf("PRINT\n"); column_num += yyleng; flag = 0;}
{PARSEINT}                                                      {printf("PARSEINT\n"); column_num += yyleng; flag = 0;}
{FUNC}                                                          {printf("FUNC\n"); column_num += yyleng; flag = 0;}
{CMDARGS}                                                       {printf("CMDARGS\n"); column_num += yyleng; flag = 0;}

{NEWLINE}                                                       {column_num = 1; line_num++; add_semicolon(); flag = 0;}
{IGNORE}                                                        {column_num += yyleng;}
{COMMENT_BARS}                                                  {add_semicolon(); column_num += yyleng; flag = 0;}  

{RESERVED}                                                      {printf("RESERVED(%s)\n", yytext); column_num += yyleng; flag = 0;}
{ID}                                                            {printf("ID(%s)\n", yytext); column_num += yyleng; flag = 1;}
{REALLIT}                                                       {printf("REALLIT(%s)\n", yytext); column_num += yyleng; flag = 1;}

.                                                               {printf("Line %d, column %d: illegal character (%s)\n", line_num, column_num, yytext); column_num += yyleng;flag = 0;}
<<EOF>>                                                         {add_semicolon(); return 0;}

%%


int main(){
    yylex();
    yylex_destroy();
    return 0;
}

int yywrap(){
    return 1;
}

void add_semicolon(){
    if(flag == 1){ 
        printf("SEMICOLON\n");
    } 
}



void verification_octal(char* number, int tam){
    for(int i = 0; i < tam; ++i){
        if(number[i] == '9' || number[i] == '8'){
          printf("Line %d, column %d: invalid octal constant (%s)\n", line_num, column_num, number);
          flag = 0;
          return;
        }
    }
    printf("INTLIT(%s)\n", number); 
    flag = 1;
    return;
}

