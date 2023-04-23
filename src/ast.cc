#include "ast.hh"

#include <string>
#include <vector>

NodeBinOp::NodeBinOp(NodeBinOp::Op ope, Node *leftptr, Node *rightptr) {
    type = BIN_OP;
    if(leftptr->lit_type == Node::SHORT && rightptr->lit_type == Node::SHORT){
        lit_type = Node::SHORT;
        printf("Warning1: No loss of precision\n");
    }
    else if(leftptr->lit_type == Node::INT && rightptr->lit_type == Node::INT){
        lit_type = Node::INT;
        printf("Warning2: No loss of precision\n");
    }
    else if(leftptr->lit_type == Node::LONG && rightptr->lit_type == Node::LONG){
        lit_type = Node::LONG;
        printf("Warning3: No loss of precision\n");
    }
    else if(leftptr->lit_type == Node::SHORT && rightptr->lit_type == Node::INT){
        lit_type = Node::INT;
        printf("Warning4: Possible loss of precision\n");
    }
    else if(leftptr->lit_type == Node::SHORT && rightptr->lit_type == Node::LONG){
        lit_type = Node::LONG;
        printf("Warning5: Possible loss of precision\n");
    }
    else if(leftptr->lit_type == Node::INT && rightptr->lit_type == Node::SHORT){
        lit_type = Node::INT;
        printf("Warning6: Possible loss of precision\n");
    }
    else if(leftptr->lit_type == Node::INT && rightptr->lit_type == Node::LONG){
        lit_type = Node::LONG;
        printf("Warning7: Possible loss of precision\n");

    }
    else if(leftptr->lit_type == Node::LONG && rightptr->lit_type == Node::SHORT){
        lit_type = Node::LONG;
        printf("Warning8: Possible loss of precision\n");
    }
    else if(leftptr->lit_type == Node::LONG && rightptr->lit_type == Node::INT){
        lit_type = Node::LONG;
        printf("Warning9: Possible loss of precision\n");
    }
    else
        printf("Error: Invalid types for binary operation");
    
    op = ope;
    left = leftptr;
    right = rightptr;
}

std::string NodeBinOp::to_string() {
    std::string out = "(";
    switch(op) {
        case PLUS: out += '+'; break;
        case MINUS: out += '-'; break;
        case MULT: out += '*'; break;
        case DIV: out += '/'; break;
    }

    out += ' ' + left->to_string() + ' ' + right->to_string() + ')';

    return out;
}

NodeShort::NodeShort(short val) {
    type = SHORT_LIT;
    lit_type = SHORT;
    value = val;
}

std::string NodeShort::to_string() {
    return std::to_string(value);
}

NodeInt::NodeInt(int val) {
    type = INT_LIT;
    lit_type = INT;
    value = val;
}

std::string NodeInt::to_string() {
    return std::to_string(value);
}


NodeLong::NodeLong(long val) {
    type = LONG_LIT;
    lit_type = LONG;
    value = val;
    // printf("Val %ld\n", value);
}

std::string NodeLong::to_string() {
    return std::to_string(value);
}

NodeStmts::NodeStmts() {
    type = STMTS;
    list = std::vector<Node*>();
}

void NodeStmts::push_back(Node *node) {
    list.push_back(node);
}

std::string NodeStmts::to_string() {
    std::string out = "(begin";
    for(auto i : list) {
        out += " " + i->to_string();
    }

    out += ')';
    FILE *f = fopen("opt.txt", "w");
    fputs(out.c_str(), f);
    fclose(f);
    return out;
}


NodeAssn::NodeAssn(std::string id, Node *expr, int litType) {
    type = ASSN;
    lit_type = litType == 0? SHORT : litType == 1? INT : LONG;
    identifier = id;
    expression = expr;
}

std::string NodeAssn::to_string() {
    return "(let " + identifier + " " + expression->to_string() + ")";
}

NodeDebug::NodeDebug(Node *expr) {
    type = DBG;
    lit_type = expr->lit_type;
    expression = expr;
}

std::string NodeDebug::to_string() {
    return "(dbg " + expression->to_string() + ")";
}

NodeIdent::NodeIdent(std::string ident, int litType) {
    type = IDENT;
    lit_type = litType == 0? SHORT : litType == 1? INT : LONG;
    identifier = ident;
}
std::string NodeIdent::to_string() {
    return identifier;
}

NodeReAssn::NodeReAssn(std::string id, Node* expr, int litType){
    type = REASSN;
    lit_type = litType == 0? SHORT : litType == 1? INT : LONG;
    identifier = id;
    expression = expr;
}

std::string NodeReAssn::to_string(){
    return "(assign " + identifier + " " + expression->to_string() + ")";
}

NodeTernary::NodeTernary(Node* cond, Node* correct, Node* wrong){
    type = TERNARY;
    condition = cond;
    true_expr = correct;
    false_expr = wrong;
}

std::string NodeTernary::to_string(){
    return "(?: " + condition->to_string() + " " + true_expr->to_string() + " " + false_expr->to_string() + ")";
}

/***********************************
           ___________
           |         |
           |NEW NODES|
           |_________|

************************************/

NodeParams::NodeParams() {
    // type = STMTS;
    list = std::vector<Node*>();
}

std::string NodeParams::to_string(){
    return "()";
}

void NodeParams::push_back(Node *node) {
    list.push_back(node);
}

NodeArgs::NodeArgs() {
    // type = STMTS;
    list = std::vector<Node*>();
}

std::string NodeArgs::to_string(){
    return "()";
}

void NodeArgs::push_back(Node *node) {
    list.push_back(node);
}

NodeArg::NodeArg(std::string id, int litType) {
    // type = ARG;
    lit_type = litType == 0? SHORT : litType == 1? INT : LONG;
    identifier = id;
}

std::string NodeArg::to_string(){
    return "()";
}


NodeFunc::NodeFunc(std::string id, Node *arguments, int litType, Node *func_body){
    // type = FUNC;
    lit_type = litType == 0? SHORT : litType == 1? INT : LONG;
    identifier = id;
    args = arguments;
    body = func_body;
}

std::string NodeFunc::to_string(){
    return "()";
}

NodeReturn::NodeReturn(Node *expr){
    // type = RETURN;
    lit_type = expr->lit_type;
    expression = expr;
}

std::string NodeReturn::to_string(){
    return "()";
}

NodeFuncCall::NodeFuncCall(std::string id, Node *parameters, int litType){
    // type = FUNC_CALL;
    lit_type = litType == 0? SHORT : litType == 1? INT : LONG;
    identifier = id;
    params = parameters;
}

std::string NodeFuncCall::to_string(){
    return "()";
}

NodeIf::NodeIf(Node *cond, Node *th, Node *el){
    type = IF;
    condition = cond;
    thn = th;
    els = el;
}

std::string NodeIf::to_string() {
    return "(if " + condition->to_string() + " " + thn->to_string() + " else " + els->to_string() + ")";
}


NodeStmts2::NodeStmts2() {
    type = STMTS;
    list = std::vector<Node*>();
}

void NodeStmts2::push_back(Node *node) {
    list.push_back(node);
}

std::string NodeStmts2::to_string() {
    std::string out = "";
    for(auto i : list) {
        out += " " + i->to_string();
    }

    return out;
}