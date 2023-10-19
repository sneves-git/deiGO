   /* ____________________________________________________________________
    |   Universidade de Coimbra - Licenciatura em Engenharia Informática   |
    |                Projeto de Compiladores 2021/22                       |
    |               Compilador para a linguagem deiGo                      |
    |                                                                      |
    | - Sofia Santos Neves nº2019220082                                    |
    | - Tatiana Silva Almeida nº2019219581                                 |
    |______________________________________________________________________|
    */

#ifndef __SEMANTICS_H
#define __SEMANTICS_H

#include "structures.h"

#define symbol_already_defined(line, column, sym) printf("Line %d, column %d: Symbol %s already defined\n", line, column, sym);
#define cannot_find_symbol(line, column, sym) printf("Line %d, column %d: Cannot find symbol %s\n", line, column, sym);
#define operator_cannot_be_applied_to_type(line, column, sym, type) printf("Line %d, column %d: Operator %s cannot be applied to type %s\n", line, column, sym, type);
#define operator_cannot_be_applied_to_types(line, column, sym, type1, type2) printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", line, column, sym, type1, type2);
#define incompatible_type_in_statement( line, column,type, sym) printf("Line %d, column %d: Incompatible type %s in %s statement\n", line, column, type, sym);
#define symbol_declared_but_never_used(line, column, sym) printf("Line %d, column %d: Symbol %s declared but never used\n", line, column, sym);

void semantic_analysis(Node *);
void find_symbol(Node *);
void see_if_used(Node *);
void check_if_unused();
char *join_types(Node* );
char *strcat_(char *, char *); //autoria Gene (https://stackoverflow.com/questions/40187840/how-to-concatenate-2-strings-using-malloc-and-not-the-library-functions)

#endif //__SEMANTICS_H