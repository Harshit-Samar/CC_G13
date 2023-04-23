#include "llvmcodegen.hh"
#include "ast.hh"
#include <iostream>
#include <string.h>
#include <llvm/Support/FileSystem.h>
#include <llvm/IR/Constant.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/GlobalValue.h>
#include <llvm/IR/Verifier.h>
#include <llvm/Bitcode/BitcodeWriter.h>
#include <vector>

#define MAIN_FUNC compiler->module.getFunction("main")

/*
The documentation for LLVM codegen, and how exactly this file works can be found
ins `docs/llvm.md`
*/

void LLVMCompiler::compile(Node *root) {
    /* Adding reference to print_i in the runtime library */
    // void printi();
    FunctionType *printi_func_type = FunctionType::get(
        builder.getVoidTy(),
        {builder.getInt64Ty()},
        false
    );
    Function::Create(
        printi_func_type,
        GlobalValue::ExternalLinkage,
        "printi",
        &module
    );
    // FunctionType *prints_func_type = FunctionType::get(
    //     builder.getVoidTy(),
    //     {builder.getInt64Ty()},
    //     false
    // );
    // Function::Create(
    //     prints_func_type,
    //     GlobalValue::ExternalLinkage,
    //     "prints",
    //     &module
    // );
    // FunctionType *printl_func_type = FunctionType::get(
    //     builder.getVoidTy(),
    //     {builder.getInt64Ty()},
    //     false
    // );
    // Function::Create(
    //     printl_func_type,
    //     GlobalValue::ExternalLinkage,
    //     "printl",
    //     &module
    // );
    /* we can get this later 
        module.getFunction("printi");
    */
 
    /* Main Function */
    // int main();
    FunctionType *main_func_type = FunctionType::get(
        builder.getInt64Ty(), {}, false /* is vararg */
    );
    Function *main_func = Function::Create(
        main_func_type,
        GlobalValue::ExternalLinkage,
        "main",
        &module
    );

    // create main function block
    BasicBlock *main_func_entry_bb = BasicBlock::Create(
        *context,
        "entry",
        main_func
    );

    // move the builder to the start of the main function block
    builder.SetInsertPoint(main_func_entry_bb);

    root->llvm_codegen(this);

    // return 0;
    builder.CreateRet(builder.getInt64(0));
}

void LLVMCompiler::dump() {
    outs() << module;
}

void LLVMCompiler::write(std::string file_name) {
    std::error_code EC;
    raw_fd_ostream fout(file_name, EC, sys::fs::OF_None);
    WriteBitcodeToFile(module, fout);
    fout.flush();
    fout.close();
}

//  ┌―――――――――――――――――――――┐  //
//  │ AST -> LLVM Codegen │  //
//  └―――――――――――――――――――――┘  //

// codegen for statements
Value *NodeStmts::llvm_codegen(LLVMCompiler *compiler) {
    Value *last = nullptr;
    for(auto node : list) {
        last = node->llvm_codegen(compiler);
    }

    return last;
}

Value *NodeStmts2::llvm_codegen(LLVMCompiler *compiler) {
    Value *last = nullptr;
    for(auto node : list) {
        last = node->llvm_codegen(compiler);
    }

    return last;
}

Value *NodeDebug::llvm_codegen(LLVMCompiler *compiler) {
    Value *expr = expression->llvm_codegen(compiler);
    Function *print_func = nullptr;
    if(lit_type == Node::SHORT){
        printf("SHORT DEBUG\n");
        print_func = compiler->module.getFunction("printi");
    }
    else if(lit_type == Node::INT){
        printf("INT DEBUG\n");
        print_func = compiler->module.getFunction("printi");
    }
    else if(lit_type == Node::LONG){
        printf("LONG DEBUG\n");
        print_func = compiler->module.getFunction("printi");
    }
    compiler->builder.CreateCall(print_func, {expr});

    return expr;
}
 
Value *NodeShort::llvm_codegen(LLVMCompiler *compiler) {
    printf("SHORT %hd\n", value);
    return compiler->builder.getInt64(value);
} 
Value *NodeInt::llvm_codegen(LLVMCompiler *compiler) {
    printf("INT %d\n", value);
    return compiler->builder.getInt64(value);
}
Value *NodeLong::llvm_codegen(LLVMCompiler *compiler) {
    printf("LONG %ld\n", value);
    return compiler->builder.getInt64(value); 
}



Value *NodeBinOp::llvm_codegen(LLVMCompiler *compiler) {
    Value *left_expr = left->llvm_codegen(compiler);
    Value *right_expr = right->llvm_codegen(compiler);

    switch(op) {
        case PLUS:
        return compiler->builder.CreateAdd(left_expr, right_expr, "addtmp");
        case MINUS:
        return compiler->builder.CreateSub(left_expr, right_expr, "minustmp");
        case MULT:
        return compiler->builder.CreateMul(left_expr, right_expr, "multtmp");
        case DIV:
        return compiler->builder.CreateSDiv(left_expr, right_expr, "divtmp");
    }
}


Value *NodeAssn::llvm_codegen(LLVMCompiler *compiler) {
    Value *expr = expression->llvm_codegen(compiler);

    IRBuilder<> temp_builder(
        &MAIN_FUNC->getEntryBlock(),
        MAIN_FUNC->getEntryBlock().begin()
    ); 
    AllocaInst *alloc = nullptr;
    if(lit_type == Node::SHORT)
        alloc = temp_builder.CreateAlloca(compiler->builder.getInt64Ty(), 0, identifier);
    else if(lit_type == Node::INT){
        printf("INT ALLOC\n");
        alloc = temp_builder.CreateAlloca(compiler->builder.getInt64Ty(), 0, identifier);
    }
    else if(lit_type == Node::LONG){
        printf("LONG ALLOC\n");
        alloc = temp_builder.CreateAlloca(compiler->builder.getInt64Ty(), 0, identifier);
    }

    compiler->locals[identifier] = alloc;

    return compiler->builder.CreateStore(expr, alloc);
}
 
Value *NodeIdent::llvm_codegen(LLVMCompiler *compiler) {
    AllocaInst *alloc = compiler->locals[identifier];
    std::cout<<"HELLO "<<identifier<<std::endl;
    if(lit_type == Node::SHORT)
        return compiler->builder.CreateLoad(compiler->builder.getInt64Ty(), alloc, identifier);
    else if(lit_type == Node::INT){
        printf("INT ALLOC\n");
        return compiler->builder.CreateLoad(compiler->builder.getInt64Ty(), alloc, identifier);
    }
    else if(lit_type == Node::LONG)
        return compiler->builder.CreateLoad(compiler->builder.getInt64Ty(), alloc, identifier);

    // if your LLVM_MAJOR_VERSION >= 14
    return compiler->builder.CreateLoad(compiler->builder.getInt64Ty(), alloc, identifier);
}

Value* NodeReAssn::llvm_codegen(LLVMCompiler* compiler){
    Value *expr = expression->llvm_codegen(compiler);
    AllocaInst *alloc = compiler->locals[identifier];
    return compiler->builder.CreateStore(expr, alloc);
}

Value* NodeTernary::llvm_codegen(LLVMCompiler* compiler){
    return nullptr;
}


Value* NodeParams::llvm_codegen(LLVMCompiler* compiler){
    return nullptr;
}
Value* NodeArgs::llvm_codegen(LLVMCompiler* compiler){
    return nullptr;
}
Value* NodeArg::llvm_codegen(LLVMCompiler* compiler){
    return nullptr;
}
Value* NodeFunc::llvm_codegen(LLVMCompiler* compiler){
    return nullptr;
}
Value* NodeReturn::llvm_codegen(LLVMCompiler* compiler){
    return nullptr;
}
Value* NodeFuncCall::llvm_codegen(LLVMCompiler* compiler){
    AllocaInst *alloc = compiler->locals[identifier];
    return nullptr;
}

Value *NodeIf::llvm_codegen(LLVMCompiler *compiler) {
    Value *CondV = condition->llvm_codegen(compiler);

    CondV = compiler->builder.CreateICmpNE(CondV, compiler->builder.getInt64(0), "ifcond");
    //CreateICmpNE (Value *LHS, Value *RHS, const Twine &Name="")

    Function *TheFunction = compiler->builder.GetInsertBlock()->getParent();

    // Create blocks for the then and else cases.  Insert the 'then' block at the
    // end of the function.
    BasicBlock *ThenBB = BasicBlock::Create(*compiler->context, "then", TheFunction);
    BasicBlock *ElseBB = BasicBlock::Create(*compiler->context, "else", TheFunction);
    BasicBlock *MergeBB = BasicBlock::Create(*compiler->context, "ifcont", TheFunction);

    compiler->builder.CreateCondBr(CondV, ThenBB, ElseBB);
    compiler->builder.SetInsertPoint(ThenBB);

    Value *ThenV = thn->llvm_codegen(compiler);
    if (!ThenV)
    return nullptr;

    compiler->builder.CreateBr(MergeBB);
//     // Codegen of 'Then' can change the current block, update ThenBB for the PHI.
    ThenBB = compiler->builder.GetInsertBlock();
    //TheFunction->insert(TheFunction->end(), ElseBB);
    compiler->builder.SetInsertPoint(ElseBB);

    Value *ElseV = els->llvm_codegen(compiler);
    if (!ElseV)
    return nullptr;

    compiler->builder.CreateBr(MergeBB);
//     // codegen of 'Else' can change the current block, update ElseBB for the PHI.
    ElseBB = compiler->builder.GetInsertBlock();
    //TheFunction->insert(TheFunction->end(), MergeBB);
    compiler->builder.SetInsertPoint(MergeBB);
    PHINode *PN =  compiler->builder.CreatePHI(Type::getInt64Ty(*compiler->context), 2, "iftmp");

    PN->addIncoming(ThenV, ThenBB);
    PN->addIncoming(ElseV, ElseBB);
    return PN;

}

#undef MAIN_FUNC