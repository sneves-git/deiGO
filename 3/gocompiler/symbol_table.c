   /* ____________________________________________________________________
    |   Universidade de Coimbra - Licenciatura em Engenharia Informática   |
    |                Projeto de Compiladores 2021/22                       |
    |               Compilador para a linguagem deiGo                      |
    |                                                                      |
    | - Sofia Santos Neves nº2019220082                                    |
    | - Tatiana Silva Almeida nº2019219581                                 |
    |______________________________________________________________________|
    */


#include "symbol_table.h"
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>




sym_table *sym_head = NULL;
sym_table *current_table = NULL;
extern int semantic_error;
 


bool var_exists(Node* node){
    symbol *symbol_aux;

    for(symbol_aux = current_table->symbol_list; symbol_aux != NULL; symbol_aux = symbol_aux->next){
        if(strcmp(symbol_aux->name, node->child->nextSibling->data.value) == 0){
            symbol_already_defined(node->child->nextSibling->data.line, node->child->nextSibling->data.column, node->child->nextSibling->data.value);
            semantic_error = 1;
            return false;
        }
    }
    return true;
}


bool func_exists(Node* node){
    symbol *symbol_aux;

    for(symbol_aux = sym_head->symbol_list; symbol_aux != NULL; symbol_aux = symbol_aux->next){
        if(strcmp(symbol_aux->name, node->child->child->data.value) == 0){
            symbol_already_defined(node->child->child->data.line, node->child->child->data.column, node->child->child->data.value);
            node->is_valid = false;
            semantic_error = 1;
            return false;
        }
    }
    return true;
}


bool handle_func_decl(Node* node){
    if(!sym_head){
        sym_head = inicialize_sym_table("Global");
    }


    if(!func_exists(node)){
        return false;
    }else{
        //return params from function 
        param *table_params = func_header_params(node->child->child);

        //create symbol to func
        symbol *sym_func = inicialize_symbol(node->child->child->data.value, node->child->child->nextSibling->type, 1, table_params,node->child->child->data.line, node->child->child->data.column);

        //add symbol (func) to global table 
        add_symbol_to_table(sym_head, sym_func); 

        //create table for the new func
        sym_table *new_table = inicialize_sym_table(node->child->child->data.value);
        current_table = new_table;
        
        //create return symbol
        symbol *return_ = inicialize_symbol("return", node->child->child->nextSibling->type, 4, NULL, node->child->child->nextSibling->data.line, node->child->child->nextSibling->data.column);
       
        add_symbol_to_table(new_table, return_);

        //add params to new table
        while(table_params != NULL){
            symbol *s = inicialize_symbol(table_params->id, table_params->type, 3, NULL, 0, 0);
          
            add_symbol_to_table(current_table, s);
            table_params = table_params->next;
        }
        
        //add new table to list of tables
        add_symbol_table_to_list_of_tables(sym_head, current_table);        
    }
    
    return true;
}


void handle_var_decl(Node *node){
    if(!sym_head){
        sym_head = inicialize_sym_table("Global");
        current_table = sym_head;
    }
    
    if(var_exists(node)){
        //create symbol
        symbol *sym_var = inicialize_symbol(node->child->nextSibling->data.value, node->child->type, 2, NULL, node->child->nextSibling->data.line, node->child->nextSibling->data.column);
    
        //add symbol (func) to current table 
        add_symbol_to_table(current_table, sym_var); 
    }
}


/*===================================================================
======================= create symbol table =========================
=====================================================================*/


void create_symbol_table(Node *node){
    if(!node) return;

    
    switch(node->type){
        case FuncDecl:
            if(handle_func_decl(node)){  
                create_symbol_table(node->child->nextSibling);
            }
            current_table = sym_head;
            break;

        case VarDecl:
            handle_var_decl(node);
            break;

        case Id:
            create_symbol_table(node->child);
            annotate_id_var_types(node);
            break;

        default:
            create_symbol_table(node->child);
            break;
    }
    create_symbol_table(node->nextSibling);
}



sym_table* search_table(Node * node){
    sym_table *table_aux;
    for(table_aux = sym_head; table_aux != NULL; table_aux = table_aux->next){
        if(strcmp(table_aux->name, node->data.value) == 0){
           return table_aux;
        }
    }
    return table_aux;
}



void annotate_id_var_types(Node *id){
    symbol *symbol_aux;

    for(symbol_aux = current_table->symbol_list; symbol_aux != NULL; symbol_aux = symbol_aux->next){
        if(strcmp(symbol_aux->name, id->data.value) == 0 && id->is_expr == true){
            id->annotation = symbol_aux->type;
            return;
        }
    }
    
    for(symbol_aux = sym_head->symbol_list; symbol_aux != NULL; symbol_aux = symbol_aux->next){
        if(strcmp(symbol_aux->name, id->data.value) == 0 && id->is_expr == true){
            id->annotation = symbol_aux->type;
            return;
        }
    }
}