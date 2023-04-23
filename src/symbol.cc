#include "symbol.hh"

bool SymbolTable::contains(std::string key) {
    return table.find(key) != table.end();
}

void SymbolTable::insert(std::string key, int value) {
    table[key] = value;
}

int SymbolTable::get(std::string key) {
    return table[key];
}

bool FunctionSymbolTable::contains(std::string key) {
    return table.find(key) != table.end();
}

void FunctionSymbolTable::insert(std::string key, std::vector<Node*> nodes) {
    table[key] = nodes;
}

std::vector<Node*> FunctionSymbolTable::get(std::string key) {
    return table[key];
}
