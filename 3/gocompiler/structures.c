   /* ____________________________________________________________________
    |   Universidade de Coimbra - Licenciatura em Engenharia Informática   |
    |                Projeto de Compiladores 2021/22                       |
    |               Compilador para a linguagem deiGo                      |
    |                                                                      |
    | - Sofia Santos Neves nº2019220082                                    |
    | - Tatiana Silva Almeida nº2019219581                                 |
    |______________________________________________________________________|
    */



#include "structures.h"
#include "malloc.h"
#include <stdbool.h>
#include <string.h>
#include "semantics.h"

extern sym_table *current_table;
extern sym_table *sym_head;
extern int semantic_error;

sym_table *inicialize_sym_table(char *name){
    sym_table *symTable = (sym_table *) malloc(sizeof(sym_table));
   
    symTable->name = name;
    symTable->symbol_list = NULL;
    symTable->next = NULL;

    return symTable;
};


symbol *inicialize_symbol(char *name, Type type, int a, param *param_list, int line, int column){
    symbol *sym = (symbol *)malloc(sizeof(symbol));
   
    sym->name = name;
    sym->type = type;

    if(a == 1){
        sym->is = func;
    }else if(a == 2){
        sym->is = var;
    }else if(a == 3){
        sym->is = parameter;
    }else if(a == 4){
        sym->is = return_;
    }

    sym->param_list = param_list;
    sym->next = NULL;

    // Error declared but never used
    sym->used = false;
    sym->line = line;
    sym->column = column;

    return sym;
}

param *func_header_params(Node *id_func_header){
    param *param_list = NULL, *aux_param;
    Node *FuncParams =NULL;

    //Check if function has type
    if(id_func_header->nextSibling->nextSibling ){
        FuncParams = id_func_header->nextSibling->nextSibling; //(funcparams)
    }else{
        FuncParams = id_func_header->nextSibling;
    }
    
    //Add parameters to function (or not)
    if(FuncParams){
        for(Node *aux = FuncParams->child; aux; aux = aux->nextSibling){
            param *parameter = inicialize_param(aux->child->nextSibling->data.value, aux->child->type);
           
            if(param_list == NULL){
                param_list = parameter;
            }else{
                // Checks if parameters are the same, if so generates error
                for(aux_param = param_list; aux_param; aux_param = aux_param->next){
                    if(strcmp(aux_param->id, parameter->id) == 0 ){
                        symbol_already_defined(aux->child->nextSibling->data.line, aux->child->nextSibling->data.column, aux->child->nextSibling->data.value);
                    }
                }

                // Puts parameters in function
                for(aux_param = param_list; aux_param->next; aux_param = aux_param->next);
                aux_param->next = parameter;
            }
        }
    }
    return param_list;

}


param *inicialize_param(char* id, Type type){
    param *parameter = (param *) malloc(sizeof(param));
    
    parameter->id = id;
    parameter->type = type;
    parameter->next = NULL;

    return parameter;
}

sym_table *add_symbol_to_table(sym_table *table, symbol *sym){
    if (table == NULL || sym == NULL) {
        return NULL;
    }
    symbol *aux = NULL;

    if(table->symbol_list == NULL){
        table->symbol_list = sym;
    }else{
        for (aux = table->symbol_list; aux->next != NULL; aux = aux->next);
        aux->next = sym;
    }
    
    return table;
}


sym_table *add_symbol_table_to_list_of_tables(sym_table *head, sym_table *new_table){
    if (head == NULL || new_table == NULL) {
        return NULL;
    }
    
    sym_table *aux = NULL;
    if(head == NULL){
        head = new_table;
    }else{
        for (aux = head; aux->next; aux = aux->next);
        aux->next = new_table;
    }

    return head;
}



void free_symbol(symbol *sym) {
    if(!sym) return;
    param *aux = NULL, *p = sym->param_list;

    for(; p != NULL;  p = p -> next){
        aux = p;
        free(aux);
    }
    free(sym);
}


void free_symbol_table_list(sym_table *sym_t) {
    if (!sym_t) return;
    
    sym_table *tab_aux = NULL, *tab = sym_t;
    while(tab != NULL){
        symbol *sym_aux = NULL, *sym = tab->symbol_list;
        while (sym != NULL) {
            sym_aux = sym;
            sym = sym->next;
            free_symbol(sym_aux);
        }
        tab_aux = tab;
        tab = tab->next;
        free(tab_aux);
    }
}



void print_param_list(param *param_list){
    param *aux = param_list;
    printf("(");
    while(aux != NULL){
        if(aux->next != NULL){
            printf("%s,", types_(aux->type));
        }else{
            printf("%s", types_(aux->type));
        }
        aux = aux->next;
    }
    printf(")");
}


void print_symbol_list(symbol *sym){
    symbol *symbol = sym;

    while(symbol){
        // Prints Name

        printf("%s\t", symbol->name);

        // Prints [ParamTypes] 
        if(symbol->is == func){
            print_param_list(symbol->param_list);
        }
        printf("\t");
        
        // Prints Type
        printf("%s", types_(symbol->type));

        // Prints [param]
        if(symbol->is == parameter){
            printf("\tparam");
        }
        
        printf("\n");
        symbol = symbol->next;
    }
    printf("\n");
}



void print_type_in_title(char *name){
    symbol *s = NULL;
    for(s = sym_head->symbol_list; s; s=s->next){
        if(strcmp(s->name, name) == 0){ 
            print_param_list(s->param_list);
        }
    }
}

void print_symbol_table(sym_table *sym_t){
    sym_table *symbol_table = sym_t;

    printf("===== %s Symbol Table =====\n", symbol_table->name);
    print_symbol_list(symbol_table->symbol_list);
    symbol_table = symbol_table->next;

    while(symbol_table){
        printf("===== Function %s", symbol_table->name);
        print_type_in_title(symbol_table->name);
        printf(" Symbol Table =====\n");
        print_symbol_list(symbol_table->symbol_list);
        symbol_table = symbol_table->next;
    }
    
}