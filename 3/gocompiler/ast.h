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
#include "structures.h"


// Functions
Data return_struct(char*, int, int, int);
Node *createNode(Type, Data);
Node *appendSibling(Node*, Node *);
void freeNode(Node*);
void appendChild(Node*, Node *);
void printNode(Node*, int , int);
void printAST(Node*, int, int);
bool statements(Node * );

#endif //__AST_H