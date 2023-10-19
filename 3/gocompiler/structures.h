
   /* ____________________________________________________________________
    |   Universidade de Coimbra - Licenciatura em Engenharia Informática   |
    |                Projeto de Compiladores 2021/22                       |
    |               Compilador para a linguagem deiGo                      |
    |                                                                      |
    | - Sofia Santos Neves nº2019220082                                    |
    | - Tatiana Silva Almeida nº2019219581                                 |
    |______________________________________________________________________|
    */




#ifndef __STRUCTURES_H
#define __STRUCTURES_H

#include <stdbool.h>




typedef enum _Type{
	/* Root */
	Program,

	/* Variable Declarations */
	VarDecl,

	/* Function Definition | Declaration */
	FuncDecl,
	FuncHeader,
	FuncParams,
	FuncBody,
	ParamDecl,

	/* Statements */
	Block,
	If,
	For,
	Return,
	Call,
	Print,
	ParseArgs,

	/* Operators */
	Or,
	And,
	Eq,
	Ne,
	Lt,
	Gt,
	Le,
	Ge,
	Add,
	Sub,
	Mul,
	Div,
	Mod,
	Not,
	Minus,
	Plus,
	Assign,

	/* Terminals */
	Int,
	Float32,
	Bool,
	String,
	IntLit,
	RealLit,
	Id,
	StrLit,
	Error,
	Undef, 
	None,
	Func
} Type;


typedef struct _parameters param;
struct _parameters{
	char *id;
    Type type;
    param *next;
};

typedef struct Data{
	int line;
	int column;
    char *value;
}Data;

typedef struct _Node Node;
struct _Node{
	// Meta 3
	Type annotation;
	param *param_list;
	bool is_expr, is_valid;

	// Meta 2
    Type type;
    Data data;
    Node *child;
    Node *nextSibling;
};




typedef struct _symbol symbol;
struct _symbol{
	enum
	{
		func,       //1
		var,	    //2
		parameter,	//3
		return_,
	} is;
	
	
    char *name;
	Type type;
    param *param_list;
    symbol *next;

	// error declared but never used
	bool used;
	int line, column;
};

typedef struct _sym_table sym_table;
struct _sym_table{
    char *name;
	symbol *symbol_list;
    sym_table *next;
};


//Functions
sym_table *inicialize_sym_table(char *);
symbol *inicialize_symbol(char *, Type, int, param *, int, int);
param *func_header_params(Node *);
param *inicialize_param(char*, Type);
sym_table *add_symbol_to_table(sym_table *, symbol *);
sym_table *add_symbol_table_to_list_of_tables(sym_table *, sym_table *);
void free_symbol(symbol *);
void free_symbol_table_list(sym_table *);
void print_param_list(param *);
void print_symbol_list(symbol *);
void print_type_in_title(char *);
void print_symbol_table(sym_table *);
char *types_(Type);
char *op_(Type);

#endif      //__STRUCTURES_H