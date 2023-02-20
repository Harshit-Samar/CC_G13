%option noyywrap

%{
#include "parser.hh"
#include <string>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
extern int yyerror(std::string msg);
%}

%{
#include <unordered_map>
#include <unordered_set>
#include <vector>
using namespace std;
%}

%{
/*
The code accounts for and handles all the test cases mentioned in the assignment. 
Moreover, it also handles the following cases:
1.) considers 0 or more spaces between the macro name and \n if there is no macro value
2.) handles singleline comments within the macro
3.) handles multiline comments within the macro
*/

//cycle detection for cyclic dependencies
unordered_map<string, string> hash_table;
unordered_set<string> encountered;
vector<int> flagIf;
bool detectcycle(string key)
{
    unordered_set<string> visited;
    while(1)
    {
        if(hash_table.find(key) == hash_table.end())
            return false;
        if(visited.find(key) != visited.end())
            return true;
        visited.insert(key);
        key = hash_table[key];
    }
    return true;
}

%}



%%

"#def " {
    // Parse the macro definition and store it in the hash table
    string key;
    bool nobody=false; //flag to check if the macro value is empty
    // finding the key
    while(1){
        char c = yyinput();
        if(c == ' ')
            break;  
        if(c == '\n')
        {
            nobody=true; //if the macro value is empty
            break;
        }    
        key.push_back(c);   
    }

    encountered.insert(key);
    //cout<<"key1 = "<<key<<endl;
    string value;
    char prev;
    if(!nobody) //if the macro value is not empty(could contain spaces or an actual value)
    {
        prev= yyinput();
        if(prev=='\n')
            nobody=true;
        else
            value.push_back(prev);
    }
    bool commentpresent=false; //flag to check if singleline comment is present inside the macro defintion
    bool multilinecomment=false; //flag to check if multiline comment is present inside the macro defintion
    while(!nobody)
    {
        char curr=yyinput();
        if(curr=='\n' && prev=='\\') //if the macro value contains a \n(macro itself is multline; ie case 2 in the assignment)
        {
            value.pop_back();
            prev=curr;
            continue;
        }
        if((curr=='\n' && prev!='\\')) // endng the macro definition
            break;
        if(curr=='/' && prev=='/') //if singleline comment is present inside the macro defintion
        {
            commentpresent=true;
            value.pop_back();
            break;
        }
        if(curr=='*' && prev=='/')  //if multiline comment is present inside the macro defintion
        {
            multilinecomment=true;
            value.pop_back();
            break;
        }

        value.push_back(curr);
        prev=curr;
    }
    if(commentpresent)  //if singleline comment is present inside the macro defintion
    {
        while(1)
        {
            char curr=yyinput();   //just parsing through the comment and not storing it
            if(curr=='\n')  //the comment ends
                break;
        }
    }
    if(multilinecomment)    //if multiline comment is present inside the macro defintion
    {
        while(1)
        {
            char curr=yyinput();    //just parsing through the comment and not storing it
            if(curr=='/' && prev=='*')   //the comment ends
                break;
            prev=curr;
        }
    }
    int flag=0; //flag to check if the macro value is empty(basically only whitespaces are there)
    int len=value.length();
    for (int i=0; i<len; i++) 
    {
        if(value[i]!=' ')  
        {
            flag=1;
            break;
        }
    }
    if(flag==0)
        nobody=true;
    //cout<<"value1 = "<<value<<endl;
    if(nobody){
        hash_table[key] = "1"; //if the macro value is empty, then the value is set to 1
    }
    else{
        hash_table[key] = value; //if the macro value is not empty, then the value is set to the macro value
        // for(auto it = hash_table.begin(); it != hash_table.end(); it++)
        //         printf("key = %s, value = %s\n", it->first.c_str(), it->second.c_str());
    }
    if(detectcycle(key)) //check for cycle detection inside the hashmap. if present, then throw error
        yyerror("cycle detected");

}
"#undef " {
    // Undefine the macro in the hash table
    string key;
    //cout<<"hi";
    while(1){
        char c = yyinput();  //finding the key
        if(c == '\n' || c == ' ')
            break;
        key.push_back(c);        
    }
    if(encountered.find(key) == encountered.end())
        yyerror("Macro not yet defined");
    
    hash_table.erase(key); //erasing the key from the hashmap
    // for(auto it = hash_table.begin(); it != hash_table.end(); it++)
    //     printf("key = %s, value = %s\n", it->first.c_str(), it->second.c_str());
}

"#ifdef " {
    string key;
    //finding the key
    cout<<"ifdef size = "<<flagIf.size()<<endl;

    while(1){
        char c = yyinput();  //finding the key
        if(c == '\n')
            break;
        
        key.push_back(c);        
    }
    if(hash_table.find(key) != hash_table.end()){
        flagIf.push_back(1);

    }
    else{
        flagIf.push_back(0);
        char prev = yyinput();
        while(1){
            char curr = yyinput();

            if(curr == 0)
                yyerror("No matching #endif");
            if(curr == 'e' && prev == '#'){
                unput('e');
                unput('#');
                break;
            }

            prev = curr;
        }
    }


}

"#elif " {

    string key;
    //finding the key
    cout<<"elif = "<<flagIf[flagIf.size()-1]<<endl;

    if(flagIf[flagIf.size()-1] == 0){
        while(1){
            char c = yyinput();  //finding the key
            if(c == '\n')
                break;
            key.push_back(c);        
        }
        if(hash_table.find(key) != hash_table.end()){
            flagIf[flagIf.size()-1] = 1;
        }
        else{
            char prev = yyinput();
            while(1){
                char curr = yyinput();
                if(curr == 0)
                    yyerror("No matching #endif");
                if(curr == 'e' && prev == '#'){
                    unput('e');
                    unput('#');
                    break;
                }
                prev = curr;
            }
        }
    }
    else{
        char prev = yyinput();
        while(1){
            char curr = yyinput();
            if(curr == 0)
                yyerror("No matching #endif");
            if(curr == 'e' && prev == '#'){
                unput('e');
                unput('#');
                break;
            }
            prev = curr;
        }
    }


}

"#else" {
    cout<<"else = "<<flagIf[flagIf.size()-1]<<endl;
    if(flagIf[flagIf.size()-1] == 1){
        char prev = yyinput();
        while(1){
            char curr = yyinput();
            if(curr == 0)
                yyerror("No matching #endif");
            if(curr == 'e' && prev == '#'){
                unput('e');
                unput('#');
                break;
            }
            prev = curr;
        }
    }
    else{
        flagIf[flagIf.size()-1] = 1;
    }
}

"#endif" {
    flagIf.pop_back();
} 



"//"(.)*                            { /* skip */}   //single line comment
"/*"([^*]|\*+[^/*])*"*"+"/"        { /* skip */ }       //multiline comment
"+"                                 {  return TPLUS; }
"-"                                 { return TDASH; }
"*"                                 { return TSTAR; }
"/"                                 { return TSLASH; }
";"                                 { return TSCOL; }
"("                                 { return TLPAREN; }
")"                                 { return TRPAREN; }
"="                                 { return TEQUAL; }
"dbg"                               { return TDBG; }
"let"                               { return TLET; }
"\x00"                                {cout<<"Hi NULL"<<endl;}
[0-9]+                              { 
        yylval.lexeme = string(yytext); 
        return TINT_LIT; 
}
[a-zA-Z]+[a-zA-Z0-9]*    { 
        yylval.lexeme = string(yytext); 
        //cout<<"yytext = "<<endl;
        if(hash_table.find(string(yytext)) == hash_table.end())  //if the key is not present in the hashmap return token
        {
            // for(auto it = hash_table.begin(); it != hash_table.end(); it++)
            //     printf("key = %s, value = %s\n", it->first.c_str(), it->second.c_str());
            return TIDENT;
        }    
        else{  //find value assosciated with the key and push it back to the input stream using unput and pointer manipulation
            string value1=hash_table[string(yytext)];
            while(hash_table.find(value1) != hash_table.end()) //handing nested macros
            {
                value1=hash_table[value1];
            }
            char* value=(char*)malloc(1000*sizeof(char));
            strcpy(value, value1.c_str());
            char* valueEnd = value + strlen(value)-1;
            while(valueEnd >= value){
                unput(*valueEnd);
                // printf("yytext = %s\n", yytext);
                valueEnd--;
            }
        } 
    }
[ \t\n]                             { /* skip */ }
[[EOF]]                       {printf("BYE\n");}
.                                   { yyerror("unknown char"); }

%%

string token_to_string(int token, const char *lexeme) {
    string s;
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

