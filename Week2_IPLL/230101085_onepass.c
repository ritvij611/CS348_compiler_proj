#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_SYMS 256
#define MAX_FWD_REFS 128
#define MAX_MEMORY 65536
#define MAX_TEXT_BYTES 30
#define MAX_BLOCKS MAX_MEMORY

struct optab {
	char mnemonic[10];
	char opcode[3];
};

struct symtab {
	char symbol[20];
	int address;             // -1 means forward reference only
	int refList[MAX_FWD_REFS];
	int refCount;
};

int findOpcodeIndex(const struct optab *oper, int total, const char *mnemonic){
	for(int i = 0; i < total; i++){
		if(strcmp(oper[i].mnemonic, mnemonic) == 0){
			return i;
		}
	}
	return -1;
}

int findSymbolIndex(const struct symtab *symbols, int count, const char *label){
	for(int i = 0; i < count; i++){
		if(strcmp(symbols[i].symbol, label) == 0){
			return i;
		}
	}
	return -1;
}

void addForwardReference(struct symtab *sym, int location){
	if(sym->refCount >= MAX_FWD_REFS){
		fprintf(stderr, "Error: too many forward references for %s\n", sym->symbol);
		exit(EXIT_FAILURE);
	}
	sym->refList[sym->refCount++] = location;
}

void patchAddress(unsigned char *memory, int operandLocation, int address){
	unsigned short current = (memory[operandLocation] << 8) | memory[operandLocation + 1];
	unsigned short xBit = current & 0x8000;
	unsigned short value = (unsigned short)(xBit | (address & 0x7FFF));
	memory[operandLocation] = (unsigned char)((value >> 8) & 0xFF);
	memory[operandLocation + 1] = (unsigned char)(value & 0xFF);
}

void backpatch(struct symtab *sym, unsigned char *memory){
	for(int i = 0; i < sym->refCount; i++){
		patchAddress(memory, sym->refList[i], sym->address);
	}
	sym->refCount = 0;
}

int parseDecimal(const char *text){
	if(text == NULL || text[0] == '\0'){
		fprintf(stderr, "Error: expected decimal constant but got empty operand\n");
		exit(EXIT_FAILURE);
	}
	char *endptr = NULL;
	long value = strtol(text, &endptr, 10);
	if(endptr == NULL || *endptr != '\0'){
		fprintf(stderr, "Error: operand %s must be a decimal constant\n", text);
		exit(EXIT_FAILURE);
	}
	return (int)value;
}

int parseHex(const char *text){
	return (int)strtol(text, NULL, 16);
}

void emitWord(unsigned char *memory, unsigned char *defined, int address, int value){
	if(address + 2 >= MAX_MEMORY){
		fprintf(stderr, "Error: address out of bounds\n");
		exit(EXIT_FAILURE);
	}
	memory[address] = (unsigned char)((value >> 16) & 0xFF);
	memory[address + 1] = (unsigned char)((value >> 8) & 0xFF);
	memory[address + 2] = (unsigned char)(value & 0xFF);
	defined[address] = defined[address + 1] = defined[address + 2] = 1;
}

void emitByteSequence(unsigned char *memory, unsigned char *defined, int address, const unsigned char *bytes, int length){
	if(address + length - 1 >= MAX_MEMORY){
		fprintf(stderr, "Error: address out of bounds\n");
		exit(EXIT_FAILURE);
	}
	for(int i = 0; i < length; i++){
		memory[address + i] = bytes[i];
		defined[address + i] = 1;
	}
}

void emitCharConstant(const char *operand, unsigned char *memory, unsigned char *defined, int address){
	size_t len = strlen(operand);
	if(len < 3 || operand[1] != '\'' || operand[len - 1] != '\''){
		fprintf(stderr, "Error: malformed BYTE constant %s\n", operand);
		exit(EXIT_FAILURE);
	}
	size_t size = len - 3;
	if(address + (int)size - 1 >= MAX_MEMORY){
		fprintf(stderr, "Error: address out of bounds\n");
		exit(EXIT_FAILURE);
	}
	for(size_t i = 0; i < size; i++){
		memory[address + (int)i] = (unsigned char)operand[i + 2];
		defined[address + (int)i] = 1;
	}
}

void emitHexConstant(const char *operand, unsigned char *memory, unsigned char *defined, int address){
	size_t len = strlen(operand);
	if(len < 3 || operand[1] != '\'' || operand[len - 1] != '\''){
		fprintf(stderr, "Error: malformed BYTE constant %s\n", operand);
		exit(EXIT_FAILURE);
	}
	size_t hexDigits = len - 3;
	if(hexDigits % 2 != 0){
		fprintf(stderr, "Error: odd number of hex digits in %s\n", operand);
		exit(EXIT_FAILURE);
	}
	size_t byteCount = hexDigits / 2;
	if(address + (int)byteCount - 1 >= MAX_MEMORY){
		fprintf(stderr, "Error: address out of bounds\n");
		exit(EXIT_FAILURE);
	}
	for(size_t i = 0; i < byteCount; i++){
		char buffer[3] = { operand[2 + 2 * i], operand[3 + 2 * i], '\0' };
		unsigned char value = (unsigned char)strtol(buffer, NULL, 16);
		memory[address + (int)i] = value;
		defined[address + (int)i] = 1;
	}
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

int main(void){
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

	unsigned char memory[MAX_MEMORY];
	unsigned char defined[MAX_MEMORY];
	unsigned short blockSize[MAX_MEMORY];
	int blockAddresses[MAX_BLOCKS];
	int blockCount = 0;
	memset(memory, 0, sizeof(memory));
	memset(defined, 0, sizeof(defined));
	memset(blockSize, 0, sizeof(blockSize));

	struct symtab symbols[MAX_SYMS];
	int symCount = 0;

	int locctr = 0;
	int startAddress = 0;
	int programLength = 0;
	char programName[7] = "NONAME";
	char execLabel[20] = "";
	int encounteredEnd = 0;

	char lineBuffer[256];

	while(fgets(lineBuffer, sizeof(lineBuffer), fp) != NULL){
		stripNewline(lineBuffer);
		if(lineBuffer[0] == '\0' || isCommentLine(lineBuffer)){
			continue;
		}

		char tok1[40] = {0};
		char tok2[40] = {0};
		char tok3[60] = {0};
		char label[20] = {0};
		char opcode[10] = {0};
		char operand[40] = {0};

		int tokenCount = sscanf(lineBuffer, "%39s %39s %59s", tok1, tok2, tok3);
		if(tokenCount <= 0){
			continue;
		}

		int hasLabel = !isspace((unsigned char)lineBuffer[0]);
		if(hasLabel){
			strncpy(label, tok1, sizeof(label) - 1);
			if(tokenCount >= 2){
				strncpy(opcode, tok2, sizeof(opcode) - 1);
			}
			if(tokenCount >= 3){
				strncpy(operand, tok3, sizeof(operand) - 1);
			}
		}
		else{
			strncpy(opcode, tok1, sizeof(opcode) - 1);
			if(tokenCount >= 2){
				strncpy(operand, tok2, sizeof(operand) - 1);
			}
		}

		if(strcmp(opcode, "START") == 0){
			startAddress = operand[0] ? parseHex(operand) : 0;
			locctr = startAddress;
			if(label[0] != '\0'){
				strncpy(programName, label, sizeof(programName) - 1);
				programName[sizeof(programName) - 1] = '\0';
			}
			continue;
		}

		if(label[0] != '\0'){
			int symIndex = findSymbolIndex(symbols, symCount, label);
			if(symIndex >= 0){
				if(symbols[symIndex].address != -1){
					fprintf(stderr, "Error: duplicate symbol %s\n", label);
					exit(EXIT_FAILURE);
				}
				symbols[symIndex].address = locctr;
				backpatch(&symbols[symIndex], memory);
			}
			else{
				if(symCount >= MAX_SYMS){
					fprintf(stderr, "Error: symbol table overflow\n");
					exit(EXIT_FAILURE);
				}
				strncpy(symbols[symCount].symbol, label, sizeof(symbols[symCount].symbol) - 1);
				symbols[symCount].symbol[sizeof(symbols[symCount].symbol) - 1] = '\0';
				symbols[symCount].address = locctr;
				symbols[symCount].refCount = 0;
				symCount++;
			}
		}

		if(strcmp(opcode, "END") == 0){
			encounteredEnd = 1;
			if(operand[0] != '\0'){
				strncpy(execLabel, operand, sizeof(execLabel) - 1);
				execLabel[sizeof(execLabel) - 1] = '\0';
			}
			break;
		}

		int opcodeIndex = findOpcodeIndex(oper, 23, opcode);
		if(opcodeIndex >= 0){
			if(locctr + 2 >= MAX_MEMORY){
				fprintf(stderr, "Error: memory limit exceeded\n");
				exit(EXIT_FAILURE);
			}

			int instStart = locctr;
			int opcodeValue = (int)strtol(oper[opcodeIndex].opcode, NULL, 16);
			memory[locctr] = (unsigned char)opcodeValue;
			defined[locctr] = 1;

			if(strcmp(opcode, "RSUB") == 0){
				memory[locctr + 1] = 0;
				memory[locctr + 2] = 0;
				defined[locctr + 1] = defined[locctr + 2] = 1;
				if(blockCount >= MAX_BLOCKS){
					fprintf(stderr, "Error: too many object blocks\n");
					exit(EXIT_FAILURE);
				}
				blockAddresses[blockCount++] = instStart;
				blockSize[instStart] = 3;
				locctr += 3;
				continue;
			}

			int operandLocation = locctr + 1;
			unsigned short operandValue = 0;
			int xFlag = 0;
			int operandSymIndex = -1;
			char operandSymbol[40] = {0};

			if(operand[0] != '\0'){
				strncpy(operandSymbol, operand, sizeof(operandSymbol) - 1);
				operandSymbol[sizeof(operandSymbol) - 1] = '\0';
				char *comma = strchr(operandSymbol, ',');
				if(comma != NULL){
					if(strcmp(comma + 1, "X") == 0){
						*comma = '\0';
						xFlag = 1;
					}
				}

				operandSymIndex = findSymbolIndex(symbols, symCount, operandSymbol);
				if(operandSymIndex >= 0){
					if(symbols[operandSymIndex].address != -1){
						operandValue = (unsigned short)(symbols[operandSymIndex].address & 0x7FFF);
					}
					else{
						addForwardReference(&symbols[operandSymIndex], operandLocation);
					}
				}
				else{
					if(symCount >= MAX_SYMS){
						fprintf(stderr, "Error: symbol table overflow\n");
						exit(EXIT_FAILURE);
					}
					strncpy(symbols[symCount].symbol, operandSymbol, sizeof(symbols[symCount].symbol) - 1);
					symbols[symCount].symbol[sizeof(symbols[symCount].symbol) - 1] = '\0';
					symbols[symCount].address = -1;
					symbols[symCount].refCount = 0;
					addForwardReference(&symbols[symCount], operandLocation);
					operandSymIndex = symCount;
					symCount++;
				}
			}

			if(xFlag){
				operandValue |= 0x8000;
			}

			memory[operandLocation] = (unsigned char)((operandValue >> 8) & 0xFF);
			memory[operandLocation + 1] = (unsigned char)(operandValue & 0xFF);
			defined[operandLocation] = defined[operandLocation + 1] = 1;

			if(operandSymIndex >= 0 && symbols[operandSymIndex].address != -1){
				patchAddress(memory, operandLocation, symbols[operandSymIndex].address);
			}

			if(blockCount >= MAX_BLOCKS){
				fprintf(stderr, "Error: too many object blocks\n");
				exit(EXIT_FAILURE);
			}
			blockAddresses[blockCount++] = instStart;
			blockSize[instStart] = 3;
			locctr += 3;
			continue;
		}

		if(strcmp(opcode, "WORD") == 0){
			int wordStart = locctr;
			int value = parseDecimal(operand);
			emitWord(memory, defined, locctr, value);
			if(blockCount >= MAX_BLOCKS){
				fprintf(stderr, "Error: too many object blocks\n");
				exit(EXIT_FAILURE);
			}
			blockAddresses[blockCount++] = wordStart;
			blockSize[wordStart] = 3;
			locctr += 3;
			continue;
		}

		if(strcmp(opcode, "BYTE") == 0){
			int byteStart = locctr;
			if(operand[0] == 'C'){
				size_t len = strlen(operand);
				int byteLen = (int)(len - 3);
				emitCharConstant(operand, memory, defined, locctr);
				if(blockCount >= MAX_BLOCKS){
					fprintf(stderr, "Error: too many object blocks\n");
					exit(EXIT_FAILURE);
				}
				blockAddresses[blockCount++] = byteStart;
				blockSize[byteStart] = (unsigned short)byteLen;
				locctr += byteLen;
			}
			else if(operand[0] == 'X'){
				int byteCount = (int)((strlen(operand) - 3) / 2);
				emitHexConstant(operand, memory, defined, locctr);
				if(blockCount >= MAX_BLOCKS){
					fprintf(stderr, "Error: too many object blocks\n");
					exit(EXIT_FAILURE);
				}
				blockAddresses[blockCount++] = byteStart;
				blockSize[byteStart] = (unsigned short)byteCount;
				locctr += byteCount;
			}
			else{
				fprintf(stderr, "Error: unsupported BYTE operand %s\n", operand);
				exit(EXIT_FAILURE);
			}
			continue;
		}

		if(strcmp(opcode, "RESW") == 0){
			locctr += 3 * parseDecimal(operand);
			continue;
		}

		if(strcmp(opcode, "RESB") == 0){
			locctr += parseDecimal(operand);
			continue;
		}

		fprintf(stderr, "Error: unknown opcode %s\n", opcode);
		exit(EXIT_FAILURE);
	}

	fclose(fp);

	if(!encounteredEnd){
		fprintf(stderr, "Error: END directive missing\n");
		return 1;
	}

	for(int i = 0; i < symCount; i++){
		if(symbols[i].address == -1){
			fprintf(stderr, "Error: undefined symbol %s\n", symbols[i].symbol);
			return 1;
		}
	}

	programLength = locctr - startAddress;

	int execAddress = startAddress;
	if(execLabel[0] != '\0'){
		int symIndex = findSymbolIndex(symbols, symCount, execLabel);
		if(symIndex < 0){
			fprintf(stderr, "Error: undefined execution start symbol %s\n", execLabel);
			return 1;
		}
		execAddress = symbols[symIndex].address;
	}

	FILE *object = fopen("output.txt", "w");
	if(object == NULL){
		perror("output.txt");
		return 1;
	}

	fprintf(object, "H%-6s%06X%06X\n", programName, startAddress & 0xFFFFFF, programLength & 0xFFFFFF);

	int blockIndex = 0;
	while(blockIndex < blockCount){
		int recordStart = -1;
		char textRecord[2 * MAX_TEXT_BYTES + 1];
		int textLen = 0;
		int recordOffset = 0;
		int lastBlockAddr = -1;
		unsigned short lastBlockLen = 0;
		textRecord[0] = '\0';

		while(blockIndex < blockCount){
			int blockAddr = blockAddresses[blockIndex];
			unsigned short chunk = blockSize[blockAddr];
			if(chunk == 0){
				blockIndex++;
				continue;
			}

			if(recordStart < 0){
				recordStart = blockAddr;
			}
			else if(blockAddr != lastBlockAddr + lastBlockLen){
				break;
			}

			if(textLen + chunk > MAX_TEXT_BYTES){
				break;
			}

			if((recordOffset + 2 * chunk) >= (int)sizeof(textRecord)){
				fprintf(stderr, "Error: text record buffer overflow\n");
				fclose(object);
				return 1;
			}

			for(int i = 0; i < chunk; i++){
				recordOffset += snprintf(textRecord + recordOffset, sizeof(textRecord) - recordOffset, "%02X", memory[blockAddr + i]);
			}

			textLen += chunk;
			lastBlockAddr = blockAddr;
			lastBlockLen = chunk;
			blockIndex++;
		}

		if(textLen == 0){
			fprintf(stderr, "Error: unable to fit object block into text record\n");
			fclose(object);
			return 1;
		}

		fprintf(object, "T%06X%02X%s\n", recordStart & 0xFFFFFF, textLen & 0xFF, textRecord);
	}

	fprintf(object, "E%06X\n", execAddress & 0xFFFFFF);

	fclose(object);
	return 0;
}
