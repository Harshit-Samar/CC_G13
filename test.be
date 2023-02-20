//#def THREE  
//#def HUNDRED
//#ifdef ONE
//let a = 5;
//dbg a;    
//#elif ABC
//dbg 8;
// 
//dbg 100;
//#endif



#def THREE  
#def HUNDRED
#undef HUNDRED
#ifdef TEN
let a = 5;
dbg a;    
#elif TWO
dbg 10;
#elif THREE
    #ifdef MAN
    dbg 10000;
    #elif HUNDRED
    dbg 777;  
    #else
    dbg 888;
    #endif   
dbg 100;
#endif 



//#def THREE  
//#def HUNDRED
//#undef HUNDRED
//#ifdef THREE
//dbg 5;
//#elif TWO
//    #ifdef MAN
//    dbg 10000;
//    #elif HUNDRED
//    dbg 777;  
//    #else
//    dbg 888;
//    #endif   
//dbg 100;
//#endif  