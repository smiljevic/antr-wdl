parser grammar WDLParser;

options {
  tokenVocab=WDLLexer;
}

document
    :   import_statement* struct* (task* workflow* | workflow* task*)
    ;

import_statement
    : Import String (As Identifier)?
    ;

task
    : Task Identifier LeftCurlyBrace taskElement+ RightCurlyBrace
    ;

taskElement
    : input
    | declaration+
    | command
    | runtime
    | taskOutput
    | parameterMeta
    | meta
    ;

struct
    : Struct Identifier LeftCurlyBrace declaration* RightCurlyBrace
    ;

workflow
    : Workflow Identifier? LeftCurlyBrace workflowElement* RightCurlyBrace
    ;

workflowElement
    :   input
    |   statement
    |   wfOutput
    |   parameterMeta
    |   meta
    ;

input
    : Input LeftCurlyBrace declaration* RightCurlyBrace
    ;

command
    : CommandStartV1 commandPartV1* CommandEndV1
    | CommandStartV2 commandPartV2* CommandEndV2
    ;

commandPartV1
    : commandPartVar
    | CommandPartStringV1
    ;

commandPartV2
    : commandPartVar
    | CommandPartStringV2
    ;

commandPartVar
    : CommandPartVarStart commandPartVarOption* (Identifier | expression) RCurly
    ;
commandPartVarOption
    : (Sep | Quote | Default) expression
    | (Boolean expression Boolean expression)
    ;

runtime
    : Runtime LeftCurlyBrace (Identifier Colon expression)* RightCurlyBrace
    ;

taskOutput
    : Output LeftCurlyBrace (type Identifier '=' expression)* RightCurlyBrace
    ;

wfOutput
    : Output LeftCurlyBrace (type Identifier '=' expression)* RightCurlyBrace
    ;

parameterMeta
    : ParameterMeta LeftCurlyBrace (Identifier (Colon|'=') String)* RightCurlyBrace
    ;

meta
    : Meta LeftCurlyBrace (Identifier (Colon|'=') String)* RightCurlyBrace
    ;

call
    : Call namespaceIdentifier (As Identifier)?  callBody?
    ;

callBody
    : LeftCurlyBrace declaration* inputs? RightCurlyBrace
    ;

inputs
    : Input Colon variableMappings
    ;

variableMappings
    : variableMappingKv (',' variableMappingKv)*
    ;

variableMappingKv
    : Identifier '=' expression
    ;

scatter
    : Scatter '(' scatterIterationStatement ')' LeftCurlyBrace statement* RightCurlyBrace
    ;

scatterIterationStatement
    : Identifier In expression
    ;

loop
    : While '(' expression ')' LeftCurlyBrace statement* RightCurlyBrace
    ;

condition
    : If '(' expression ')' LeftCurlyBrace ifbranch RightCurlyBrace (Else LeftCurlyBrace elsebranch RightCurlyBrace)?
    ;

ifbranch: statement* ;

elsebranch: statement* ;

statement
    : declaration
    | expression
    | call
    | loop
    | condition
    | scatter
    ;

declaration
    : type Identifier ('=' expression)?
    ;

namespaceIdentifier
    :  Identifier ('.' Identifier)*
    ;

expression
    :   LeftBracket expression RightBracket // grouping
    |   expression Dot namespaceIdentifier // object access
    |   expression LeftSqBracket expression RightSqBracket // array/map access
    |   Identifier LeftBracket (expression (',' expression)*)? RightBracket // function call
    |   expression (Mult|Div|Mod) expression
    |   expression (Plus|Minus) expression
    |   expression (Integer|Float)
    |   expression (Lt|LtE|Gt|GtE) expression
    |   expression (Eq|NotEq) expression
    |   expression (And|Or) expression
    |   Negation expression
    |   Sign expression
    |   namespaceIdentifier LeftSqBracket expression RightSqBracket Assign expression // array element assignment
    |   LeftSqBracket (expression (Comma expression)*)? RightSqBracket // array literal
    |   Object? LeftCurlyBrace (expression Colon expression) (',' (expression Colon expression)*)? RightCurlyBrace // map literal
    |   LeftBracket expression Comma expression RightBracket // pair literal
    |   If expression Then expression Else expression
    |   namespaceIdentifier Assign expression
    |   String | Integer | Float | Boolean | Identifier
    ;

type
    :   primitiveType Optional?
    |   mapType Optional?
    |   pairType Optional?
    |   objectType Optional?
    |   arrayType Plus? Optional?
    |   struct Optional?
    |   Identifier
    ;

primitiveType
    :   BooleanType
    |   IntegerType
    |   FloatType
    |   FileType
    |   StringType
    ;

arrayType
    : ArrayType '[' (primitiveType | objectType | arrayType | pairType | mapType) ']'
    ;

mapType
    : MapType '[' primitiveType ',' (primitiveType | arrayType | mapType | objectType | pairType) ']'
    ;

pairType
    : PairType '[' primitiveType ',' (primitiveType | arrayType | mapType | objectType | pairType) ']'
    ;

objectType
    : ObjectType
    ;