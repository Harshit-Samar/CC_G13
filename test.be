//this is a test file containing all test cases for the project

#def TEN 10

#def STATEMENTS let a = 5; \
let x = a * 16; \
dbg a + b * x

let b = 10;
STATEMENTS;

#def NOBODY
dbg NOBODY;

#def ABC 4
#def DEF ABC + 5
#def GHI ABC * DEF
dbg GHI;

#def ABC 1
dbg ABC;
#def ABC 15
dbg ABC;

#def ABC 2
// #undef ABC  //uncomment this line to see the difference
dbg ABC;
