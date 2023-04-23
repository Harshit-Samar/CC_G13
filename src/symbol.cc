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

// bool SymbolTableForFunction::contains(std::string key) {
//     return table.find(key) != table.end();
// }

// void SymbolTableForFunction::insert(std::string key,Node* value, int type) {
//    std:: pair<Node*,int> p =std::make_pair(value,type);
//     table[key] = p;
// }

// std:: pair<Node*,int> SymbolTableForFunction::get(std::string key) {
//     return table[key];
// }