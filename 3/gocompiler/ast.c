/* ____________________________________________________________________
   |   Universidade de Coimbra - Licenciatura em Engenharia Informática    |
   |                Projeto de Compiladores 2021/22                       |
   |               Compilador para a linguagem deiGo                      |
   |                                                                      |
   | - Sofia Santos Neves nº2019220082                                    |
   | - Tatiana Silva Almeida nº2019219581                                 |
   |______________________________________________________________________|
*/

#include "ast.h"
#include "y.tab.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

char *types[] = {
    /* Root */
    "Program",

    /* Variable Declarations */
    "VarDecl",

    /* Function Definition | Declaration */
    "FuncDecl", "FuncHeader", "FuncParams", "FuncBody", "ParamDecl",

    /* Statements */
    "Block", "If", "For", "Return", "Call", "Print", "ParseArgs",

    /* Operators */
    "Or", "And", "Eq", "Ne", "Lt", "Gt", "Le", "Ge", "Add", "Sub", "Mul", "Div",
    "Mod", "Not", "Minus", "Plus", "Assign",

    /* Terminals */
    "Int", "Float32", "Bool", "String", "IntLit", "RealLit", "Id", "StrLit",
    "Error", "Undef", "None", "Func"
    };


Data return_struct(char* value, int line, int column, int type){
  Data token = {.value = NULL, .line = line, .column = column};
  if( type == ID || type == STRLIT || type == INTLIT || type == REALLIT){
    token.value = (char*)strdup(value);
  }
  return token;
}



Node *createNode(Type type, Data value) {
  Node *aux = malloc(sizeof(Node));
  aux->annotation = None;
  aux->param_list = NULL;
  aux->is_expr = false;
  aux->is_valid = true;
 
  aux->type = type;
  aux->data = value;
  aux->child = NULL;
  aux->nextSibling = NULL;
  return aux;
}

Node *appendSibling(Node *head, Node *node) {
  if (head == NULL || node == NULL) {
    return NULL;
  }

  Node *aux = NULL;
  for (aux = head; aux->nextSibling != NULL; aux = aux->nextSibling)
    ;
  aux->nextSibling = node;

  return head;
}

void appendChild(Node *parent, Node *node) {

  if (parent == NULL || node == NULL) {
    return;
  }
  parent->child = node;
}

void printNode(Node *node, int depth, int semantic_analysis) {
  for (int i = 0; i < depth * 2; ++i) {
    printf(".");
  }
  printf("%s", types[node->type]);
  if (strcmp(types[node->type], "StrLit") == 0) {
    if (node->data.value)
      printf("(\"%s)", node->data.value);
  } else {
    if (node->data.value)
      printf("(%s)", node->data.value);
  }
  
  if(semantic_analysis == 1){
    

    if(node->annotation == Func){
        printf(" - ");
        print_param_list(node->param_list);
    }else if(    node->annotation != Undef 
              && node->annotation != None
              && node->type != String
              && node->type != Bool 
              && strcmp("none",types_(node->annotation) ) != 0)
    {
      printf(" - %s", types_(node->annotation));      
    }

  }

  
  printf("\n");
}

void printAST(Node *node, int depth, int semantic_analysis) {
  printNode(node, depth, semantic_analysis);
  if (node->child) {
    printAST(node->child, depth + 1, semantic_analysis);
  }
  if (node->nextSibling) {
    printAST(node->nextSibling, depth, semantic_analysis);
  }
}

void freeNode(Node *node) {
  if (node != NULL) {
    if (node->data.value) {
      free(node->data.value);
    }
    freeNode(node->child);
    freeNode(node->nextSibling);
    free(node);
  }
}

bool statements(Node *node) {
  if (node == NULL)
    return false;

  int i = 0;
  for (Node *aux = node; aux->nextSibling != NULL; aux = aux->nextSibling) {
    i++;
  }

  if (i >= 1) {
    return true;
  }
  return false;
}
