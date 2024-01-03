%{
    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h>
    #include<ctype.h>
    #include"lex.yy.c"
    #include"node.h"

    void yyerror(const char *s);
    int yylex();
    int yywrap();

    int memLoc = 1;
    int count=0;
    int q;
    char type[10];
    extern int countn;
    struct node *head;
    int nodeNum = 0;
    symboltable symbol_table[100];

%}

%union { 
	struct nd_obj { 
        char id[100];
        char name[100];
		struct node* nd;
	} nd_obj; 
}

%token<nd_obj> K_DO K_DOUBLE K_ELSE K_EXIT 
K_FUNCTION K_IF K_INTEGER K_PRINT_DOUBLE K_PRINT_INTEGER K_PRINT_STRING K_PROCEDURE K_PROGRAM K_READ_DOUBLE 
K_READ_INTEGER K_READ_STRING K_RETURN K_STRING K_THEN K_WHILE ASSIGN ASSIGN_PLUS ASSIGN_MINUS ASSIGN_MULTIPLY
ASSIGN_DIVIDE ASSIGN_MOD COMMA COMMENT DAND DIVIDE DOR DEQ GEQ GT LBRACKET LEQ LCURLY LPAREN LT MINUS DECREMENT
MOD MULTIPLY NE NOT PERIOD PLUS INCREMENT RBRACKET RCURLY RPAREN SEMI IDENTIFIER SCONSTANT ICONSTANT DCONSTANT

%type<nd_obj> program function_list variable variables array function_call procedure function param_list statement_list param statement opt_param_list
%type<nd_obj> var_declaration data_type assignment print_stmt read_stmt if_stmt while_stmt do_stmt return_stmt print_function read_function
%type<nd_obj> opt_assignment opt_declaration expr index arg_list opt_arg_list condition body


%left PLUS MINUS
%left MULTIPLY DIVIDE MOD
%left DOR
%left DAND
%nonassoc K_THEN
%nonassoc K_ELSE
%right NOT
%start program
%right INCREMENT DECREMENT

%%

program: K_PROGRAM {insert_type();} IDENTIFIER {add('V');} LCURLY function_list RCURLY {
    $$.nd = mknode($6.nd, NULL, "program", $3.id, nodeNum++);
    head=$$.nd;
}

;

function_list: procedure {$$.nd = mknode($1.nd, NULL, "function_list_procedure", NULL, nodeNum++);}
    | function {$$.nd = mknode($1.nd, NULL, "function_list_function", NULL, nodeNum++);}
    | function_list function {$$.nd = mknode($1.nd, $2.nd, "function_list", NULL, nodeNum++);}
    | function_list procedure {$$.nd = mknode($1.nd, $2.nd, "function_list", NULL, nodeNum++);};


function: K_FUNCTION data_type IDENTIFIER {add('F');} LPAREN param_list RPAREN LCURLY statement_list RCURLY{
    struct node* tmp = mknode($6.nd, $9.nd, "tmp", NULL, nodeNum++);
    $$.nd = mknode($2.nd, tmp, "function", $3.id, nodeNum++);
};

procedure: K_PROCEDURE IDENTIFIER {add('P');} LPAREN param_list RPAREN LCURLY statement_list RCURLY{
    $$.nd = mknode($5.nd, $8.nd, "procedure", $2.id, nodeNum++);
};

variable: IDENTIFIER {add('V'); $$.nd = mknode(NULL, NULL, "variable", $1.id, nodeNum++);}
         | array {$$.nd = $1.nd;};

variables: variable {$$.nd = $1.nd;}
         | variable COMMA variables {$$.nd = mknode($1.nd, $3.nd, "variables", NULL, nodeNum++);};

param_list: {$$.nd = NULL;}
          | param {$$.nd = $1.nd;}
          | param COMMA opt_param_list {$$.nd = mknode($1.nd, $3.nd, "param_list", NULL, nodeNum++);};

opt_param_list: param {$$.nd = mknode($1.nd, NULL, "opt_param_list", NULL, nodeNum++);}
              | param COMMA opt_param_list {$$.nd = mknode($1.nd, $3.nd, "opt_param_list", NULL, nodeNum++);};

arg_list: {$$.nd = NULL;}
         | expr {$$.nd = $1.nd;}
         | expr COMMA opt_arg_list {$$.nd = mknode($1.nd, $3.nd, "arg_list", NULL, nodeNum++);};

opt_arg_list: expr {$$.nd = $1.nd;}
            | expr COMMA opt_arg_list {$$.nd = mknode($1.nd, $3.nd, "opt_arg_list", NULL, nodeNum++);};

param: data_type variable {$$.nd = mknode($1.nd, $2.nd, "param", NULL, nodeNum++);};

array: IDENTIFIER {add('V');} LBRACKET index RBRACKET {$$.nd = mknode($4.nd, NULL, "IDENTIFIER", $1.id, nodeNum++);};

index: {$$.nd = NULL;}
         | expr {$$.nd = $1.nd;};

data_type: K_DOUBLE {$$.nd = mknode(NULL, NULL, "data_type", "double", nodeNum++); insert_type();}
         | K_INTEGER {$$.nd = mknode(NULL, NULL, "data_type", "int", nodeNum++); insert_type();}
         | K_STRING {$$.nd = mknode(NULL, NULL, "data_type", "char*", nodeNum++); insert_type();};

statement_list: statement {$$.nd = $1.nd;}
              | statement_list statement {$$.nd = mknode($1.nd, $2.nd, "statement_list", NULL, nodeNum++);};

statement: procedure {$$.nd = $1.nd;}
         | var_declaration SEMI {$$.nd = $1.nd;}
         | assignment SEMI {$$.nd = $1.nd;}
         | print_stmt SEMI {$$.nd = $1.nd;}
         | read_stmt SEMI {$$.nd = $1.nd;}
         | function_call SEMI {$$.nd = $1.nd;}
         | if_stmt {$$.nd = $1.nd;}
         | while_stmt {$$.nd = $1.nd;}
         | do_stmt {$$.nd = $1.nd;}
         | variable INCREMENT SEMI {$$.nd = mknode($1.nd, NULL, "INCREMENT", NULL, nodeNum++);}
         | variable DECREMENT SEMI {$$.nd = mknode($1.nd, NULL, "DECREMENT", NULL, nodeNum++);}
         | variable ASSIGN_PLUS expr SEMI {$$.nd = mknode($1.nd, $3.nd, "ASSIGN_PLUS", NULL, nodeNum++);}
         | variable ASSIGN_MINUS expr SEMI {$$.nd = mknode($1.nd, $3.nd, "ASSIGN_MINUS", NULL, nodeNum++);}
         | variable ASSIGN_MULTIPLY expr SEMI {$$.nd = mknode($1.nd, $3.nd, "ASSIGN_MULTIPLY", NULL, nodeNum++);}
         | variable ASSIGN_DIVIDE expr SEMI {$$.nd = mknode($1.nd, $3.nd, "ASSIGN_DIVIDE", NULL, nodeNum++);}
         | variable ASSIGN_MOD expr SEMI {$$.nd = mknode($1.nd, $3.nd, "ASSIGN_MOD", NULL, nodeNum++);}
         | return_stmt SEMI {$$.nd = $1.nd;};

var_declaration: data_type variable opt_assignment opt_declaration {
    struct node* tmp = mknode($3.nd, $4.nd, "tmp", NULL, nodeNum++);
    $$.nd = mknode($2.nd, tmp, "var_declaration", NULL, nodeNum++);};

opt_declaration: {$$.nd = NULL;}
         | COMMA variable opt_assignment opt_declaration {struct node* tmp = mknode($3.nd, $4.nd, "tmp", NULL, nodeNum++); $$.nd = mknode($2.nd, tmp, "opt_declaration", NULL, nodeNum++);};

assignment: variables ASSIGN expr opt_assignment {
    struct node* tmp = mknode($1.nd, $3.nd, "assignment_tmp", NULL, nodeNum++);
    $$.nd = mknode(tmp, $4.nd, "assignment", NULL, nodeNum++);};

opt_assignment: {$$.nd = NULL;}
         | ASSIGN expr opt_assignment {$$.nd = mknode($2.nd, $3.nd, "opt_assignment", NULL, nodeNum++);};

print_stmt: print_function LPAREN expr RPAREN {$$.nd = mknode($1.nd, $3.nd, "print_stmt", NULL, nodeNum++);};

print_function: K_PRINT_DOUBLE {$$.nd = mknode(NULL, NULL, "K_PRINT_DOUBLE", NULL, nodeNum++);}
              | K_PRINT_INTEGER {$$.nd = mknode(NULL, NULL, "K_PRINT_INTEGER", NULL, nodeNum++);}
              | K_PRINT_STRING  {$$.nd = mknode(NULL, NULL, "K_PRINT_STRING", NULL, nodeNum++);};

read_stmt: read_function LPAREN variable RPAREN {$$.nd = mknode($1.nd, $3.nd, "read_stmt", NULL, nodeNum++);};

read_function: K_READ_DOUBLE {$$.nd = mknode(NULL, NULL, "K_READ_DOUBLE", NULL, nodeNum++);}
             | K_READ_INTEGER {$$.nd = mknode(NULL, NULL, "K_READ_INTEGER", NULL, nodeNum++);}
             | K_READ_STRING {$$.nd = mknode(NULL, NULL, "K_READ_STRING", NULL, nodeNum++);};

function_call: IDENTIFIER LPAREN arg_list RPAREN {$$.nd = mknode($3.nd, NULL, "function_call", $1.id, nodeNum++);};

if_stmt: K_IF LPAREN condition RPAREN K_THEN body {$$.nd = mknode($3.nd, $6.nd, "if_stmt", NULL, nodeNum++);}
    | K_IF LPAREN condition RPAREN K_THEN body K_ELSE body {struct node* tmp = mknode($6.nd, $8.nd, "tmp", NULL, nodeNum++); $$.nd = mknode($3.nd, tmp, "if_else", NULL, nodeNum++);};
   
body: statement {$$.nd = $1.nd;}
    | LCURLY statement_list RCURLY {$$.nd = $1.nd;};

while_stmt: K_WHILE LPAREN condition RPAREN statement {$$.nd = mknode($3.nd, $5.nd, "while_stmt", NULL, nodeNum++);}
    | K_WHILE LPAREN condition RPAREN LCURLY statement_list RCURLY {$$.nd = mknode($3.nd, $6.nd, "while_stmt", NULL, nodeNum++);};

do_stmt: K_DO LPAREN assignment SEMI condition SEMI expr RPAREN statement {struct node* tmp1 = mknode($3.nd, $5.nd, "tmp1", NULL, nodeNum++);
                                                                           struct node* tmp2 = mknode($7.nd, $9.nd, "tmp2", NULL, nodeNum++);
                                                                           $$.nd = mknode(tmp1, tmp2, "do_stmt", NULL, nodeNum++);}
    | K_DO LPAREN assignment SEMI condition SEMI expr RPAREN LCURLY statement_list RCURLY  {struct node* tmp1 = mknode($3.nd, $5.nd, "tmp1", NULL, nodeNum++);
                                                                                            struct node* tmp2 = mknode($7.nd, $10.nd, "tmp2", NULL, nodeNum++);
                                                                                            $$.nd = mknode(tmp1, tmp2, "do_stmt", NULL, nodeNum++);}; 

return_stmt: K_RETURN expr {$$.nd = mknode($2.nd, NULL, "return_stmt", NULL, nodeNum++);}
    | K_RETURN variable ASSIGN expr {$$.nd = mknode($2.nd, $4.nd, "return_stmt", NULL, nodeNum++);};

expr: variable {$$.nd = $1.nd;}
    | ICONSTANT {add('I'); $$.nd = mknode(NULL, NULL, "ICONSTANT", $1.id, nodeNum++);}
    | DCONSTANT {add('D'); $$.nd = mknode(NULL, NULL, "DCONSTANT", $1.id, nodeNum++);}
    | SCONSTANT {add('S'); $$.nd = mknode(NULL, NULL, "SCONSTANT", $1.id, nodeNum++);}
    | expr PLUS expr {$$.nd = mknode($1.nd, $3.nd, "PLUS", NULL, nodeNum++);}
    | expr MINUS expr {$$.nd = mknode($1.nd, $3.nd, "MINUS", NULL, nodeNum++);}
    | expr MULTIPLY expr {$$.nd = mknode($1.nd, $3.nd, "MULTIPLY", NULL, nodeNum++);}
    | expr DIVIDE expr {$$.nd = mknode($1.nd, $3.nd, "DIVIDE", NULL, nodeNum++);}
    | expr MOD expr {$$.nd = mknode($1.nd, $3.nd, "MOD", NULL, nodeNum++);}
    | MINUS expr {$$.nd = mknode($2.nd, NULL, "UMINUS", NULL, nodeNum++);}
    | expr INCREMENT {$$.nd = mknode($1.nd, NULL, "INC", NULL, nodeNum++);}
    | expr DECREMENT {$$.nd = mknode($1.nd, NULL, "DEC", NULL, nodeNum++);}
    | LPAREN expr RPAREN {$$.nd = mknode($2.nd, NULL, "expr", NULL, nodeNum++);}
    | function_call {$$.nd = $1.nd;};

condition: expr DEQ expr {$$.nd = mknode($1.nd, $3.nd, "DEQ", NULL, nodeNum++);}
    | expr LT expr {$$.nd = mknode($1.nd, $3.nd, "LT", NULL, nodeNum++);}
    | expr LEQ expr {$$.nd = mknode($1.nd, $3.nd, "LEQ", NULL, nodeNum++);}
    | expr GT expr {$$.nd = mknode($1.nd, $3.nd, "GT", NULL, nodeNum++);}
    | expr GEQ expr {$$.nd = mknode($1.nd, $3.nd, "GEQ", NULL, nodeNum++);}
    | expr NE expr {$$.nd = mknode($1.nd, $3.nd, "NE", NULL, nodeNum++);}
    | NOT condition {$$.nd = mknode($2.nd, NULL, "NOT", NULL, nodeNum++);}
    | condition DAND condition {$$.nd = mknode($1.nd, $3.nd, "DAND", NULL, nodeNum++);}
    | condition DOR condition {$$.nd = mknode($1.nd, $3.nd, "DOR", NULL, nodeNum++);};
%%

int searchString(char *type) {
	int i;
	for(i=count-1; i>=0; i--) {
        if(strcmp(symbol_table[i].type,"ICONSTANT")!=0 && strcmp(symbol_table[i].type, "DCONSTANT")!=0){
            if(strcmp(symbol_table[i].id_name, type)==0) {
                return -1;
                break;
            }
        }
	}
	return 0;
}

int searchInt(int val){
	int i;
	for(i=count-1; i>=0; i--) {
        if(strcmp(symbol_table[i].type, "ICONSTANT") == 0){
            if(symbol_table[i].intVal == val) {
                return -1;
                break;
            }
        }
	}
	return 0;
}

int searchDouble(double val){
	int i;
	for(i=count-1; i>=0; i--) {
        if(strcmp(symbol_table[i].type, "DCONSTANT") == 0){
            if(symbol_table[i].doubleVal == val) {
                return -1;
                break;
            }
        }
	}
	return 0;
}

void add(char c) {
    if(c == 'V') {
        q=searchString(yylval.nd_obj.id);
        if(!q){
            symbol_table[count].id_name=strdup(yylval.nd_obj.id);
            symbol_table[count].data_type=strdup(type);
            symbol_table[count].line_no=countn;
            symbol_table[count].type=strdup("IDENTIFIER");
            symbol_table[count].memLoc = memLoc++;
            count++;
        }
	}
	else if(c == 'I') {
        int val = atoi(yylval.nd_obj.id);
         q=searchInt(val);
        if(!q){
            symbol_table[count].intVal=val;
            symbol_table[count].data_type=strdup("int");
            symbol_table[count].line_no=countn;
            symbol_table[count].type=strdup("ICONSTANT");
            symbol_table[count].memLoc = memLoc++;
            count++;
        }
	}
	else if(c == 'D') {
        char *modified = strdup(yylval.nd_obj.id);
        char *index= strchr(modified, 'd');
        if (index) {
            *index = 'e';
        }
        double val = atof(modified);
        free(modified);
        q=searchDouble(val);
        if(!q){
            symbol_table[count].doubleVal=val;
            symbol_table[count].data_type=strdup("double");
            symbol_table[count].line_no=countn;
            symbol_table[count].type=strdup("DCONSTANT");
            symbol_table[count].memLoc = memLoc++;
            count++;
        }
	}
	else if(c == 'S') {
        q=searchString(yylval.nd_obj.id);
        if(!q){
            symbol_table[count].id_name=strdup(yylval.nd_obj.id);
            symbol_table[count].data_type=strdup("string");
            symbol_table[count].line_no=countn;
            symbol_table[count].type=strdup("SCONSTANT");
            symbol_table[count].memLoc = memLoc++;
            count++;
        }
	}
    else if(c == 'F') {
        q=searchString(yylval.nd_obj.id);
        if(!q){
            symbol_table[count].id_name=strdup(yylval.nd_obj.id);
            symbol_table[count].data_type=strdup(type);
            symbol_table[count].line_no=countn;
            symbol_table[count].type=strdup("FUNCTION");
            symbol_table[count].memLoc = memLoc++;   
            count++;
        }  
    }
    else if(c == 'P') {
        q=searchString(yylval.nd_obj.id);
        if(!q){
            symbol_table[count].id_name=strdup(yylval.nd_obj.id);
            symbol_table[count].data_type=strdup("void");
            symbol_table[count].line_no=countn;
            symbol_table[count].type=strdup("PROCEDURE");
            symbol_table[count].memLoc = memLoc++;   
            count++;
        }  
    }
}

struct node* mknode(struct node *left, struct node *right, char *token, char* id, int num) {	
	struct node *newnode = (struct node *)malloc(sizeof(struct node));
	char *newstr = (char *)malloc(strlen(token)+1);
	strcpy(newstr, token);
    if(id != NULL){
        char *newstr2 = (char *)malloc(strlen(id)+1);
	    strcpy(newstr2, id);
        newnode->id = newstr2;
    }
	newnode->left = left;
	newnode->right = right;
	newnode->token = newstr;
    newnode->num = num;
	return(newnode);
}

void printSymbolTable(){
    printf("SYMBOL\t\t\t\tDATATYPE\tTYPE\t\tLINE NUMBER\tMEMLOC \n");
    printf("_______________________________________________________________________________________\n\n");
    for(int i=0; i<count; i++) {
        if(strcmp(symbol_table[i].type, "ICONSTANT") == 0){
            printf("%-25d\t%-15s\t%-15s\t%-15d\t%-15d\n", symbol_table[i].intVal, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, symbol_table[i].memLoc);
        }
        else if(strcmp(symbol_table[i].type, "DCONSTANT") == 0){
            printf("%-25f\t%-15s\t%-15s\t%-15d\t%-15d\n", symbol_table[i].doubleVal, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, symbol_table[i].memLoc);
        }
        else{
            printf("%-25s\t%-15s\t%-15s\t%-15d\t%-15d\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, symbol_table[i].memLoc);
        }
    }
}

void printtree(struct node* tree) {
    printf("\n\nInorder traversal of the Parse Tree:\n\n");
    printf("%-25s %-25s %-25s %-25s %-25s\n", "Node", "Token", "ID", "L-Child", "R-Child");
    printInorder(tree);
    printf("\n");
}
 
void printInorder(struct node *tree) {
    if (tree->left) {
        printInorder(tree->left);
    }
    if (tree->right) {
        printInorder(tree->right);
    }
    printf("%-25d %-25s %-25s", tree->num, tree->token, tree->id);
    if(tree->left != NULL){
        printf(" %-25d", tree->left->num);
    }else{
        printf(" %-25s", "NULL");
    }
    if(tree->right != NULL){
        printf(" %-25d", tree->right->num);
    }else{
        printf(" %-25s", "NULL");
    }
 
    printf("\n");
}

int symbolTableLookup(char* token){
    for(int i = 0; i < count; i++){
        if(symbol_table[i].id_name != NULL && strcmp(token, symbol_table[i].id_name) == 0){
            return symbol_table[i].memLoc;
        }
    }
    return -1;
}

void insert_type() {
	strcpy(type, yytext);
}

void yyerror(const char* msg) {
    fprintf(stderr, "%s\n", msg);
}

int findInt(int val){
    return 0;
}

int findDouble(double val){
    return 0;
}

int findString(char* str){
    return 0;
}

void generateCode(FILE* file, struct node* node);

void printParameters(FILE* file, struct node* node){
    if(node == NULL){
        return;
    }
    else if(strcmp(node->token, "param") == 0){
        fprintf(file, "%s %s", node->left->id, node->right->id);
    }
    else if(strcmp(node->token, "opt_param_list") == 0){
        fprintf(file, " , ");
    }
    printParameters(file, node->left);
    printParameters(file, node->right);

}

void printArguments(FILE* file, struct node* node){
    if(node == NULL){
        return;
    }
    else if(strcmp(node->token, "variable") == 0){
        fprintf(file, "Mem[SR-%d]", symbolTableLookup(node->id));
    }
    else if(strcmp(node->token, "ICONSTANT") == 0){
        fprintf(file, "%s", node->id);
    }
    else if(strcmp(node->token, "SCONSTANT") == 0){
        fprintf(file, "%s", node->id);
    }
    else if(strcmp(node->token, "DCONSTANT") == 0){
        fprintf(file, "%f", atof(node->id));
    }
    else if(strcmp(node->token, "arg_list") == 0){
        printArguments(file, node->left);
        fprintf(file, " , ");
        printArguments(file, node->right);
    }
    else if(strcmp(node->token, "opt_arg_list") == 0){
        printArguments(file, node->left);
        fprintf(file, " , ");
        printArguments(file, node->right);
    }

}

int getValue(FILE* file, struct node* node){
    if(node == NULL){
        return 0;
    }
    else if(strcmp(node->token, "SCONSTANT") == 0){
        //fprintf(file, "SMem = %s;\n", node->id);
        return 2;
    }
    else if(strcmp(node->token, "ICONSTANT") == 0){
        fprintf(file, "F[1] = %f;\n", atof(node->id));
        return 1;
    }
    else if(strcmp(node->token, "DCONSTANT") == 0){
        fprintf(file, "F[1] = %f;\n", atof(node->id));
        return 1;
    }
    else if(strcmp(node->token, "expr") == 0){
        return getValue(file, node->left);
    }
    else if(strcmp(node->token, "variable") == 0){
        fprintf(file, "F[1] = Mem[SR-%d];\n", symbolTableLookup(node->id));
        return 1;
    }
    else if(strcmp(node->token, "MULTIPLY") == 0){
        getValue(file, node->left);
        fprintf(file, "F[2] = F[1];\n");
        getValue(file, node->right);
        fprintf(file, "F[1] = F[1]*F[2];\n");
        return 1;
    }
    else if(strcmp(node->token, "DIVIDE") == 0){
        getValue(file, node->left);
        fprintf(file, "F[2] = F[1];\n");
        getValue(file, node->right);
        fprintf(file, "F[1] = F[2]/F[1];\n");
        return 1;
    }
    else if(strcmp(node->token, "ADD") == 0){
        getValue(file, node->left);
        fprintf(file, "F[2] = F[1];\n");
        getValue(file, node->right);
        fprintf(file, "F[1] = F[1]+F[2];\n");
        return 1;
    }
    else if(strcmp(node->token, "SUBTRACT") == 0){
        getValue(file, node->left);
        fprintf(file, "F[2] = F[1];\n");
        getValue(file, node->right);
        fprintf(file, "F[1] = F[2]-F[1];\n");
        return 1;
    }
    return 0;
}

void generateFunctionHeaders(FILE* file, struct node* node){
    if(node == NULL){
        return;
    }
    else if (strcmp(node->token, "function") == 0 && strcmp(node->id, "main") != 0){
        fprintf(file, "%s %s (", node->left->id, node->id);
        printParameters(file, node->right->left);
        fprintf(file, ");\n");
    } 
    else if(strcmp(node->token, "procedure") == 0){
        fprintf(file, "void %s (", node->id);
        printParameters(file, node->left);
        fprintf(file, ");\n");
    }

    generateFunctionHeaders(file, node->left);
    generateFunctionHeaders(file, node->right);
}


void generateFunctionsAndProcedures(FILE* file, struct node* node) {
    // Implement logic to traverse the AST and generate code for functions/procedures
    if(node == NULL){
        return;
    }
    else if (strcmp(node->token, "function") == 0 && strcmp(node->id, "main") != 0){
        fprintf(file, "%s %s (", node->left->id, node->id);
        printParameters(file, node->right->left);
        fprintf(file, "){\n");
        generateCode(file, node);
        fprintf(file, "}\n");
    } 
    else if(strcmp(node->token, "procedure") == 0){
        fprintf(file, "void %s (", node->id);
        printParameters(file, node->left);
        fprintf(file, "){\n");
        generateCode(file, node);
        fprintf(file, "}\n");
    }

    generateFunctionsAndProcedures(file, node->left);
    generateFunctionsAndProcedures(file, node->right);


}

void generateMain(FILE* file, struct node* node) {
    if (node == NULL) {
        return;
    }
    if (node->id != NULL && strcmp(node->id, "main") == 0) {
        fprintf(file, "int yourmain() {\nSR -= 8;\n");
        generateCode(file, node);
        fprintf(file, "SR += 8;\nreturn 0;\n}");
    } else {
        generateMain(file, node->left);
        generateMain(file, node->right);
    }
}
 
void generateCode(FILE* file, struct node* node){
    if(node == NULL){
        return;
    }
    generateCode(file, node->left);
    generateCode(file, node->right);

    if(strcmp(node->token, "IDENTIFIER") == 0){
    }
    else if(strcmp(node->token, "ICONSTANT") == 0){
        //fprintf(file,"R[1] = %d;\n", atoi(node->id));
        //fprintf(file,"F23_Time+=1;\n");
    }
    else if(strcmp(node->token, "SCONSTANT") == 0){
        fprintf(file,"SMem = %s;\n", node->id);
        fprintf(file,"F23_Time+=1;\n");
    }
    else if(strcmp(node->token, "variable") == 0){
 
    }
    else if(strcmp(node->token, "assignment") == 0){
        int ret = getValue(file, (node->left->right));
        if(ret == 1){
            fprintf(file,"Mem[SR-%d] = F[1];\n", symbolTableLookup(node->left->left->id));
            fprintf(file,"F23_Time+=20+1;\n");
        }

    }
    else if(strcmp(node->token, "print_stmt") == 0){
        if(strcmp(node->left->token, "K_PRINT_INTEGER") == 0)
        {
            fprintf(file,"print_integer(Mem[SR-%d]);\n", symbolTableLookup(node->right->id));
            fprintf(file,"F23_Time+=20;\n");
        }
        else if(strcmp(node->left->token, "K_PRINT_STRING") == 0){
            fprintf(file,"print_string(SMem);\n");
            fprintf(file,"F23_Time+=1;\n");
        }
        else if(strcmp(node->left->token, "K_PRINT_DOUBLE") == 0){
            fprintf(file,"print_double(Mem[SR-%d]);\n", symbolTableLookup(node->right->id));
            fprintf(file,"F23_Time+=1;\n");
        }
    }
    else if (strcmp(node->token, "function_call") == 0) {
        fprintf(file, "%s(", node->id);
        printArguments(file, node->left);
        fprintf(file, ");\n");
        fprintf(file, "F23_Time += 20;\n");
    }
    else if(strcmp(node->token, "return_stmt") == 0){
        if(strcmp(node->left->token, "ICONSTANT") == 0){
            fprintf(file, "return %s;\n", node->left->id);
        }
        else if(strcmp(node->left->token, "DCONSTANT") == 0){
            fprintf(file, "return %s;\n", node->left->id);
        }
        else if(strcmp(node->left->token, "SCONSTANT") == 0){
            fprintf(file, "return %s;\n", node->left->id);
        }
        else if(strcmp(node->left->token, "variable") == 0){
            fprintf(file, "return Mem[SR-%d];\n", symbolTableLookup(node->left->id));
        }
        else if(strcmp(node->left->token, "function_call") == 0){
            fprintf(file, "return %s(", node->left->id);
            printArguments(file, node->left->left);
            fprintf(file, ");\n");
        }
    }
    else if(strcmp(node->token, "if") == 0){
         fprintf(file, "return Mem[SR-%d];\n", symbolTableLookup(node->left->id));
    }
}


int main(){
    yyparse();

    FILE *yourmain;
    yourmain = fopen("yourmain.h", "w");
    if (yourmain == NULL) {
        printf("Error opening the file.\n");
        return 1;
    }
    


    generateFunctionHeaders(yourmain, head);

    generateFunctionsAndProcedures(yourmain, head);

    generateMain(yourmain, head);

    fclose(yourmain);

    printtree(head);
    printSymbolTable();
    printf("\nGenerated Code Output:\n");

}