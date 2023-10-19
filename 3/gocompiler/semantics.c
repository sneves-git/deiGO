   /* ____________________________________________________________________
    |   Universidade de Coimbra - Licenciatura em Engenharia Informática   |
    |                Projeto de Compiladores 2021/22                       |
    |               Compilador para a linguagem deiGo                      |
    |                                                                      |
    | - Sofia Santos Neves nº2019220082                                    |
    | - Tatiana Silva Almeida nº2019219581                                 |
    |______________________________________________________________________|
    */

#define _GNU_SOURCE         
#include <stdio.h>
#include "semantics.h"
#include <stdlib.h>
#include <ctype.h>
#include <string.h>


extern  char* types[];

extern sym_table *sym_head;
extern sym_table *current_table;
int semantic_error = 0;


void semantic_analysis(Node *node){
    if(!node) return;

    
	Type left_side_type, right_side_type;
    
    switch(node->type){
        
        /* Statements */
        case VarDecl:
            break;
        case FuncDecl:
            if(node->is_valid == false){
                current_table = sym_head;
                break;
            }

            for(sym_table *aux_table = sym_head; aux_table; aux_table = aux_table->next){
                if(strcmp(aux_table->name, node->child->child->data.value) == 0){
                    current_table = aux_table;
                    semantic_analysis(node->child->nextSibling);
                    break;
                }
            }
                
            current_table = sym_head;
            break;
        case If:
            semantic_analysis(node->child);
            
            right_side_type = node->child->annotation;
            if(right_side_type != Bool){
                incompatible_type_in_statement(node->child->data.line, node->child->data.column, types_(right_side_type), "if");
                semantic_error = 1;
            }
            break;
        
        case For:
            semantic_analysis(node->child);
            
            left_side_type = node->child->annotation;
            Type aux = node->child->type;

            if(aux != Block && (left_side_type != Bool || left_side_type == Undef)){
                incompatible_type_in_statement(node->child->data.line, node->child->data.column, types_(left_side_type), "for" );
                semantic_error = 1;
            }
            break;

        case Return:
            semantic_analysis(node->child);        

            if(node->child){
                left_side_type = node->child->annotation;
                if(current_table->symbol_list){
                    if(current_table->symbol_list->type != left_side_type){
                        incompatible_type_in_statement(node->child->data.line, node->child->data.column, types_(left_side_type), "return" );
                        semantic_error = 1;
                    }
                }
            }else {
                if(strcmp(types_(current_table->symbol_list->type), "none") != 0){
                    incompatible_type_in_statement(node->data.line, node->data.column, "none", "return" );
                    semantic_error = 1;
                }
            }
            break;
        
        case Print:
            semantic_analysis(node->child);           
            break;
        
        case ParseArgs:
            semantic_analysis(node->child);

            left_side_type = node->child->annotation;
            right_side_type = node->child->nextSibling->annotation;
            if(left_side_type != Int || right_side_type != Int){
                node->annotation = Undef;
                operator_cannot_be_applied_to_types(node->data.line, node->data.column, op_(node->type), types_(left_side_type), types_(right_side_type));
                semantic_error = 1;
            }else{
                node->annotation = left_side_type;
            }
            break;

        /* Operators */
        case Or:
        case And:
            semantic_analysis(node->child);

            left_side_type = node->child->annotation;
            right_side_type = node->child->nextSibling->annotation;
            if(left_side_type == Bool && right_side_type == Bool){
                node->annotation = Bool;
            }else{
                operator_cannot_be_applied_to_types(node->data.line, node->data.column, op_(node->type), types_(left_side_type), types_(right_side_type));
                node->annotation = Bool;
                semantic_error = 1;
            }
            break;
        
        case Eq:
        case Ne:
            semantic_analysis(node->child);

            left_side_type = node->child->annotation;
            right_side_type = node->child->nextSibling->annotation;

            node->annotation = Bool;
            if(left_side_type != right_side_type){
                operator_cannot_be_applied_to_types(node->data.line, node->data.column, op_(node->type), types_(left_side_type), types_(right_side_type));
                semantic_error = 1;
            }
            break;
           

        case Lt:
        case Gt:
        case Le:
        case Ge:
            semantic_analysis(node->child);

            left_side_type = node->child->annotation;
            right_side_type = node->child->nextSibling->annotation;

            node->annotation = Bool;
            if(left_side_type != right_side_type || left_side_type == Bool || left_side_type == Undef){
                operator_cannot_be_applied_to_types(node->data.line, node->data.column, op_(node->type), types_(left_side_type), types_(right_side_type));
                semantic_error = 1;
            }
            break;

        case Add:
            semantic_analysis(node->child);

            left_side_type = node->child->annotation;
            right_side_type = node->child->nextSibling->annotation;

            if(     left_side_type == right_side_type
                && (left_side_type == Float32 || left_side_type == Int || left_side_type == String)){
                node->annotation = left_side_type;
            }else{
                node->annotation = Undef;
                operator_cannot_be_applied_to_types(node->data.line, node->data.column, op_(node->type), types_(left_side_type), types_(right_side_type));
                semantic_error = 1;
            }

            break;
            
        case Sub:
        case Mul:
        case Div:
            semantic_analysis(node->child);

            left_side_type = node->child->annotation;
            right_side_type = node->child->nextSibling->annotation; 
            node->annotation = Undef;
            
            if ( left_side_type == right_side_type 
                && (left_side_type == Float32 || left_side_type == Int)){
                node->annotation = left_side_type;
		    }else{
                node->annotation = Undef;
                operator_cannot_be_applied_to_types(node->data.line, node->data.column, op_(node->type), types_(left_side_type), types_(right_side_type) );
                semantic_error = 1;
		    }
		
            break;
            
        case Mod: 
            semantic_analysis(node->child);

            left_side_type = node->child->annotation;
            right_side_type = node->child->nextSibling->annotation;
            node->annotation = Int;
            if( left_side_type == Int && right_side_type == Int){
                node->annotation = left_side_type;
            }else{
                node->annotation = Undef;
                operator_cannot_be_applied_to_types(node->data.line, node->data.column, op_(node->type), types_(left_side_type), types_(right_side_type));
                semantic_error = 1;
            }
            break;
        
        case Not: 
            semantic_analysis(node->child);
            right_side_type = node->child->annotation;

            node->annotation = Bool;
            if(right_side_type != Bool){
                operator_cannot_be_applied_to_type(node->data.line, node->data.column, op_(node->type), types_(right_side_type));
                semantic_error = 1;
            }
            break;

        case Minus:
        case Plus:
            semantic_analysis(node->child);

            right_side_type = node->child->annotation;
            
            if(right_side_type == Float32 || right_side_type == Int){
                node->annotation = right_side_type;
            }else{
                node->annotation = Undef;
                operator_cannot_be_applied_to_type(node->data.line, node->data.column, op_(node->type), types_(right_side_type));
                semantic_error = 1;
            }
            
            break;
      
        case Assign:
            semantic_analysis(node->child);
            
            left_side_type = node->child->annotation;
            right_side_type = node->child->nextSibling->annotation; 

            if (left_side_type != right_side_type || right_side_type == Undef || left_side_type == Undef || left_side_type == None || right_side_type == None){
                node->annotation = Undef;
                operator_cannot_be_applied_to_types(node->data.line, node->data.column, op_(node->type), types_(left_side_type), types_(right_side_type) );
                semantic_error = 1;
            }
            else{
                node->annotation = left_side_type; 
            }
              
            break;

        case Call:
            semantic_analysis(node->child->nextSibling);
            symbol *symbol_aux;
            int flag = 0;
            node->annotation = Undef;
            // Search for all params and put it in param_list
            Node *node_ = node->child->nextSibling;
            param *param_list = NULL, *aux_param;
            while(node_){
                // Check if annotation exists, if not then it's type
                param *parameter = inicialize_param(node_->data.value, node_->annotation);
                if(param_list == NULL){
                    param_list = parameter;
                }else{
                    for(aux_param = param_list; aux_param->next; aux_param = aux_param->next);
                    aux_param->next = parameter;
                }
                node_ = node_->nextSibling;
            }
            node->child->param_list = param_list;    
            
            for(symbol_aux = sym_head->symbol_list; symbol_aux != NULL; symbol_aux = symbol_aux->next){
                if(strcmp(symbol_aux->name, node->child->data.value) == 0 && symbol_aux->is == func){
                    

                    flag = 1;
                    // Add type to call
                    node->annotation = symbol_aux->type;
                    node->child->annotation = Func;

                    // Check if parameters of function are the same
                    int error_symbol = 0;
                    param *aux1, *aux2;
                    for(aux1 = symbol_aux->param_list, aux2 = node->child->param_list; aux1 != NULL && aux2 != NULL; aux1 = aux1->next, aux2 = aux2->next){
                        if(aux1->type == aux2->type){
                            continue;
                        }else{
                            node->annotation = Undef;
                            cannot_find_symbol(node->child->data.line, node->child->data.column, join_types(node->child));
                            semantic_error = 1;
                            error_symbol = 1;
                            break;
                        }
                    }
                    if(aux1 != aux2 && error_symbol != 1){
                        node->annotation = Undef;
                        cannot_find_symbol(node->child->data.line, node->child->data.column, join_types(node->child));
                        semantic_error = 1;
                    }

                }
            }

            if(flag == 0){
                node->annotation = Undef;

                cannot_find_symbol(node->child->data.line, node->child->data.column, join_types(node->child));
                semantic_error = 1;
            }
            break;

        /* Terminals */
        case IntLit:
            node->annotation = Int;
            break;

        case RealLit:
            node->annotation = Float32;
            break;

        case String:
        case StrLit:
            node->annotation = String;
            break;

        case Bool:
            node->annotation = Bool;
            break;

        case Id:
            semantic_analysis(node->child);
            find_symbol(node);
            see_if_used(node);

            break;

        default:
            semantic_analysis(node->child);
            break;
    }
    semantic_analysis(node->nextSibling);

}


char *join_types(Node* node){
    param * parameter_list = node->param_list;
    char *string = node->data.value;

    string = strcat_(string, "(");

    for(param *aux = parameter_list; aux; aux = aux->next){
        if(aux->next){
            string = strcat_(string, types_(aux->type));
            string = strcat_(string, ",");
        }else{
            string = strcat_(string, types_(aux->type));
        }
    }

    string = strcat_(string, ")");

    return string;
}


char *strcat_(char *a, char *b) {
  char *p, *q, *rtn;
  rtn = q = malloc(strlen(a) + strlen(b) + 1);
  for (p = a; (*q = *p) != '\0'; ++p, ++q) {}
  for (p = b; (*q = *p) != '\0'; ++p, ++q) {}
  return rtn;
}

void check_if_unused(){
    sym_table *aux_table;
    symbol *aux_symbol;
    
    for(aux_table = sym_head->next; aux_table; aux_table = aux_table->next){
        for(aux_symbol = aux_table->symbol_list; aux_symbol; aux_symbol = aux_symbol->next){
            if(aux_symbol->used == false && aux_symbol->is == var){
                symbol_declared_but_never_used(aux_symbol->line,aux_symbol->column, aux_symbol->name);
                semantic_error = 1;
            }
        }  
    }
}


void see_if_used(Node *node){
    symbol *symbol_aux;

    // Check local table for same symbol
    for(symbol_aux = current_table->symbol_list; symbol_aux != NULL; symbol_aux = symbol_aux->next){
        if(strcmp(symbol_aux->name, node->data.value) == 0){
            symbol_aux->used = true;
        }
    }
    

    // Check global table for the same symbol
    for(symbol_aux = sym_head->symbol_list; symbol_aux != NULL; symbol_aux = symbol_aux->next){
        // Check if ID name is the same as any
        if(strcmp(symbol_aux->name, node->data.value) == 0){
            symbol_aux->used = true;
            // Check if it is function
            if(symbol_aux->is != func){
                return;
            }
        }
    }
    return;
}
    
void find_symbol(Node *node){
    symbol *symbol_aux;

    // Check local table for same symbol
    for(symbol_aux = current_table->symbol_list; symbol_aux != NULL; symbol_aux = symbol_aux->next){
        if(strcmp(symbol_aux->name, node->data.value) == 0){
            return;
        }
    }
    
    // Check global table for the same symbol
    for(symbol_aux = sym_head->symbol_list; symbol_aux != NULL; symbol_aux = symbol_aux->next){
        // Check if ID name is the same as any

        if(strcmp(symbol_aux->name, node->data.value) == 0){
            // Check if it is function
            if(symbol_aux->is != func){
                return;
            }
        }
    }

    node->annotation = Undef;
    cannot_find_symbol(node->data.line, node->data.column, node->data.value);
    semantic_error = 1;
    return;
}
    

