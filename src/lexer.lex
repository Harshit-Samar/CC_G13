%option noyywrap

%{
#include "parser.hh"
#include <string>

extern int yyerror(std::string msg);
%}

%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
%}


%{
// Define a hash table to store macros
#define HASH_TABLE_SIZE 1000
char *hash_table[HASH_TABLE_SIZE];

// Hash function for the hash table
unsigned int hash(char *str) {
    unsigned int hash = 0;
    while (*str) {
        hash = hash * 31 + *str++;
    }
    return hash % HASH_TABLE_SIZE;
}

%}



%%

"#def " {
    // Parse the macro definition and store it in the hash table
    char* key = (char*)malloc(100*sizeof(char));
    int i = 0;
    while(1){
        char c = yyinput();
        if(c == ' ' || c == '\n')
            break;
        *(key + i) = c;
        i++;        
    }
    // printf("key = %s\n", key);
    char* value = (char*)malloc(100*sizeof(char));
    i = 0;
    int cnt = 0;
    while(1){
        char c = yyinput();
        if(c == '\\'){
            cnt++;
            continue;
        }
        if(c == '\n' && cnt == 0)
            break;
        if(c == '\n' && cnt != 0){
            cnt = 0;
        }
        *(value + i) = c;
        i++;        
    }
    
    // printf("value = %s\n", value);
 

    unsigned int h = hash(key);
    if (hash_table[h] != NULL) {
        free(hash_table[h]);
    }

    i = 0, cnt = 0;
    while(1){
        char c = *(value + i);
        if(c == '\0')
            break;
        if(c != ' ' && c != '\n'){
            cnt++;
            break;
        }
        i++;
    }
    if(cnt == 0){
        char* replaceValue = (char*)malloc(3*sizeof(char));
        *replaceValue = '1';
        hash_table[h] = replaceValue;

    }
    else{
        hash_table[h] = value;
    }

}
"#undef " {
    // Undefine the macro in the hash table
    char* key = (char*)malloc(100*sizeof(char));
    int i = 0;
    while(1){
        char c = yyinput();
        if(c == '\n')
            break;
        *(key + i) = c;
        i++;        
    }
    unsigned int h = hash(key);
    if (hash_table[h] != NULL) {
        free(hash_table[h]);
    }
}



"//"(.)*                            { /* skip */}
"/*"([^]|[]+[^/])[]+[/]        { /* skip */ }
"+"                                 { printf("HI\n");return TPLUS; }
"-"                                 { return TDASH; }
"*"                                 { return TSTAR; }
"/"                                 { return TSLASH; }
";"                                 { return TSCOL; }
"("                                 { return TLPAREN; }
")"                                 { return TRPAREN; }
"="                                 { return TEQUAL; }
"dbg"                               { return TDBG; }
"let"                               { return TLET; }
[0-9a-zA-Z]+                           { 
        yylval.lexeme = std::string(yytext); 
        if(hash_table[hash(yytext)] == NULL)
            return TIDENT;
        else{
            char* value = hash_table[hash(yytext)];
            char* valueEnd = value + strlen(value)-1;
            while(valueEnd >= value){
                unput(*valueEnd);
                // printf("yytext = %s\n", yytext);
                valueEnd--;
            }
        } 
    }
[ \t\n]                             { /* skip */ }
.                                   { yyerror("unknown char"); }

%%

std::string token_to_string(int token, const char *lexeme) {
    std::string s;
    switch (token) {
        case TPLUS: s = "TPLUS"; break;
        case TDASH: s = "TDASH"; break;
        case TSTAR: s = "TSTAR"; break;
        case TSLASH: s = "TSLASH"; break;
        case TSCOL: s = "TSCOL"; break;
        case TLPAREN: s = "TLPAREN"; break;
        case TRPAREN: s = "TRPAREN"; break;
        case TEQUAL: s = "TEQUAL"; break;
        
        case TDBG: s = "TDBG"; break;
        case TLET: s = "TLET"; break;
        
        case TINT_LIT: s = "TINT_LIT"; s.append("  ").append(lexeme); break;
        case TIDENT: s = "TIDENT"; s.append("  ").append(lexeme); break;
    }

    return s;
}