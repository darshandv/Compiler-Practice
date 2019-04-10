%{

    #include "symboltable.c"
    int yylex();
%}

%define parse.lac full
%define parse.error verbose

%union{
    char* str;
    double dec;
}

%nonassoc ifonly
%nonassoc ifx

%start start_state

%token SINGLE MULTI INCLUDE DEF 
%token<str> IDE INTEGER FLOATING
%token INT FLOAT CHAR BREAK CONTINUE IF ELSE
%token OB CB OP CP INC DEC STRING
%token PLE MIE MUE MOE DIE AND OR   

%left ','
%right PLE MIE MUE MOE DIE
%left OR
%left AND
%left '|'
%left '^'
%left '&'
%left '+' '-'
%left '*' '/' 

%type <dec> datatype constexp
%type <str> term expression

%%

start_state: opt start_state| opt;

opt: pre | function | 
     comments |     
     declaration;

pre: INCLUDE | DEF;

comments: SINGLE|
          MULTI
        ;

declaration: datatype decl_list ';' {};

datatype: INT {$$ = INT;dtype = INT;}
          |FLOAT {$$ = FLOAT;dtype = FLOAT;}
          |CHAR {$$ = CHAR;dtype = CHAR;}
          ;

decl_list: decl_list ',' decl 
           | decl;

decl: IDE   {redecl($1);insert($1,dtype,curr_scope,yylineno);}
      |IDE '=' IDE {redecl($1);insert($1,dtype,curr_scope,yylineno);}
      | IDE '=' constexp {redecl($1);insert($1,dtype,curr_scope,yylineno);}
      | IDE '=' expression {redecl($1);insert($1,dtype,curr_scope,yylineno);}
    ;

function: fdef | finit;

finit: datatype IDE OP arg_list CP ';';

arg_list:  datatype IDE {redecl($2);insert($2,dtype,curr_scope,yylineno);}| datatype IDE ',' arg_list {redecl($2);insert($2,dtype,curr_scope,yylineno);}|;


stmt: singlestmt stmt| cpstmt stmt |;

cpstmt: OB {curr_scope++;} stmt CB {
    while(stack[tos]->scope==curr_scope){
        tos--;
    }
    curr_scope--;
};

singlestmt: declaration | function |comments | pre | expression ';';

fdef: datatype 
    IDE 
    OP arg_list CP stmt {redecl($2);insert($2,dtype,curr_scope,yylineno);} ;


constexp: INTEGER  {$$=atof($1);}
          | constexp '+' constexp {$$=$1+$3;}
          ;

expression: term 
            | expression '+' expression
            | expression '=' expression  {type_check($1,$3);}
            | expression AND expression
            | OP expression CP
            ;

term: IDE {not_decl($1);} ;

%%

int main(int argc, char *argv[]){
    extern FILE *yyin;
    yyin = fopen(argv[1],"r");

    tos++;
    node* dummy = malloc(sizeof(node));
    dummy->scope=-1;
    stack[tos] = dummy;

    if(!yyparse()){
        printf("Parsing completed\n");
    }
    else {
        printf("Parsing incomplete\n");
    }
    print_st();
    return 0;
}