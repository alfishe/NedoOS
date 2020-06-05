enum {
        CMD_NOP,
        CMD_ADD,
        CMD_SUB, //CONST A CONST B SUB = A-B
        CMD_MUL,
        CMD_DIV, //CONST A CONST B DIV = A/B
        CMD_DIVSIGNED,
        CMD_IF0GOTO, //IF0GOTO ADDR
        CMD_GOTO, //GOTO ADDR
        CMD_DUP,
        CMD_DROP,
        CMD_SWAP, //CONST A CONST B SWAP SUB = B-A
        CMD_READVAR, //CONST A READVAR = VAR(A)
        CMD_WRITEVAR, //CONST A CONST B WRITEVAR: VAR(A) = B
        CMD_CONST, //CONST A
        CMD_RET,
        CMD_CALL, //CALL ADDR
        CMD_AND,
        CMD_OR,
        CMD_XOR,
        CMD_EQ,
        CMD_MOREEQ,
        CMD_MOREEQSIGNED,
        CMD_INV,
        CMD_RST, //RST <systemprocnum>
        CMD_SHR, //CONST A CONST B SHR = A>>B
        CMD_SHRSIGNED,
        CMD_SHL,
        CMD_MOD, //CONST A CONST B MOD = A % B
        CMD_DONE, //end
};

enum {
  Gotov1 = 100,
  Gotov2,
  Pusk,
};
