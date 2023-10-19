
   /* ____________________________________________________________________
    |   Universidade de Coimbra - Licenciatura em Engenharia Informática   |
    |                Projeto de Compiladores 2021/22                       |
    |               Compilador para a linguagem deiGo                      |
    |                                                                      |
    | - Sofia Santos Neves nº2019220082                                    |
    | - Tatiana Silva Almeida nº2019219581                                 |
    |______________________________________________________________________|
    */


#ifndef __SYMBOL_TABLE_H
#define __SYMBOL_TABLE_H
#include <stdbool.h>
#include <stdlib.h>
#include "semantics.h"

// Functions
bool func_exists(Node* );
bool var_exists(Node*);
bool handle_func_decl(Node* );
void handle_var_decl(Node *);
void create_symbol_table(Node *);
sym_table* search_table(Node *);
void annotate_id_var_types(Node *);


#endif //__SYMBOL_TABLE_H