%code requires{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define DEBUG_TAG 1
    #define MAX 100

    /*boolean type*/
    typedef short bool;
    #define true 1
    #define false 0

    /*The object type*/
    typedef unsigned long long type;
    
    /*random id(5000000000-10000000000) for each type*/
    #define no_type         6627973484
    #define equal_to_parent 7081252647 
    /*function type*/
    #define print_num       5758909184
    #define print_bool      5354207974
    #define op_plus         6673629119
    #define op_minus        6713860669
    #define op_multiply     6073937088
    #define op_divide       8259115088
    #define op_modulus      8662978513
    #define op_greater      6209294872
    #define op_smaller      8205064019
    #define op_equal        8982314659
    #define op_and          8876816213
    #define op_or           7164729157
    #define op_not          7042065125
    #define if_stmt         7508748275
    #define if_else         8179782206
    #define function        5615781688
    #define def_function    8004400219
    #define def_variable    7437795984
    #define get_variable    6576760245
    /*constant type*/
    #define integer         9832221520
    #define boolean         5478890977
    #define id              7903098729


    /*An object*/
    typedef struct object object;
    struct object {
        type t;

        char *name;     //an id
        int ival;       //an num
        bool bval;      //an bool
    };
    /*function of object*/
    object *new_object(type t, char *name, int ival, bool bval);

    /*An ast tree node*/
    typedef struct ast_node ast_node;
    struct ast_node {
        object *obj;

        ast_node *left_child;
        ast_node *right_child;
    };
    /*function of ast node*/
    ast_node *new_node(object *obj, ast_node *left, ast_node *right);
    /*the new node functions of different type*/
    ast_node *new_empty(ast_node *left, ast_node *right);
    ast_node *new_equal_to_parent(ast_node *left, ast_node *right);
    ast_node *new_num(int num, ast_node *left, ast_node *right);
    ast_node *new_bool(bool b, ast_node *left, ast_node *right);
    ast_node *new_id(char *c, ast_node *left, ast_node *right);
    ast_node *new_operator(type t, ast_node *left, ast_node *right);

    /*free function*/
    ast_node *free_node(ast_node *target);

    /*ast clone function*/
    ast_node *ast_clone(ast_node *target);

    /*ast tree root*/
    ast_node *root;

    /*variables*/
    ast_node *defined_variables[MAX];
    int variable_top;
    /*functions about variables*/
    void add_variables(ast_node *node);
    ast_node *get_variables(char *name);
    
    // TODO: Type checking

    void yyerror(const char *message);
    void init();
    void exec();
    void traverse(ast_node *node, type parent_type);

    
}

%union {
    ast_node *AST_NODE;
}

%type<AST_NODE> stmts stmt
%type<AST_NODE> exps exp
%type<AST_NODE> print_stmt
%type<AST_NODE> num_op
%type<AST_NODE> greater smaller equal
%type<AST_NODE> plus minus multiply divide modulus
%type<AST_NODE> logical_op
%type<AST_NODE> and_op or_op not_op
%type<AST_NODE> if_exp
%type<AST_NODE> test_exp then_exp else_exp
%type<AST_NODE> variable def_stmt

%token<AST_NODE> PRINT_N PRINT_B
%token<AST_NODE> BOOL NUM ID
%token<AST_NODE> PLS MIN MUL DIV MOD GREATER SMALLER EQUAL
%token<AST_NODE> AND OR NOT
%token<AST_NODE> IF
%token<AST_NODE> DEF

%%
program     :stmts {root = $1;}
;
stmts       :stmt stmts {$$ = new_empty($1, $2);}
            |stmt {$$ = $1;}
;
stmt        :exp {$$ = $1;}
            |print_stmt {$$ = $1;}
            |def_stmt {$$ = $1;}

;
exps        :exp exps {$$ = new_equal_to_parent($1, $2);}
            |exp {$$ = $1;}  
;
exp         :BOOL {$$ = $1;}
            |NUM {$$ = $1;}
            |num_op {$$ = $1;}
            |logical_op {$$ = $1;}
            |if_exp {$$ = $1;}
            |variable 
            {
                ast_node *node = new_operator(get_variable, NULL, NULL);
                node->obj->name = $1->obj->name;
                $$ = node;
            }
;
print_stmt  :'(' PRINT_N exp ')' 
            {
                $$ = new_operator(print_num, $3, NULL);
            }
            |'(' PRINT_B exp ')'
            {
                $$ = new_operator(print_bool, $3, NULL);
            }
;
num_op      :plus {$$ = $1;}
            |minus {$$ = $1;}
            |multiply {$$ = $1;}
            |divide {$$ = $1;}
            |modulus {$$ = $1;}
            |greater {$$ = $1;}
            |smaller {$$ = $1;}
            |equal {$$ = $1;}
;
    plus    :'(' PLS exp exps ')'
    {
        $$ = new_operator(op_plus, $3, $4);
    }
    ;
    minus   :'(' MIN exp exp ')'
    {
        $$ = new_operator(op_minus, $3, $4);
    }
    ;
    multiply:'(' MUL exp exps ')'
    {
        $$ = new_operator(op_multiply, $3, $4);
    }
    ;
    divide  :'(' DIV exp exp ')'
    {
        $$ = new_operator(op_divide, $3, $4);
    }
    ;
    modulus :'(' MOD exp exp ')'
    {
        $$ = new_operator(op_modulus, $3, $4);
    }
    ;
    greater :'(' GREATER exp exp ')'
    {
        $$ = new_operator(op_greater, $3, $4);
    }
    ;
    smaller :'(' SMALLER exp exp ')'
    {
        $$ = new_operator(op_smaller, $3, $4);
    }
    ;
    equal   :'(' EQUAL exp exps ')'
    {
        $$ = new_operator(op_equal, $3, $4);
    }
;
logical_op  :and_op {$$ = $1;}
            |or_op {$$ = $1;}
            |not_op {$$ = $1;}
;
    and_op  : '(' AND exp exps ')'
    {
        $$ = new_operator(op_and, $3, $4);
    }
    ;
    or_op   : '(' OR exp exps ')'
    {
        $$ = new_operator(op_or, $3, $4);
    }
    ;
    not_op  : '(' NOT exp ')'
    {
        $$ = new_operator(op_not, $3, NULL);
    }
;
if_exp      : '(' IF test_exp then_exp else_exp ')'
{
    ast_node *statement = new_operator(if_else, $4, $5);
    $$ = new_operator(if_stmt, $3, statement);
}
;
    test_exp: exp {$$ = $1;}
    ;
    then_exp: exp {$$ = $1;}
    ;
    else_exp: exp {$$ = $1;}
;
def_stmt    : '(' DEF variable exp ')'
{
    if($4->obj->t == function) {
        $$ = new_operator(def_function, $3, $4);
    }
    else {
        $$ = new_operator(def_variable, $3, $4);
    }
}
;
    variable: ID {$$ = $1;}
;
%%

object *new_object(type t, char *name, int ival, bool bval) {
    object *new_obj = (object *) malloc(sizeof(object));

    new_obj->t = t;
    new_obj->name = name;
    new_obj->ival = ival;
    new_obj->bval = bval;

    return new_obj;
}

ast_node *new_node(object *obj, ast_node *left, ast_node *right) {
    ast_node *new_n = (ast_node *) malloc(sizeof(ast_node));

    new_n->obj = obj;
    new_n->left_child = left;
    new_n->right_child = right;
}

ast_node *new_empty(ast_node *left, ast_node *right) {
    return new_node(new_object(no_type, NULL, 0, false), left, right);
}

ast_node *new_equal_to_parent(ast_node *left, ast_node *right) {
    return new_node(new_object(equal_to_parent, "=", 0, false), left, right);
}

ast_node *new_num(int num, ast_node *left, ast_node *right) {
    return new_node(new_object(integer, NULL, num, false), left, right);
}

ast_node *new_bool(bool b, ast_node *left, ast_node *right) {
    return new_node(new_object(boolean, NULL, 0, b), left, right);
}

ast_node *new_id(char *str, ast_node *left, ast_node *right) {
    return new_node(new_object(id, str, 0, false), left, right);
}

ast_node *new_operator(type t, ast_node *left, ast_node *right) {
    return new_node(new_object(t, NULL, 0, false), left, right);
}

ast_node *free_node(ast_node *target) {
    if (target != NULL) {
        free_node(target->left_child);
        free_node(target->right_child);

        free(target);
    }
    
    return NULL;
}

ast_node *ast_clone(ast_node *target) {
    if(target == NULL) return NULL;

    ast_node *new_node = new_empty(ast_clone(target->left_child), ast_clone(target->right_child));

    new_node->obj->t = target->obj->t;
    new_node->obj->name = target->obj->name;
    new_node->obj->ival = target->obj->ival;
    new_node->obj->bval = target->obj->bval;

    return new_node;
}

void add_variables(ast_node *node) {
    defined_variables[++variable_top] = node;
}

ast_node *get_variables(char *name) {
    for(int i = 0; i <= variable_top; i++) {
        if(strcmp(defined_variables[i]->obj->name, name) == 0) {
            return ast_clone(defined_variables[i]);
        }
    }
}

void exec() {
    traverse(root, root->obj->t);
}

void traverse(ast_node *node, type parent_type){
    
    if (node == NULL) return;

    switch (node->obj->t) {
        case no_type:{
            traverse(node->left_child, node->obj->t);
            traverse(node->right_child, node->obj->t);

            node->left_child = free_node(node->left_child);
            node->right_child = free_node(node->right_child);
            break;
        }
        case equal_to_parent:{
            node->obj->t = parent_type;
            traverse(node, node->obj->t);
            
            if(DEBUG_TAG) {
                printf("Inherit\n");
            }

            break;
        }
        case print_num: {
            traverse(node->left_child, node->obj->t);

            //TODO: type checking
            
            if(DEBUG_TAG) {
                printf("print-num: ");
            }
            printf("%d\n", node->left_child->obj->ival);

            node->left_child = free_node(node->left_child);
            node->right_child = free_node(node->right_child);
            break;
        }
        case print_bool: {
            traverse(node->left_child, node->obj->t);

            //TODO: type checking
            
            if(DEBUG_TAG) {
                printf("print-bool: ");
            }
            printf("%s\n", node->left_child->obj->bval ? "#t" : "#f");

            node->left_child = free_node(node->left_child);
            node->right_child = free_node(node->right_child);
            break;
        }
        case op_plus: {
            traverse(node->left_child, node->obj->t);
            traverse(node->right_child, node->obj->t);
            //TODO: type checking

            int num1 = node->left_child->obj->ival;
            int num2 = node->right_child->obj->ival;

            if(DEBUG_TAG) {
                printf("%d + %d = %d\n", num1, num2, num1 + num2);
            }

            node->obj->t = integer;
            node->obj->ival = num1 + num2;

            node->left_child = free_node(node->left_child);
            node->right_child = free_node(node->right_child);

            break;
        }
        case op_minus: {
            traverse(node->left_child, node->obj->t);
            traverse(node->right_child, node->obj->t);

            //TODO: type checking

            int num1 = node->left_child->obj->ival;
            int num2 = node->right_child->obj->ival;

            if(DEBUG_TAG) {
                printf("%d - %d = %d\n", num1, num2, num1 - num2);
            }

            node->obj->t = integer;
            node->obj->ival = num1 - num2;

            node->left_child = free_node(node->left_child);
            node->right_child = free_node(node->right_child);

            break;
        }
        case op_multiply: {
            traverse(node->left_child, node->obj->t);
            traverse(node->right_child, node->obj->t);

            //TODO: type checking

            int num1 = node->left_child->obj->ival;
            int num2 = node->right_child->obj->ival;

            if(DEBUG_TAG) {
                printf("%d * %d = %d\n", num1, num2, num1 * num2);
            }

            node->obj->t = integer;
            node->obj->ival = num1 * num2;

            node->left_child = free_node(node->left_child);
            node->right_child = free_node(node->right_child);

            break;
        }
        case op_divide: {
            traverse(node->left_child, node->obj->t);
            traverse(node->right_child, node->obj->t);

            //TODO: type checking

            int num1 = node->left_child->obj->ival;
            int num2 = node->right_child->obj->ival;

            if(DEBUG_TAG) {
                printf("%d / %d = %d\n", num1, num2, num1 / num2);
            }

            node->obj->t = integer;
            node->obj->ival = num1 / num2;

            node->left_child = free_node(node->left_child);
            node->right_child = free_node(node->right_child);

            break;
        }
        case op_modulus: {
            traverse(node->left_child, node->obj->t);
            traverse(node->right_child, node->obj->t);

            //TODO: type checking

            int num1 = node->left_child->obj->ival;
            int num2 = node->right_child->obj->ival;

            if(DEBUG_TAG) {
                printf("%d mod %d = %d\n", num1, num2, num1 % num2);
            }

            node->obj->t = integer;
            node->obj->ival = num1 % num2;

            node->left_child = free_node(node->left_child);
            node->right_child = free_node(node->right_child);

            break;
        }
        case op_greater: {
            traverse(node->left_child, node->obj->t);
            traverse(node->right_child, node->obj->t);

            //TODO: type checking

            int num1 = node->left_child->obj->ival;
            int num2 = node->right_child->obj->ival;

            if(DEBUG_TAG) {
                printf("%d > %d ? \"%s\"\n", num1, num2, (num1 > num2 ? "#t" : "#f"));
            }

            node->obj->t = boolean;
            node->obj->bval = (num1 > num2 ? true : false);

            node->left_child = free_node(node->left_child);
            node->right_child = free_node(node->right_child);

            break;
        }
        case op_smaller: {
            traverse(node->left_child, node->obj->t);
            traverse(node->right_child, node->obj->t);

            //TODO: type checking

            int num1 = node->left_child->obj->ival;
            int num2 = node->right_child->obj->ival;

            if(DEBUG_TAG) {
                printf("%d < %d ? \"%s\"\n", num1, num2, (num1 < num2 ? "#t" : "#f"));
            }

            node->obj->t = boolean;
            node->obj->bval = (num1 < num2 ? true : false);

            node->left_child = free_node(node->left_child);
            node->right_child = free_node(node->right_child);
            break;
        }
        case op_equal: {
            traverse(node->left_child, node->obj->t);
            traverse(node->right_child, node->obj->t);

            char *check =  node->right_child->obj->name;

            //TODO: type checking

            int num1 = node->left_child->obj->ival;
            int num2 = node->right_child->obj->ival;
            

            if(DEBUG_TAG) {
                printf("%d = %d ? \"%s\"\n", num1, num2, (num1 == num2 ? "#t" : "#f"));
            }

            node->obj->t = boolean;
            node->obj->bval = (num1 == num2 ? true : false);
            node->obj->ival = num1;

            if(check == "="){
                node->obj->bval *= node->right_child->obj->bval;
                if(DEBUG_TAG) printf("Final Result: %s\n", (node->obj->bval ? "#t" : "#f"));
            }
            node->left_child = free_node(node->left_child);
            node->right_child = free_node(node->right_child);
            break;
        }
        case op_and: {
            traverse(node->left_child, node->obj->t);
            traverse(node->right_child, node->obj->t);

            //TODO: type checking

            bool val1 = node->left_child->obj->bval;
            bool val2 = node->right_child->obj->bval;

            if(DEBUG_TAG) {
                printf("%s and %s = %s\n", (val1 ? "#t" : "#f"), (val2 ? "#t" : "#f"), (val1 * val2 ? "#t" : "#f"));
            }

            node->obj->t = boolean;
            node->obj->bval = (val1 * val2 ? true : false);

            node->left_child = free_node(node->left_child);
            node->right_child = free_node(node->right_child);
            break;
        }
        case op_or: {
            traverse(node->left_child, node->obj->t);
            traverse(node->right_child, node->obj->t);

            //TODO: type checking

            bool val1 = node->left_child->obj->bval;
            bool val2 = node->right_child->obj->bval;

            if(DEBUG_TAG) {
                printf("%s or %s = %s\n", (val1 ? "#t" : "#f"), (val2 ? "#t" : "#f"), (val1 + val2 ? "#t" : "#f"));
            }

            node->obj->t = boolean;
            node->obj->bval = (val1 + val2 ? true : false);

            node->left_child = free_node(node->left_child);
            node->right_child = free_node(node->right_child);
            break;
        }
        case op_not: {
            traverse(node->left_child, node->obj->t);

            //TODO: type checking

            bool val = node->left_child->obj->bval;

            if(DEBUG_TAG) {
                printf("not %s = %s\n", (val ? "#t" : "#f"), (!val ? "#t" : "#f"));
            }

            node->obj->t = boolean;
            node->obj->bval = (!val ? true : false);

            node->left_child = free_node(node->left_child);
            node->right_child = free_node(node->right_child);
            break;
        }
        case if_stmt: {
            traverse(node->left_child, node->obj->t);

            //TODO: type checking

            if(node->left_child->obj->bval) {
                if(DEBUG_TAG) printf("Go to true statement\n");

                traverse(node->right_child->left_child, node->right_child->obj->t);

                node->obj->t = node->right_child->left_child->obj->t;
                node->obj->ival = node->right_child->left_child->obj->ival;
                node->obj->bval = node->right_child->left_child->obj->bval;
            }
            else {
                if(DEBUG_TAG) printf("Go to false statement\n");
                traverse(node->right_child->right_child, node->right_child->obj->t);

                node->obj->t = node->right_child->right_child->obj->t;
                node->obj->ival = node->right_child->right_child->obj->ival;
                node->obj->bval = node->right_child->right_child->obj->bval;
            }

            node->left_child = free_node(node->left_child);
            node->right_child = free_node(node->right_child);

            break;
        }
        case def_variable: {
            node->right_child->obj->name = node->left_child->obj->name;
            
            add_variables(node->right_child);
            break;
        }
        case get_variable: {
            ast_node *result = get_variables(node->obj->name);

            node->obj->t = result->obj->t;
            node->obj->ival = result->obj->ival;
            node->obj->bval = result->obj->bval;

            node->right_child = ast_clone(result->right_child);
            node->left_child = ast_clone(result->left_child);

            traverse(node, parent_type);

            if(DEBUG_TAG) {
                printf("find variable: %s\n", node->obj->name);
            }

            break;
        }
    }
}

void yyerror(const char *message) {
    fprintf(stderr, "error: %s\n", message);
    exit(1);
}

void init() {
    variable_top = -1;
}

int main() {
    init();
    yyparse();
    exec();
    return 0;
}