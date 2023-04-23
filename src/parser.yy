%define api.value.type { ParserValue }

%code requires {
#include <iostream>
#include <vector>
#include <string>
#include <stack>
#include <set>
#include "parser_util.hh"
#include "symbol.hh"
#include "ast.hh"

}



%code {

#include <cstdlib>
#define INT_MAX 2147483647
#define SHORT_MAX 32767

extern int yylex();
extern int yyparse();

extern NodeStmts* final_values;

NodeBinOp *help;
int flag = 0;
SymbolTable symbol_table;
// SymbolTableForFunction symbol_table_func;
std::set<std::string> curr;
int yyerror(std::string msg);
long postorder(Node* node);
std::stack<std::pair<SymbolTable, std::set<std::string>>> scopes;
std::map<std::string, std::vector<std::string>> mp;
std::vector<std::vector<std::string>> levels;


}
 

%token TPLUS TDASH TSTAR TSLASH
%token <lexeme> TINT_LIT TIDENT
%token TINT TSHORT TLONG TLET TDBG
%token TFUN TRET TIF TELSE
%token TSCOL TLPAREN TRPAREN TEQUAL TLBRACE TRBRACE TCOMMA
%token TQUESTION TCOLON

%type <node> Expr Stmt Arg
%type <stmts> Program StmtList 
%type <stmts2> StmtList2
%type <args> ArgList 
%type <params> ParamList
%type <int_value> Type

%left TQUESTION TCOLON
%left TPLUS TDASH
%left TSTAR TSLASH

%%

Program :                
        { final_values = nullptr; }
        | StmtList 
        { final_values = $1; }
	    ;
 
StmtList : Stmt                
         { $$ = new NodeStmts(); $$->push_back($1); }
	     | StmtList Stmt 
         { $$->push_back($2); }
	     ;

StmtList2 : Stmt                
         { $$ = new NodeStmts2(); $$->push_back($1); }
	     | StmtList2 Stmt 
         { $$->push_back($2); }
	     ;


Stmt : TLET TIDENT TCOLON Type TEQUAL Expr TSCOL
     {  
        for(auto it : curr) std::cout << it << " ";
        std::cout << std::endl;
        if(symbol_table.contains($2) && curr.find($2) == curr.end()) {
            yyerror("tried to redeclare  variable.\n");
        } else {
            if(curr.find($2) != curr.end())
                curr.erase($2);
            symbol_table.insert($2, $4);
            if($4 == 0 && $6->lit_type != Node::SHORT)
                yyerror("tried to assign higher type to short.\n");
            else if($4 == 1 && $6->lit_type == Node::LONG)
                yyerror("tried to assign higher type to int.\n");
                
            long val = postorder($6);

            if(val != -1){
                if($4 == 0) {
                    printf("short val: %hd\n", (short)val);
                    $6 = new NodeShort((short)val);
                }
                else if($4 == 1) {
                    printf("int val: %d\n", (int)val);
                    $6 = new NodeInt((int)val);
                }
                else{
                    printf("long val: %ld\n", (long)val);
                    $6 = new NodeLong((long)val);
                }
            }
            if(flag == 0){
                flag = 1;
                help = (NodeBinOp*)$6;
            }
            
            $$ = new NodeAssn($2, $6, $4);
        }
     }
     | TDBG Expr TSCOL
     { 
        long val = postorder($2);

        if(val != -1){
            if($2->lit_type == 0) {
                // printf("short val: %hd\n", (short)val);
                $2 = new NodeShort((short)val);
            }
            else if($2->lit_type == 1) {
                // printf("int val: %d\n", (int)val);
                $2 = new NodeInt((int)val);
            }
            else{
                // printf("long val: %ld\n", (long)val);
                $2 = new NodeLong((long)val);
            }
        }
        $$ = new NodeDebug($2);
     }
     | TIDENT TEQUAL Expr TSCOL
     {
        if(symbol_table.contains($1)) {
            if($3->lit_type > symbol_table.get($1))
                yyerror("tried to assign higher type to lower type.\n");
            long val = postorder($3);

            if(val != -1){
                if($3->lit_type == 0) {
                    // printf("short val: %hd\n", (short)val);
                    $3 = new NodeShort((short)val);
                }
                else if($3->lit_type == 1) {
                    // printf("int val: %d\n", (int)val);
                    $3 = new NodeInt((int)val);
                }
                else{
                    // printf("long val: %ld\n", (long)val);
                    $3 = new NodeLong((long)val);
                }
            }
            $$ = new NodeReAssn($1, $3, symbol_table.get($1)); // Stmt node now points to newly created node with key TIDENT and value Expr
        } else {
            yyerror("tried to assign to undeclared variable.\n");
        }
     }
     | TFUN TIDENT TLPAREN ArgList TRPAREN TCOLON Type TLBRACE Program TRBRACE TSCOL
     {
        // if(symbol_table_func.contains($2)) {
        //     // tried to redeclare function, so error
        //     yyerror("tried to redeclare function.\n");
        // } else {
        //     symbol_table_func.insert($2, $4, $7);
        //     $$ = new NodeFunc($2, $4, $7, $9);
        // }

         
     }
     | TRET Expr TSCOL
     {
        $$ = new NodeReturn($2);

     }
     | TIF Expr Left StmtList2 Right TELSE Left StmtList2 Right 
     {  
        long val = postorder($2);
        if(val != -1){
            if($2->lit_type == 0) {
                printf("short val: %hd\n", (short)val);
                $2 = new NodeShort((short)val);
            }
            else if($2->lit_type == 1) {
                printf("int val: %d\n", (int)val);
                $2 = new NodeInt((int)val);
            }
            else{
                printf("long val: %ld\n", (long)val);
                $2 = new NodeLong((long)val);
            }
        }
        if(val == -1)
            $$ = new NodeIf($2, $4, $8); 
        else if(val == 0){
            $$ = $8;
        }
        else{
            $$ = $4;
        }

 
    }
     ;

Expr : TINT_LIT               
     {  long val = stol($1);
        if(val <= SHORT_MAX) {
            short val = stoi($1);
            // printf("short val: %hd\n", val);
            $$ = new NodeShort(val);
        }
        else if(val <= INT_MAX) {
            // printf("int val: %d\n", val);

            int val = stoi($1);
            $$ = new NodeInt(val);
        }
        else {
            // printf("long val: %ld\n", val);

            long val = stol($1);
            $$ = new NodeLong(val);
        }  
     } 
     | TIDENT
     { 
        if(symbol_table.contains($1))
            $$ = new NodeIdent($1, symbol_table.get($1));
        else
            yyerror("using undeclared variable.\n");

     }
     | Expr TPLUS Expr
     { 
        long left = postorder($1);
        long right = postorder($3);
            if(left != -1){
                if($1->lit_type == 0) {
                    // printf("short val: %hd\n", (short)left);
                    $1 = new NodeShort((short)left);
                }
                else if($1->lit_type == 1) {
                    // printf("int val: %d\n", (int)left);
                    $1 = new NodeInt((int)left);
                }
                else{
                    // printf("long val: %ld\n", (long)left);
                    $1 = new NodeLong((long)left);
                }
            }
            if(right != -1){
                if($3->lit_type == 0) {
                    // printf("short val: %hd\n", (short)right);
                    $3 = new NodeShort((short)right);
                }
                else if($3->lit_type == 1) {
                    // printf("int val: %d\n", (int)right);
                    $3 = new NodeInt((int)right);
                }
                else{
                    // printf("long val: %ld\n", (long)right);
                    $3 = new NodeLong((long)right);
                }
            }
        $$ = new NodeBinOp(NodeBinOp::PLUS, $1, $3); }
     | Expr TDASH Expr
     { 
        long left = postorder($1);
        long right = postorder($3);
            if(left != -1){
                if($1->lit_type == 0) {
                    // printf("short val: %hd\n", (short)left);
                    $1 = new NodeShort((short)left);
                }
                else if($1->lit_type == 1) {
                    // printf("int val: %d\n", (int)left);
                    $1 = new NodeInt((int)left);
                }
                else{
                    // printf("long val: %ld\n", (long)left);
                    $1 = new NodeLong((long)left);
                }
            }
            if(right != -1){
                if($3->lit_type == 0) {
                    // printf("short val: %hd\n", (short)right);
                    $3 = new NodeShort((short)right);
                }
                else if($3->lit_type == 1) {
                    // printf("int val: %d\n", (int)right);
                    $3 = new NodeInt((int)right);
                }
                else{
                    // printf("long val: %ld\n", (long)right);
                    $3 = new NodeLong((long)right);
                }
            }
        $$ = new NodeBinOp(NodeBinOp::MINUS, $1, $3); }
     | Expr TSTAR Expr
     { 
        long left = postorder($1);
        long right = postorder($3);
            if(left != -1){
                if($1->lit_type == 0) {
                    // printf("short val: %hd\n", (short)left);
                    $1 = new NodeShort((short)left);
                }
                else if($1->lit_type == 1) {
                    // printf("int val: %d\n", (int)left);
                    $1 = new NodeInt((int)left);
                }
                else{
                    // printf("long val: %ld\n", (long)left);
                    $1 = new NodeLong((long)left);
                }
            }
            if(right != -1){
                if($3->lit_type == 0) {
                    // printf("short val: %hd\n", (short)right);
                    $3 = new NodeShort((short)right);
                }
                else if($3->lit_type == 1) {
                    // printf("int val: %d\n", (int)right);
                    $3 = new NodeInt((int)right);
                }
                else{
                    // printf("long val: %ld\n", (long)right);
                    $3 = new NodeLong((long)right);
                }
            }
        $$ = new NodeBinOp(NodeBinOp::MULT, $1, $3); }
     | Expr TSLASH Expr
     { 
        long left = postorder($1);
        long right = postorder($3);
            if(left != -1){
                if($1->lit_type == 0) {
                    // printf("short val: %hd\n", (short)left);
                    $1 = new NodeShort((short)left);
                }
                else if($1->lit_type == 1) {
                    // printf("int val: %d\n", (int)left);
                    $1 = new NodeInt((int)left);
                }
                else{
                    // printf("long val: %ld\n", (long)left);
                    $1 = new NodeLong((long)left);
                }
            }
            if(right != -1){
                if($3->lit_type == 0) {
                    // printf("short val: %hd\n", (short)right);
                    $3 = new NodeShort((short)right);
                }
                else if($3->lit_type == 1) {
                    // // printf("int val: %d\n", (int)right);
                    $3 = new NodeInt((int)right);
                }
                else{
                    // printf("long val: %ld\n", (long)right);
                    $3 = new NodeLong((long)right);
                }
            }
        $$ = new NodeBinOp(NodeBinOp::DIV, $1, $3); }
     | TLPAREN Expr TRPAREN 
     { 
        long val = postorder($2);

        if(val != -1){
            if($2->lit_type == 0) {
                // printf("short val: %hd\n", (short)val);
                $2 = new NodeShort((short)val);
            }
            else if($2->lit_type == 1) {
                // printf("int val: %d\n", (int)val);
                $2 = new NodeInt((int)val);
            }
            else{
                // printf("long val: %ld\n", (long)val);
                $2 = new NodeLong((long)val);
            }
        }
        
        $$ = $2; } 
     | TIDENT TLPAREN ParamList TRPAREN
     {
        if(symbol_table.contains($1)) {
            $$ = new NodeFuncCall($1, $3, symbol_table.get($1));
        } else {
            yyerror("tried to call undeclared function.\n");
        }
     }
     ;
    
ArgList : Arg
        { $$ = new NodeArgs(); $$->push_back($1); }
        |
        ArgList TCOMMA Arg
        { $$->push_back($3); }
        |
        ;

Arg : TIDENT TCOLON Type
    { $$ = new NodeArg($1, $3); }
    ;

ParamList : Expr
        { $$ = new NodeParams(); $$->push_back($1); }
        |
        ParamList TCOMMA Expr
        { $$->push_back($3); }
        ;

Type : TSHORT { $$ = 0; }
     | TINT { $$ = 1; }
     | TLONG { $$ = 2; }
     ;

Left : TLBRACE{ 
    SymbolTable new_table=symbol_table;
    std::set<std::string> new_set;
    for(auto it: symbol_table.table)
    {
        new_set.insert(it.first);
    }
    std::pair<SymbolTable, std::set<std::string>> new_pair(new_table, curr);
    curr=new_set;
    scopes.push(new_pair);
};
Right : TRBRACE{
    if(scopes.empty()) yyerror("right brace before left brace \n");
    symbol_table=scopes.top().first;
    curr=scopes.top().second;
    Node* p = new NodeInt(120);
    new NodeAssn("cond", help, 1);
    scopes.pop();
};
%%

int yyerror(std::string msg) {
    std::cerr << "Error! " << msg << std::endl;
    exit(1);
}

long postorder(Node* root) {
    if(root == nullptr)
        return -1;
    long left = -1;
    long right = -1;
    if(root->type == Node::SHORT_LIT) {
        return ((NodeShort*)root)->value;
    }
    else if(root->type == Node::INT_LIT) {
        return ((NodeInt*)root)->value;
    }
    else if(root->type == Node::LONG_LIT) {
        return ((NodeLong*)root)->value;
    }
    if(root->type == Node::BIN_OP){
        left = postorder(((NodeBinOp*)root)->left);
        right = postorder(((NodeBinOp*)root)->right);
    }
    else{
       return -1; 
    }

    if(left != -1 && right != -1) {
        if(((NodeBinOp*)root)->op == NodeBinOp::PLUS) {
            printf("left: %ld, right: %ld\n", left, right);
            return left + right;
        } else if(((NodeBinOp*)root)->op == NodeBinOp::MINUS) {
            return left - right;
        } else if(((NodeBinOp*)root)->op == NodeBinOp::MULT) {
            return left * right;
        } else if(((NodeBinOp*)root)->op == NodeBinOp::DIV) {
            return left / right;
        }
    }
    return -1;
}