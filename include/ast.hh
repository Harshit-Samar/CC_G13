#ifndef AST_HH
#define AST_HH

#include <llvm/IR/Value.h>
#include <string>
#include <vector>

struct LLVMCompiler;

/**
Base node class. Defined as `abstract`.
*/
struct Node {
    enum NodeType {
        BIN_OP, INT_LIT, SHORT_LIT, LONG_LIT, STMTS, ASSN, DBG, IDENT, REASSN, TERNARY, IF
    } type;
    enum LiteralType{
        SHORT, INT, LONG
    } lit_type;
    
    virtual std::string to_string() = 0;
    virtual llvm::Value *llvm_codegen(LLVMCompiler *compiler) = 0;
};

/**
    Node for list of statements
*/
struct NodeStmts : public Node {
    std::vector<Node*> list;

    NodeStmts();
    void push_back(Node *node);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for binary operations
*/
struct NodeBinOp : public Node {
    enum Op {
        PLUS, MINUS, MULT, DIV
    } op;

    Node *left, *right;

    NodeBinOp(Op op, Node *leftptr, Node *rightptr);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for integer literals
*/
struct NodeShort : public Node {
    short value;

    NodeShort(short val);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeInt : public Node {
    int value;

    NodeInt(int val);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeLong : public Node {
    long value;

    NodeLong(long val);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for variable assignments
*/
struct NodeAssn : public Node {
    std::string identifier;
    Node *expression;

    NodeAssn(std::string id, Node *expr, int litType);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};



/**
    Node for `dbg` statements
*/
struct NodeDebug : public Node {
    Node *expression;

    NodeDebug(Node *expr);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for idnetifiers
*/
struct NodeIdent : public Node {
    std::string identifier;

    NodeIdent(std::string ident, int litType);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/** 
 * Node for ternary operations
*/
/**
    Node for variable re-assignments
*/
struct NodeReAssn : public Node {
    std::string identifier;
    Node *expression;

    NodeReAssn(std::string id, Node *expr, int litType);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeTernary : public Node {


    Node *condition, *true_expr, *false_expr;

    NodeTernary(Node *condition, Node *true_expr, Node *false_expr);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};


/***********************************
           ___________
           |         |
           |NEW NODES|
           |_________|

************************************/

struct NodeParams : public Node {
    std::vector<Node*> list;

    NodeParams();
    void push_back(Node *node);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeArgs : public Node {
    std::vector<Node*> list;

    NodeArgs();
    void push_back(Node *node);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeArg : public Node {
    std::string identifier;
    Node *expression;

    NodeArg(std::string id, int litType);
    // create a function to get the value of the expression
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};


struct NodeFunc : public Node {
    std::string identifier;
    Node *args;
    int litType;
    Node *body;
    Node *params;

    NodeFunc(std::string id, Node *argumentss, int litType, Node *func_body);
    // create a function to get the value of the args
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeReturn : public Node {
    Node *expression;

    NodeReturn(Node *expr);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeFuncCall : public Node {
    std::string identifier;
    Node *params;

    NodeFuncCall(std::string id, Node *parameters, int litType);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};


struct NodeIf : public Node {
    Node *condition;
    Node *thn;
    Node *els;

    NodeIf(Node *cond, Node *th, Node *el);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};


struct NodeStmts2 : public Node {
    std::vector<Node*> list;

    NodeStmts2();
    void push_back(Node *node);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};
#endif