#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>

struct optab {
    char opname[10];
    char opcode[3];   
};

struct symtab {
    char symbol[20];
    int address;
};

#define MAX_LINES 512
#define MAX_SYMS 256
#define MAX_TEXT_BYTES 30

struct sourceLine {
    int address;
    char label[20];
    char opcode[10];
    char operand[40];
    char comment[128];
    char objcode[32];
    int isComment;
};

int findOpcodeIndex(const struct optab *oper, int total, const char *opname){
    for(int i = 0; i < total; i++){
        if(strcmp(oper[i].opname, opname) == 0){
            return i;
        }
    }
    return -1;
}

int findSymbolAddress(const struct symtab *symbols, int count, const char *label){
    for(int i = 0; i < count; i++){
        if(strcmp(symbols[i].symbol, label) == 0){
            return symbols[i].address;
        }
    }
    return -1;
}

void stripNewline(char *text){
    size_t len = strlen(text);
    while(len > 0 && (text[len - 1] == '\n' || text[len - 1] == '\r')){
        text[len - 1] = '\0';
        len--;
    }
}

int isCommentLine(const char *line){
    const char *ptr = line;
    while(*ptr && isspace((unsigned char)*ptr)){
        ptr++;
    }
    return *ptr == '.';
}

int parseDecimal(const char *text){
    return (int)strtol(text, NULL, 10);
}

int parseHex(const char *text){
    return (int)strtol(text, NULL, 16);
}

void generateByteObject(const char *operand, char *output){
    output[0] = '\0';
    size_t len = strlen(operand);
    if(len < 3 || operand[1] != '\'' || operand[len - 1] != '\''){
        return;
    }
    if(operand[0] == 'C'){
        char temp[8];
        for(size_t i = 2; i < len - 1; i++){
            snprintf(temp, sizeof(temp), "%02X", (unsigned char)operand[i]);
            strncat(output, temp, sizeof(temp));
        }
    }
    else if(operand[0] == 'X'){
        size_t dataLen = len - 3;
        strncat(output, operand + 2, dataLen);
    }
}


int main(){
    struct optab oper[23];
    oper[0] = (struct optab){"LDA", "00"};
    oper[1] = (struct optab){"LDX", "04"};
    oper[2] = (struct optab){"LDL", "08"};
    oper[3] = (struct optab){"STA", "0C"};
    oper[4] = (struct optab){"STX", "10"};
    oper[5] = (struct optab){"STL", "14"};
    oper[6] = (struct optab){"LDCH", "50"};
    oper[7] = (struct optab){"STCH", "54"};
    oper[8] = (struct optab){"ADD", "18"};
    oper[9] = (struct optab){"SUB", "1C"};
    oper[10] = (struct optab){"MUL", "20"};
    oper[11] = (struct optab){"DIV", "24"};
    oper[12] = (struct optab){"COMP", "28"};
    oper[13] = (struct optab){"J", "3C"};
    oper[14] = (struct optab){"JLT", "38"};
    oper[15] = (struct optab){"JEQ", "30"};
    oper[16] = (struct optab){"JGT", "34"};
    oper[17] = (struct optab){"JSUB", "48"};
    oper[18] = (struct optab){"RSUB", "4C"};
    oper[19] = (struct optab){"TIX", "2C"};
    oper[20] = (struct optab){"TD", "E0"};
    oper[21] = (struct optab){"RD", "D8"};
    oper[22] = (struct optab){"WD", "DC"};
    FILE *fp = fopen("input.txt", "r");
    if(fp == NULL){
        perror("input.txt");
        return 1;
    }

    struct sourceLine lines[MAX_LINES];
    struct symtab symbols[MAX_SYMS];
    int lineCount = 0;
    int symCount = 0;
    int locctr = 0;
    int startAddress = 0;
    int programLength = 0;
    char programName[7] = "NONAME";
    char execLabel[20] = "";
    char buffer[256];

    while(fgets(buffer, sizeof(buffer), fp) != NULL){
        stripNewline(buffer);
        if(buffer[0] == '\0'){
            continue;
        }

        if(isCommentLine(buffer)){
            if(lineCount >= MAX_LINES){
                fprintf(stderr, "Error: too many source lines\n");
                exit(EXIT_FAILURE);
            }
            struct sourceLine *line = &lines[lineCount++];
            memset(line, 0, sizeof(*line));
            line->isComment = 1;
            line->address = locctr;
            strncpy(line->comment, buffer, sizeof(line->comment) - 1);
            continue;
        }

        if(lineCount >= MAX_LINES){
            fprintf(stderr, "Error: too many source lines\n");
            exit(EXIT_FAILURE);
        }

        struct sourceLine *line = &lines[lineCount];
        memset(line, 0, sizeof(*line));
        line->address = locctr;

        char tok1[40] = {0};
        char tok2[40] = {0};
        char tok3[60] = {0};
        int tokenCount = sscanf(buffer, "%39s %39s %59s", tok1, tok2, tok3);
        if(tokenCount <= 0){
            continue;
        }

        int hasLabel = !isspace((unsigned char)buffer[0]);
        if(hasLabel){
            strncpy(line->label, tok1, sizeof(line->label) - 1);
            if(tokenCount >= 2){
                strncpy(line->opcode, tok2, sizeof(line->opcode) - 1);
            }
            if(tokenCount >= 3){
                strncpy(line->operand, tok3, sizeof(line->operand) - 1);
            }
        }
        else{
            line->label[0] = '\0';
            strncpy(line->opcode, tok1, sizeof(line->opcode) - 1);
            if(tokenCount >= 2){
                strncpy(line->operand, tok2, sizeof(line->operand) - 1);
            }
        }

        if(strcmp(line->opcode, "START") == 0){
            startAddress = parseHex(line->operand);
            locctr = startAddress;
            line->address = locctr;
            if(line->label[0] != '\0'){
                strncpy(programName, line->label, sizeof(programName) - 1);
                programName[sizeof(programName) - 1] = '\0';
            }
            lineCount++;
            continue;
        }

        if(line->label[0] != '\0'){
            if(symCount >= MAX_SYMS){
                fprintf(stderr, "Error: symbol table overflow\n");
                exit(EXIT_FAILURE);
            }
            if(findSymbolAddress(symbols, symCount, line->label) != -1){
                fprintf(stderr, "Error: duplicate symbol %s\n", line->label);
                exit(EXIT_FAILURE);
            }
            strncpy(symbols[symCount].symbol, line->label, sizeof(symbols[symCount].symbol) - 1);
            symbols[symCount].address = locctr;
            symCount++;
        }

        if(strcmp(line->opcode, "END") == 0){
            if(line->operand[0] != '\0'){
                strncpy(execLabel, line->operand, sizeof(execLabel) - 1);
                execLabel[sizeof(execLabel) - 1] = '\0';
            }
            lineCount++;
            break;
        }

        int opcodeIndex = findOpcodeIndex(oper, 23, line->opcode);
        if(opcodeIndex >= 0){
            locctr += 3;
        }
        else if(strcmp(line->opcode, "WORD") == 0){
            locctr += 3;
        }
        else if(strcmp(line->opcode, "RESW") == 0){
            locctr += 3 * parseDecimal(line->operand);
        }
        else if(strcmp(line->opcode, "RESB") == 0){
            locctr += parseDecimal(line->operand);
        }
        else if(strcmp(line->opcode, "BYTE") == 0){
            size_t len = strlen(line->operand);
            if(len >= 3 && line->operand[1] == '\'' && line->operand[len - 1] == '\''){
                if(line->operand[0] == 'C'){
                    locctr += (int)(len - 3);
                }
                else if(line->operand[0] == 'X'){
                    locctr += (int)((len - 3 + 1) / 2);
                }
                else{
                    fprintf(stderr, "Error: invalid BYTE constant %s\n", line->operand);
                    exit(EXIT_FAILURE);
                }
            }
            else{
                fprintf(stderr, "Error: malformed BYTE operand %s\n", line->operand);
                exit(EXIT_FAILURE);
            }
        }
        else{
            fprintf(stderr, "Error: unknown opcode %s\n", line->opcode);
            exit(EXIT_FAILURE);
        }

        lineCount++;
    }

    fclose(fp);

    programLength = locctr - startAddress;

    FILE *intermediate = fopen("intermediate.txt", "w");
    if(intermediate == NULL){
        perror("intermediate.txt");
        return 1;
    }

    //fprintf(intermediate, "Addr\tLabel\tOpcode\tOperand\tObject\n");
    //fprintf(intermediate, "----\t-----\t------\t-------\t------\n");

    for(int i = 0; i < lineCount; i++){
        if(lines[i].isComment){
            fprintf(intermediate, "    \t%s\n", lines[i].comment);
            continue;
        }
        fprintf(intermediate, "%04X\t%-6s\t%-6s\t%-10s\n",
                lines[i].address & 0xFFFF,
                lines[i].label[0] ? lines[i].label : "",
                lines[i].opcode,
                lines[i].operand[0] ? lines[i].operand : "");
    }

    fclose(intermediate);

    for(int i = 0; i < lineCount; i++){
        lines[i].objcode[0] = '\0';
        if(lines[i].isComment){
            continue;
        }

        if(strcmp(lines[i].opcode, "START") == 0 || strcmp(lines[i].opcode, "END") == 0){
            continue;
        }

        if(strcmp(lines[i].opcode, "RSUB") == 0){
            snprintf(lines[i].objcode, sizeof(lines[i].objcode), "4C0000");
            continue;
        }

        if(strcmp(lines[i].opcode, "RESW") == 0 || strcmp(lines[i].opcode, "RESB") == 0){
            continue;
        }

        if(strcmp(lines[i].opcode, "WORD") == 0){
            int value = parseDecimal(lines[i].operand);
            snprintf(lines[i].objcode, sizeof(lines[i].objcode), "%06X", value & 0xFFFFFF);
            continue;
        }

        if(strcmp(lines[i].opcode, "BYTE") == 0){
            generateByteObject(lines[i].operand, lines[i].objcode);
            continue;
        }

        int opcodeIndex = findOpcodeIndex(oper, 23, lines[i].opcode);
        if(opcodeIndex < 0){
            fprintf(stderr, "Error: opcode %s missing in OPTAB\n", lines[i].opcode);
            exit(EXIT_FAILURE);
        }

        int operandAddress = 0;
        int xFlag = 0;
        if(strlen(lines[i].operand) > 0){
            char operandCopy[40];
            strncpy(operandCopy, lines[i].operand, sizeof(operandCopy) - 1);
            operandCopy[sizeof(operandCopy) - 1] = '\0';
            char *comma = strchr(operandCopy, ',');
            if(comma != NULL){
                if(strcmp(comma + 1, "X") == 0){
                    *comma = '\0';
                    xFlag = 1;
                }
            }
            if(strlen(operandCopy) > 0){
                operandAddress = findSymbolAddress(symbols, symCount, operandCopy);
                if(operandAddress < 0){
                    fprintf(stderr, "Error: undefined symbol %s\n", operandCopy);
                    exit(EXIT_FAILURE);
                }
            }
        }

        if(xFlag){
            operandAddress |= 0x8000;
        }

        int opcodeValue = (int)strtol(oper[opcodeIndex].opcode, NULL, 16);
        int objectValue = (opcodeValue << 16) | (operandAddress & 0xFFFF);
        snprintf(lines[i].objcode, sizeof(lines[i].objcode), "%06X", objectValue & 0xFFFFFF);
    }

    FILE *object = fopen("output.txt", "w");
    if(object == NULL){
        perror("output.txt");
        return 1;
    }

    fprintf(object, "H%-6s%06X%06X\n", programName, startAddress & 0xFFFFFF, programLength & 0xFFFFFF);

    int textStart = -1;
    int textLen = 0;
    char textRecord[2 * MAX_TEXT_BYTES + 1];
    textRecord[0] = '\0';

    for(int i = 0; i < lineCount; i++){
        if(lines[i].isComment){
            continue;
        }

        if(strcmp(lines[i].opcode, "START") == 0){
            continue;
        }

        if(strcmp(lines[i].opcode, "END") == 0){
            if(textLen > 0){
                fprintf(object, "T%06X%02X%s\n", textStart & 0xFFFFFF, textLen & 0xFF, textRecord);
                textLen = 0;
                textRecord[0] = '\0';
                textStart = -1;
            }
            break;
        }

        const char *obj = lines[i].objcode;
        if(obj[0] == '\0'){
            if(strcmp(lines[i].opcode, "RESW") == 0 || strcmp(lines[i].opcode, "RESB") == 0){
                if(textLen > 0){
                    fprintf(object, "T%06X%02X%s\n", textStart & 0xFFFFFF, textLen & 0xFF, textRecord);
                    textLen = 0;
                    textRecord[0] = '\0';
                    textStart = -1;
                }
            }
            continue;
        }

        int objBytes = (int)(strlen(obj) / 2);
        if(textLen == 0){
            textStart = lines[i].address;
        }
        if(textLen + objBytes > MAX_TEXT_BYTES){
            fprintf(object, "T%06X%02X%s\n", textStart & 0xFFFFFF, textLen & 0xFF, textRecord);
            textLen = 0;
            textRecord[0] = '\0';
            textStart = lines[i].address;
        }

        size_t currentLen = strlen(textRecord);
        size_t objLen = strlen(obj);
        if(currentLen + objLen >= sizeof(textRecord)){
            fprintf(stderr, "Error: text record overflow\n");
            fclose(object);
            return 1;
        }
        memcpy(textRecord + currentLen, obj, objLen + 1);
        textLen += objBytes;
    }

    if(textLen > 0){
        fprintf(object, "T%06X%02X%s\n", textStart & 0xFFFFFF, textLen & 0xFF, textRecord);
    }

    int execAddress = startAddress;
    if(execLabel[0] != '\0'){
        int resolved = findSymbolAddress(symbols, symCount, execLabel);
        if(resolved < 0){
            fprintf(stderr, "Error: undefined execution start symbol %s\n", execLabel);
            fclose(object);
            return 1;
        }
        execAddress = resolved;
    }

    fprintf(object, "E%06X\n", execAddress & 0xFFFFFF);

    fclose(object);
    return 0;
}