#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#ifndef NODE_H
#define NODE_H

typedef struct node {
    struct node* left;
    struct node* right;
    char* token;
    char* id;
    char* name;
    int memLoc;
    int num;
} node;

typedef struct symboltable {
    char * id_name;
    int intVal;
    double doubleVal;
    char * data_type;
    char * type;
    int line_no;
    int memLoc;
} symboltable;

int searchString(char *type);
int searchInt(int val);
int searchDouble(double val);
void add(char c);

void printtree(struct node*);
void printInorder(struct node *);
struct node* mknode(struct node *left, struct node *right, char *token, char* id, int num);
void add(char);
void insert_type();
int findInt(int);
int findDouble(double);
int findString(char*);


#endif
