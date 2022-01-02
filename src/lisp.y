%code requires{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define DEBUG_TAG 1

    /*boolean type*/
    typedef short bool;
    #define true 1
    #define false 0

    /*The object type*/
    typedef unsigned long long type;
    #define no_type         6627973484
    #define equal_to_parent 7081252647 
    /*function type*/
    #define print_num       5758909184
    #define print_bool      5354207974
    /*constant type*/
    #define integer         9832221520
    #define boolean         5478890977


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

    /*ast tree root*/
    ast_node *root;

    void yyerror(const char *message);
    void exec();
    void traverse(ast_node *node, type parent_type);

    
}

%union {
    ast_node *AST_NODE;
}

%type<AST_NODE> stmts stmt
%type<AST_NODE> exp
%type<AST_NODE> print_stmt

%token<AST_NODE> PRINT_N PRINT_B
%token<AST_NODE> BOOL NUM

%%
program     :stmts {root = $1;}
;
stmts       :stmt stmts 
            {
                $$ = new_node(new_object(no_type, NULL, 0, false), $1, $2);
            }
            |stmt {$$ = $1;}
;
stmt        :exp {$$ = $1;}
            |print_stmt {$$ = $1;}

;
exp         :BOOL {$$ = $1;}
            |NUM {$$ = $1;}
;
print_stmt  :'(' PRINT_N exp ')' 
            {
                $$ = new_node(new_object(print_num, NULL, 0, false), $3, NULL);
            }
            |'(' PRINT_B exp ')'
            {
                $$ = new_node(new_object(print_bool, NULL, 0, false), $3, NULL);
            }

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

void exec() {
    traverse(root, root->obj->t);
}

void traverse(ast_node *node, type parent_type){
    
    if (node == NULL) return;

    switch (node->obj->t) {
        case no_type:{
            traverse(node->left_child, node->left_child->obj->t);
            traverse(node->right_child, node->right_child->obj->t);

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
            traverse(node->left_child, node->left_child->obj->t);
            //TODO: type checking
            if(DEBUG_TAG) {
                printf("print-num: ");
            }
            printf("%d\n", node->left_child->obj->ival);
            break;
        }
        case print_bool: {
            traverse(node->left_child, node->left_child->obj->t);
            //TODO: type checking
            if(DEBUG_TAG) {
                printf("print-bool: ");
            }
            printf("%s\n", node->left_child->obj->bval ? "#t" : "#f");
            break;
        }
    }
}

void yyerror(const char *message) {
    fprintf(stderr, "error: %s\n", message);
    exit(1);
}

int main() {
    yyparse();
    exec();
    return 0;
}