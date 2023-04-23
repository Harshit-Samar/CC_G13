#ifndef SYMBOL_HH
#define SYMBOL_HH

#include <map>
#include <string>
#include "ast.hh"


// Basic symbol table, just keeping track of prior existence and nothing else
struct SymbolTable {
    std::map<std::string, int> table;

    bool contains(std::string key);
    void insert(std::string key, int value);
    int get(std::string key);
};
// struct SymbolTableForFunction {
//     std::map<std::string, std::pair<Node*,int>> table;

//     bool contains(std::string key);
//     void insert(std::string key, Node* value, int type);
//      std:: pair<Node*,int> get(std::string key);
// };

#endif