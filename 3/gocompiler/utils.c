   /* ____________________________________________________________________
    |   Universidade de Coimbra - Licenciatura em Engenharia Informática   |
    |                Projeto de Compiladores 2021/22                       |
    |               Compilador para a linguagem deiGo                      |
    |                                                                      |
    | - Sofia Santos Neves nº2019220082                                    |
    | - Tatiana Silva Almeida nº2019219581                                 |
    |______________________________________________________________________|
    */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdbool.h>
#include "ast.h"

char *types_(Type t){
    switch(t){
        case Int:
            return "int";
            break;
        case Float32:
            return "float32";
            break;
        case Bool:
            return "bool";
            break;
        case String:
            return "string";
            break;
        case Undef:
            return "undef";
            break;
        default:
            return "none";
            break;
    }
}


char *op_(Type t){
    switch(t){
        case Or:
            return "||";
            break;
        case And:
            return "&&";
            break;
        case Eq:
            return "==";
            break;
        case Ne:
            return "!=";
            break;
        case Lt:
            return "<";
            break;
        case Gt:
            return ">";
            break;
        case Le:
            return "<=";
            break;
        case Ge:
            return ">=";
            break;
        case Add:
            return "+";
            break;
        case Sub:
            return "-";
            break;
        case Mul:
            return "*";
            break;
        case Div:
            return "/";
            break;
        case Mod:
            return "%";
            break;
        case Not:
            return "!";
            break;
        case Minus:
            return "-";
            break;
        case Plus:
            return "+";
            break;
        case Assign:
            return "=";
            break;
        case ParseArgs:
            return "strconv.Atoi";
            break;
        default:
            return "";
            break;
        
    }
}