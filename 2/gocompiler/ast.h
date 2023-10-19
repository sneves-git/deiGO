 /* ____________________________________________________________________
    |   Universidade de Coimbra - Licenciatura em Engenharia Informática    |
    |                Projeto de Compiladores 2021/22                       |
    |               Compilador para a linguagem deiGo                      |
    |                                                                      |
    | - Sofia Santos Neves nº2019220082                                    |
    | - Tatiana Silva Almeida nº2019219581                                 |
    |______________________________________________________________________|
*/

#ifndef __AST_H
#define __AST_H

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
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
	Error
} Type;


typedef struct Data{
    char *value;
}Data;

typedef struct _Node Node;
struct _Node{
    Type type;
    Data data;
    Node *child;
    Node *nextSibling;
};

// Functions
Node *createNode(Type, char *);
Node *appendSibling(Node*, Node *);
void freeNode(Node*);
void appendChild(Node*, Node *);
void printNode(Node*, int );
void printAST(Node*, int);
bool statements(Node * node);
#endif //__AST_H