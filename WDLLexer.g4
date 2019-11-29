lexer grammar WDLLexer;

Dot: '.' ;

Comma: ',' ;

Colon: ':' ;

Quotes: '"';

SingleQuotes: '\'' ;

As: 'as' ;

Import: 'import' ;

Runtime: 'runtime' ;

Task: 'task' ;

Struct: 'struct' ;

Workflow: 'workflow' ;

Input: 'input' ;

Output: 'output' ;

ParameterMeta: 'parameter_meta' ;

Meta: 'meta' ;

Call: 'call' ;

Scatter: 'scatter' ;

CommandStartV1: Command Ws* '{' Ws* -> pushMode(InCommandV1) ;

CommandStartV2: Command Ws* '<<<' Ws* -> pushMode(InCommandV2) ;

Command: 'command' ;

LeftBracket : '(' ;

RightBracket: ')' ;

LeftSqBracket: '[' ;

RightSqBracket: ']' ;

LeftCurlyBrace: '{' ;

RightCurlyBrace: '}' ;

Negation: '!' ;

In: 'in' ;

While: 'while' ;

If: 'if' ;

Then: 'then' ;

Else: 'else' ;

Optional : '?' ;

Plus: '+' ;

Minus: '-' ;

Mult: '*' ;

Div: '/' ;

Mod: '%' ;

And: '&&' ;

Or: '||' ;

Gt: '>' ;

GtE: '>=' ;

Lt: '<' ;

LtE: '<=' ;

Eq: '==' ;

Assign: '=' ;

NotEq: '!=' ;

Sign: Plus | Minus ;

BooleanType: 'Boolean' ;

IntegerType: 'Int' ;

FloatType: 'Float' ;

FileType: 'File' ;

StringType: 'String' ;

ArrayType: 'Array' ;

MapType: 'Map' ;

PairType: 'Pair' ;

Object : 'object' ;

ObjectType : 'Object' ;

String
	:	Quotes StringCharacters? Quotes
	|   SingleQuotes StringCharacters? SingleQuotes
	;

Integer
	:	Sign? DecimalNumeral
	|	Sign? HexNumeral
	|	Sign? OctalNumeral
	;

Float
	:	Sign? DecimalFloatingPointLiteral
	|	Sign? HexadecimalFloatingPointLiteral
	;

Boolean
    : 'true'
    | 'false'
    ;

Identifier : [a-zA-Z][a-zA-Z0-9_]* ;

Comment : '#' .*? ('\n'|EOF) -> skip ;

Ws  :  [ \t\r\n\u000C]+ -> skip ;

Any : . ;

fragment
DecimalFloatingPointLiteral
	:	Digits '.' Digits? ExponentPart? FloatTypeSuffix?
	|	'.' Digits ExponentPart? FloatTypeSuffix?
	|	Digits ExponentPart FloatTypeSuffix?
	|	Digits FloatTypeSuffix
	;

fragment
ExponentPart
	:	ExponentIndicator SignedInteger
	;

fragment
ExponentIndicator
	:	[eE]
	;

fragment
SignedInteger
	:	Sign? Digits
	;

fragment
FloatTypeSuffix
	:	[fFdD]
	;

fragment
HexadecimalFloatingPointLiteral
	:	HexSignificand BinaryExponent FloatTypeSuffix?
	;

fragment
HexSignificand
	:	HexNumeral '.'?
	|	'0' [xX] HexDigits? '.' HexDigits
	;

fragment
BinaryExponent
	:	BinaryExponentIndicator SignedInteger
	;

fragment
BinaryExponentIndicator
	:	[pP]
	;

fragment
DecimalNumeral
	:	'0'
	|	NonZeroDigit (Digits? | Underscores Digits)
	;

fragment
Digits
	:	Digit (DigitsAndUnderscores? Digit)?
	;

fragment
Digit
	:	'0'
	|	NonZeroDigit
	;

fragment
NonZeroDigit
	:	[1-9]
	;

fragment
DigitsAndUnderscores
	:	DigitOrUnderscore+
	;

fragment
DigitOrUnderscore
	:	Digit
	|	'_'
	;

fragment
Underscores
	:	'_'+
	;

fragment
HexNumeral
	:	'0' [xX] HexDigits
	;

fragment
HexDigits
	:	HexDigit (HexDigitsAndUnderscores? HexDigit)?
	;

fragment
HexDigit
	:	[0-9a-fA-F]
	;

fragment
HexDigitsAndUnderscores
	:	HexDigitOrUnderscore+
	;

fragment
HexDigitOrUnderscore
	:	HexDigit
	|	'_'
	;

fragment
OctalNumeral
	:	'0' Underscores? OctalDigits
	;

fragment
OctalDigits
	:	OctalDigit (OctalDigitsAndUnderscores? OctalDigit)?
	;

fragment
OctalDigit
	:	[0-7]
	;

fragment
OctalDigitsAndUnderscores
	:	OctalDigitOrUnderscore+
	;

fragment
OctalDigitOrUnderscore
	:	OctalDigit
	|	'_'
	;


fragment
StringCharacters
	:	StringCharacter+
	;
fragment
StringCharacter
	:	~['"\\\r\n]
	|	EscapeSequence
	;
fragment
EscapeSequence
	:	'\\' [btnfr"'\\]
	|	OctalEscape
    |   UnicodeEscape
	;

fragment
OctalEscape
	:	'\\' OctalDigit
	|	'\\' OctalDigit OctalDigit
	|	'\\' ZeroToThree OctalDigit OctalDigit
	;

fragment
ZeroToThree
	:	[0-3]
	;

fragment
UnicodeEscape
    :   '\\' 'u'+  HexDigit HexDigit HexDigit HexDigit
    ;

mode InCommandV1;

CommandPartVarStart
    : '${' -> pushMode(InCommandVar)
    ;

CommandPartStringV1
    : ~('$'|'~'|'{'|'}')+
    | ('$'|'~') ~'{' ~('$'|'~'|'}')*
    | ('$'|'~')
    ;

CommandEndV1
    : Ws* '}' -> popMode
    ;

mode InCommandV2;

CommandPartVarStart2
    : CommandPartVarStart -> type(CommandPartVarStart), pushMode(InCommandVar)
    ;

CommandPartStringV2
    : ~('$'|'~'|'>')+
    | ('$'|'~') ~'{' ~('$'|'~'|'>')*
    | ('$'|'~')
    | '>' ~('$'|'~'|'>')*
    | '>' '>' ~('$'|'~'|'>')*
    ;

CommandEndV2
    : Ws* '>>>' -> popMode
    ;


mode InCommandVar;

CommandPartVarWs
    : Ws -> skip
    ;

CommandPartVarString
    : String -> type(String)
    ;

CommandPartVarInteger
    : Integer -> type(Integer)
    ;

CommandPartVarFloat
    : Float -> type(Float)
    ;

CommandPartVarBoolean
    : Boolean -> type(Boolean)
    ;

CommandPartVarLeftBracket
    : LeftBracket -> type(LeftBracket)
    ;

CommandPartVarRightBracket
    : RightBracket -> type(RightBracket)
    ;

CommandPartVarIdentifier
    : Identifier -> type(Identifier)
    ;

CommandPartVarLeftSqBracket
    : LeftSqBracket -> type(LeftSqBracket)
    ;

CommandPartVarRightSqBracket
    : RightSqBracket -> type(RightSqBracket)
    ;


CommandPartVarMult
    : Mult -> type(Mult)
    ;

CommandPartVarDiv
    : Div -> type(Div)
    ;

CommandPartVarMod
    : Mod -> type(Mod)
    ;

CommandPartVarPlus
    : Plus -> type(Plus)
    ;

CommandPartVarMinus
    : Minus -> type(Minus)
    ;

CommandPartVarLt
    : Lt -> type(Lt)
    ;

CommandPartVarLtE
    : LtE -> type(LtE)
    ;

CommandPartVarGt
    : Gt -> type(Gt)
    ;

CommandPartVarGtE
    : GtE -> type(GtE)
    ;

CommandPartVarEq
    : Eq -> type(Eq)
    ;

CommandPartVarNotEq
    : NotEq -> type(NotEq)
    ;

CommandPartVarAnd
    : And -> type(And)
    ;

CommandPartVarNotOr
    : Or -> type(Or)
    ;

CommandPartVarNegation
    : Negation -> type(Negation)
    ;

CommandPartVarSign
    : Sign -> type(Sign)
    ;

CommandPartVarObject
    : Object -> type(Object)
    ;

CommandPartVarColon
    : Colon -> type(Colon)
    ;

CommandPartVarComma
    : Comma -> type(Comma)
    ;

CommandPartVarIf
    : If -> type(If)
    ;

CommandPartVarThen
    : Then -> type(Then)
    ;

CommandPartVarElse
    : Else -> type(Else)
    ;

Bool
    : Boolean '=' -> type(Boolean)
    ;

Sep
    :  'sep' '='
    ;

Quote
    :  'quote' '='
    ;

Default
    : 'default' '='
    ;

RCurly: Ws* '}'  -> popMode ;