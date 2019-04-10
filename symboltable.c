#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "lex.yy.c"

extern int yylineno;

#define prime 33
#define mod 1007

void yyerror(const char* str){
    printf("Error %s at line %d\n",str,yylineno);
    exit(0);
}

typedef struct Node{
    char name[100];
    double type;
    int scope;
    int num_params;
    int line;
    struct Node* next; // actually redundant if not using hash
} node;

node *st[mod] = {NULL};
node *ct[mod] = {NULL};
node *stack[mod];
int tos = -1;
int dtype = 0;
int next = -1; //can use hash instead
int next_ct = -1; //for constant table
int curr_scope = 0;

node* insert(char* name, double type, int scope, int line){
    node* temp = (node*)malloc(sizeof(node));
    strcpy(temp->name,name);
    temp->type = type;
    temp->line = line;
    temp->scope = scope;
    temp->num_params = -1;

    next++; //instead of hash
    temp->next= st[next];
    st[next] = temp;
    stack[++tos] = temp;

    return temp;
}

void print_st(){
    printf("-------------------------------------------------\n");
    printf("%10s | %10s | %10s | %10s\n","name","type","scope","num_par");
    printf("-------------------------------------------------\n");
    int ptr = 0;
    for(int i = 0; i<mod; i++){
        node * temp = st[i];
        while(temp!=NULL){
            printf("%10s | %10d | %10d | %10d\n",temp->name,(int)temp->type,temp->scope,temp->num_params);
            temp = temp->next;
        }
    }
}

node* search(char * str){
    for(int i = 0; i<mod; i++){
        node * temp = st[i];
        while(temp!=NULL){
            if(!strcmp(temp->name,str)){
                return temp;
            }
            temp = temp->next;
        }
    }
}

void type_check(char* str1, char * str2){
    if(search(str1)->type!=search(str2)->type){
        yyerror("Type mismatch");
    }
}

void redecl(char* str){
    int ptr = tos;
    while(stack[ptr]->scope==curr_scope){
        if(!strcmp(stack[ptr]->name,str)){
            yyerror("Variable redeclared");
            
        }
        ptr--;
    }
}

void not_decl(char * str){
    int ptr = tos;
    while(ptr>=0){
        if (!strcmp(stack[ptr]->name,str))
            return;
        ptr--;
    }
    yyerror("Variable not declared");
}

node* insert_ct(char* name, double type, int scope, int line){
    node* temp = (node*)malloc(sizeof(node));
    strcpy(temp->name,name);
    temp->type = type;
    temp->line = line;
    temp->scope = scope;
    temp->num_params = -1;

    next_ct++; //instead of hash
    temp->next= st[next_ct];
    ct[next_ct] = temp;

    return temp;
}

