%{
	// Considered # as Epsilon
	// Change input file name on line no. 521 or replace the grammar in input.txt file
	
	// Sample Grammar Format
	// S -> A
	// A -> ABd|Aa|a
	// B -> Be|b

	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <ctype.h>

	int numProductions = 0;
	char **productions;
	char **firsts;
	char **follows;
	char *nonTerminals;
	int *nonTerminalsToCount;
	int numNonTerminals = 0;
	char *numberToNonTerminal;
	char start = '\0';
	int currentProduction = 0;
	int productionStart = 3;
	int var;
	int idx;
	int **nonTerminalsToIndices;
%}

%%

[A-Z][ \n\t\r]?"->"[ \n\t\r]?[a-zA-Z+*-|]* {
	if(start == '\0') {
		start = yytext[0];
	}
	
	productionStart = yytext[3] != '>' ? 3 : 5;

	numProductions++;
	nonTerminalsToIndices[yytext[0] - 'A'][nonTerminalsToCount[yytext[0] - 'A']] = currentProduction;
	nonTerminalsToCount[yytext[0] - 'A'] = 1;
	productions[currentProduction][0] = yytext[0];
	numberToNonTerminal[currentProduction] = yytext[0];
	nonTerminals[numNonTerminals++] = yytext[0];

	idx = 1;
	for(var=productionStart; var<yyleng; var++) {
		if(yytext[var] == '|') {
			numProductions++;
			
			productions[currentProduction][idx] = '\0';
			idx = 1;
			
			currentProduction++;

			nonTerminalsToIndices[yytext[0] - 'A'][nonTerminalsToCount[yytext[0] - 'A']] = currentProduction;
			nonTerminalsToCount[yytext[0] - 'A']++;

			numberToNonTerminal[currentProduction] = yytext[0];

			productions[currentProduction][0] = yytext[0];
			continue;
		}
		productions[currentProduction][idx] = yytext[var];
		idx++;
	}
	productions[currentProduction][idx] = '\0';
	currentProduction++;
}

"%".* {
	printf("Comment : %s\n", yytext);
}

. ;

%%

char getNewNonTerminal() {
	int m;
	for(m=0; m<26; m++) {
		if(nonTerminalsToCount[m] == 0) {
			break;	
		}
	}
	return m + 'A';
}

void printProduction(char *production ) {
	printf("%c -> ", production[0]);
	for(int i=1; i<strlen(production); i++) {
		printf("%c", production[i]);
	}
	printf("  ");
}

void eliminateLeftRecursion() {
	char currentNonTerminal;
	char newNonTerminal;
	int tempNumNonTerminals = numNonTerminals;
	int k,l, reducedProductions = 0, canBeEliminated = 0, tempIndex, newNonTerminalAdded = 0;
	for(int i=0; i<numNonTerminals; i++) {
		canBeEliminated = 0;
		currentNonTerminal = nonTerminals[i];
		newNonTerminal = getNewNonTerminal();
		newNonTerminalAdded = 0;
		for(int j=0; j<nonTerminalsToCount[currentNonTerminal - 'A']; j++) {
			if(productions[nonTerminalsToIndices[currentNonTerminal - 'A'][j]][0] == productions[nonTerminalsToIndices[currentNonTerminal - 'A'][j]][1]) {
				canBeEliminated += 1;
				nonTerminalsToIndices[newNonTerminal - 'A'][nonTerminalsToCount[newNonTerminal - 'A']] = nonTerminalsToIndices[currentNonTerminal - 'A'][j];
				nonTerminalsToCount[newNonTerminal - 'A'] += 1;
				productions[nonTerminalsToIndices[currentNonTerminal - 'A'][j]][0] = newNonTerminal;
				numberToNonTerminal[nonTerminalsToIndices[currentNonTerminal - 'A'][j]] = newNonTerminal;
				
				if(newNonTerminalAdded == 0) nonTerminals[tempNumNonTerminals++] = newNonTerminal;
				newNonTerminalAdded = 1;
				
				k=2;
				for(k=2; k<strlen(productions[nonTerminalsToIndices[currentNonTerminal - 'A'][j]]); k++) {
					productions[nonTerminalsToIndices[currentNonTerminal - 'A'][j]][k-1] = productions[nonTerminalsToIndices[currentNonTerminal - 'A'][j]][k];
				}
				productions[nonTerminalsToIndices[currentNonTerminal - 'A'][j]][k-1] = newNonTerminal;
				productions[nonTerminalsToIndices[currentNonTerminal - 'A'][j]][k] = '\0';

				reducedProductions++;
			}
			else if (canBeEliminated != 0 && !isupper(productions[nonTerminalsToIndices[currentNonTerminal - 'A'][j]][1])) {
				l = strlen(productions[nonTerminalsToIndices[currentNonTerminal - 'A'][j]]);
				productions[nonTerminalsToIndices[currentNonTerminal - 'A'][j]][l] = newNonTerminal;
				productions[nonTerminalsToIndices[currentNonTerminal - 'A'][j]][l+1] = '\0';
			}
		}
		if(canBeEliminated != 0){
			productions[numProductions][0] = newNonTerminal;
			productions[numProductions][1] = '#';
			productions[numProductions][2] = '\0';

			nonTerminalsToIndices[newNonTerminal - 'A'][nonTerminalsToCount[newNonTerminal - 'A']] = numProductions;

			numProductions++;
			nonTerminalsToCount[newNonTerminal - 'A']++;

			nonTerminalsToCount[currentNonTerminal - 'A'] -= reducedProductions;

			tempIndex = 0;
			for(int p=canBeEliminated; p<9; p++) {
				nonTerminalsToIndices[currentNonTerminal - 'A'][tempIndex++] = nonTerminalsToIndices[currentNonTerminal - 'A'][p];
			}
		}
	}
	numNonTerminals = tempNumNonTerminals;
}

void doLeftFactoring() {
	int idx = 0;
	char newNonTerminal;
	int m;
	for(int i=0; i<26; i++) {
		if(nonTerminalsToIndices[i][0] != -1 && nonTerminalsToIndices[i][1] != -1) {
			newNonTerminal = getNewNonTerminal();
			for(int j=0; j<10; j++) {
				if(nonTerminalsToIndices[i][j] == -1) break;
				for(int k=j+1; k<10; k++) {
					if(nonTerminalsToIndices[i][k] == -1) break;
					idx = 1;
					while(productions[nonTerminalsToIndices[i][j]][idx] == productions[nonTerminalsToIndices[i][k]][idx])	{
						idx++;
					}

					if(idx>1) {
						productions[numProductions][0] = newNonTerminal;
						if(strlen(productions[nonTerminalsToIndices[i][k]]) == idx) {
							productions[numProductions][1] = '#';
						} else{
							for(m=idx; m<strlen(productions[nonTerminalsToIndices[i][k]]); m++) {
								productions[numProductions][m-idx+1] = productions[nonTerminalsToIndices[i][k]][m];
							}
						}
						
						productions[numProductions][m-idx+1] = '\0';
						
						nonTerminalsToIndices[newNonTerminal - 'A'][nonTerminalsToCount[newNonTerminal - 'A']] = numProductions;
						numProductions++;

						nonTerminalsToCount[newNonTerminal - 'A'] += 1;

						numberToNonTerminal[nonTerminalsToIndices[i][k]] = newNonTerminal;
						nonTerminals[numNonTerminals++] = newNonTerminal;

						productions[nonTerminalsToIndices[i][k]][idx] = newNonTerminal;
						productions[nonTerminalsToIndices[i][k]][idx+1] = '\0';
					}
				}
				if(idx > 1) {
					productions[nonTerminalsToIndices[i][j]][idx] = newNonTerminal;
					productions[nonTerminalsToIndices[i][j]][idx+1] = '\0';
				}
			}
		}
	}
}

void findFirsts() {
	char** prevFirsts = calloc(26, sizeof(char*));
	int l, k, flag, present;
	for(int i=0; i<26; i++) {
		prevFirsts[i] = calloc(20, sizeof(char));
		prevFirsts[i][0] = '\0';
	}

	int r=0;
	
	do {
		for(int i=0; i<26; i++) {
			for(int j=0; j<20; j++) {
				prevFirsts[i][j] == firsts[i][j];
			}
		}

		for(int i=0; i<numNonTerminals; i++) {
			for(int j=0; j<10; j++) {
				if(nonTerminalsToIndices[nonTerminals[i] - 'A'][j] == -1) break;
				if(isupper(productions[nonTerminalsToIndices[nonTerminals[i] - 'A'][j]][1])){
					if(strlen(firsts[productions[nonTerminalsToIndices[nonTerminals[i] - 'A'][j]][1] - 'A']) > 0) {
						l = strlen(firsts[nonTerminals[i] - 'A']);
						if(firsts[nonTerminals[i] - 'A'][l-1] != firsts[productions[nonTerminalsToIndices[nonTerminals[i] - 'A'][j]][1] - 'A'][strlen(firsts[productions[nonTerminalsToIndices[nonTerminals[i] - 'A'][j]][1] - 'A'])-1]) {
							for(k = 0; k<strlen(firsts[productions[nonTerminalsToIndices[nonTerminals[i] - 'A'][j]][1] - 'A']); k++) {
								present = 0;
								for(int q=0; q<l; q++) {
									if(firsts[nonTerminals[i] - 'A'][q] == firsts[productions[nonTerminalsToIndices[nonTerminals[i] - 'A'][j]][1] - 'A'][k]) {
										present = 1;
										break;
									}		
								}
								if (present != 1) {
									firsts[nonTerminals[i] - 'A'][l+k] = firsts[productions[nonTerminalsToIndices[nonTerminals[i] - 'A'][j]][1] - 'A'][k];
								}
							}
							firsts[nonTerminals[i] - 'A'][l+k] = '\0';
						}
					}
				}
				else {
					l = strlen(firsts[nonTerminals[i] - 'A']);
					if(productions[nonTerminalsToIndices[nonTerminals[i] - 'A'][j]][1] == 'i' && firsts[nonTerminals[i] - 'A'][l-1] != productions[nonTerminalsToIndices[nonTerminals[i] - 'A'][j]][2]) {
						firsts[nonTerminals[i] - 'A'][l] = productions[nonTerminalsToIndices[nonTerminals[i] - 'A'][j]][1];
						firsts[nonTerminals[i] - 'A'][l + 1] = productions[nonTerminalsToIndices[nonTerminals[i] - 'A'][j]][2];
						firsts[nonTerminals[i] - 'A'][l + 2] = '\0';
					}
					else if(firsts[nonTerminals[i] - 'A'][l-2] != 'i') {
						present = 0;
						for(int q=0; q<l; q++) {
							if(firsts[nonTerminals[i] - 'A'][q] == productions[nonTerminalsToIndices[nonTerminals[i] - 'A'][j]][1]) {
								present = 1;
								break;
							}
						}
						if(present != 1) {
							firsts[nonTerminals[i] - 'A'][l] = productions[nonTerminalsToIndices[nonTerminals[i] - 'A'][j]][1];
							firsts[nonTerminals[i] - 'A'][l + 1] = '\0';
						}
					}
				}
			}
		}

		flag = 0;
		for(int i=0; i<26; i++) {
			for(int j=0; j<20; j++) {
				if(prevFirsts[i][j] == firsts[i][j]) continue;
				flag = 1;
			}
		}

		r++;
	} while(r < 10 || flag != 1);
}

void findFollows() {
	char** prevFollows = calloc(26, sizeof(char*));
	int l, p, flag, present;
	for(int i=0; i<26; i++) {
		prevFollows[i] = calloc(20, sizeof(char));
		prevFollows[i][0] = '\0';
	}
	int r=0;

	do {
		for(int i=0; i<26; i++) {
			for(int j=0; j<20; j++) {
				prevFollows[i][j] == follows[i][j];
			}
		}

		for(int i=0; i<numNonTerminals; i++) {
			l = strlen(follows[nonTerminals[i] - 'A']);

			if(nonTerminals[i] == start) {
				follows[start - 'A'][l] = '$';
				follows[start - 'A'][l+1] = '\0';
			}
			
			for(int j=0; j<numProductions; j++) {
				for(int k=1; k<strlen(productions[j]); k++) {
					l = strlen(follows[nonTerminals[i] - 'A']);
					if(nonTerminals[i] == productions[j][k]) {
						if(k == strlen(productions[j]) - 1) {
							for(p=0; p<strlen(follows[productions[j][0] - 'A']); p++) {
								present = 0;
								for(int q=0; q<strlen(follows[nonTerminals[i] - 'A']); q++) {
									if(follows[nonTerminals[i] - 'A'][q] == follows[productions[j][0] - 'A'][p]) {
										present = 1;
										break;
									}
								}
								if(present != 1) {
									follows[nonTerminals[i] - 'A'][l+p] = follows[productions[j][0] - 'A'][p];
								}
							}
							follows[nonTerminals[i] - 'A'][l+p] = '\0';
						}
						else if (isupper(productions[j][k+1])){
							for(p=0; p<strlen(firsts[productions[j][k+1] - 'A']); p++) {
								present = 0;
								for(int q=0; q<strlen(follows[nonTerminals[i] - 'A']); q++) {
									if(follows[nonTerminals[i] - 'A'][q] == firsts[productions[j][k+1] - 'A'][p]) {
										present = 1;
										break;
									}
								}
								if(present != 1 && firsts[productions[j][k+1] - 'A'][p] != '#') {
									follows[nonTerminals[i] - 'A'][l+p] = firsts[productions[j][k+1] - 'A'][p];
								}
							}
							follows[nonTerminals[i] - 'A'][l+p] = '\0';
						}
						else if (productions[j][k+1] != '#'){
							present = 0;
							for(int q=0; q<strlen(follows[nonTerminals[i] - 'A']); q++) {
								if(follows[nonTerminals[i] - 'A'][q] == productions[j][k+1]) {
									present = 1;
									break;
								}
							}
							if(present != 1) {
								follows[nonTerminals[i] - 'A'][l] = productions[j][k+1];
								follows[nonTerminals[i] - 'A'][l+1] = '\0';
							}
						}
					}
				}
			}
		}
		

		flag = 0;
		for(int i=0; i<26; i++) {
			for(int j=0; j<20; j++) {
				if(prevFollows[i][j] == follows[i][j]) continue;
				flag = 1;
				
			}
		}

		r++;
	} while(r < 10 && flag != 1);
}

void prettyPrintParseTable(int*** parseTable, int numTerminals, char* terminals) {
	printf("   |  \t\t");
	for(int i=0; i<numTerminals; i++) {
		terminals[i] == '#' ? printf("$\t\t|") : printf("%c\t\t|\t\t", terminals[i]);
	}
	printf("\n");

	int s = numTerminals > 2 ? 130 : 66;
	for(int i=0; i<s; i++) printf("-");
	printf("\n");

	for(int i=0; i<numNonTerminals; i++) {
		printf("%c  |  \t", nonTerminals[i]);
		for(int j=0; j<numTerminals; j++) {
			for(int k=0; k<10; k++) {
				if(parseTable[i][j][k] != -1) {
					if(k>0) printf("|| ");
					printProduction(productions[parseTable[i][j][k]]);
					
				}
				if(parseTable[i][j][0] == -1) {
					printf(" -- \t\t");
					break;
				}
			}
			if(parseTable[i][j][0] != -1 && parseTable[i][j][1] == -1) {
				printf("\t");
			}
			printf("\t | \t");
		}
		printf("\n");
	}
	printf("\n");
}

void constructParseTable() {
	char* terminals = calloc(15, sizeof(char));
	int numTerminals = 0, isPresent = 0;
	for(int i=0; i<numProductions; i++) {
		for(int j=0; j<strlen(productions[i]); j++) {
			if(!isupper(productions[i][j]) && productions[i][j] != 'd') {
				isPresent = 0;
				for(int k=0; k<numTerminals; k++) {
					if(terminals[k] == productions[i][j]) {
						isPresent = 1;
						break;
					}
				}
				if(isPresent != 1){
					terminals[numTerminals++] = productions[i][j];
					terminals[numTerminals] = '\0';
				}
			}
		}
	}
	
	int*** parseTable = calloc(numNonTerminals, sizeof(int**));
	for(int i=0; i<numNonTerminals; i++) {
		parseTable[i] = calloc(numTerminals, sizeof(int*));
		for(int j=0; j<numTerminals; j++) {
			parseTable[i][j] = calloc(10, sizeof(int));
			for(int k=0; k<10; k++) {
				parseTable[i][j][k] = -1;
			}
		}
	}
	
	char* fillTerminals = calloc(1, sizeof(char));
	int notLL1Grammar = 0;
	int length = 0;
	for(int n=0; n<numNonTerminals; n++) {
		for(int i=0; i<numProductions; i++) {
			if(productions[i][0] == nonTerminals[n]) {
				if(isupper(productions[i][1])) {
					free(fillTerminals);
					fillTerminals = calloc(strlen(firsts[productions[i][1] - 'A']), sizeof(char));
					strcpy(fillTerminals, firsts[productions[i][1] - 'A']);
				}
				else if (productions[i][1] == '#') {
					free(fillTerminals);
					fillTerminals = calloc(strlen(follows[productions[i][0] - 'A']), sizeof(char));
					strcpy(fillTerminals, follows[productions[i][0] - 'A']);
				}
				else{
					free(fillTerminals);
					fillTerminals = calloc(1, sizeof(char));
					fillTerminals[0] = productions[i][1];
				}

				for(int j=0; j<strlen(fillTerminals); j++) {
					for(int k=0; k<numTerminals; k++) {
						if(terminals[k] == fillTerminals[j] || (terminals[k] == '#' && fillTerminals[j] == '$')) {
							length = 0;
							for(int m=0; m<10; m++) {
								if(parseTable[n][k][m] == -1) break;
								length++;
							}
							
							if(length >= 1) notLL1Grammar = 1;

							parseTable[n][k][length] = i;
						}
					}
				}
			}
		}
	}
	

	printf("\nParse Table\n");
	prettyPrintParseTable(parseTable, numTerminals, terminals);

	notLL1Grammar == 1 ? printf("Given grammar is not LL(1) grammar.\nReason : Contains more than one production in same cell.\n\n") : printf("Given grammar is LL(1) grammar.\n\n");
}

int main(int argc, char **argv)
{
	FILE* file;
	char* line = NULL;
    size_t len = 0;
    ssize_t read;
	
	nonTerminalsToIndices = calloc(26, sizeof(int*));
	for(int i=0; i<26; i++) {
		nonTerminalsToIndices[i] = calloc(10, sizeof(int));
		for(int j=0; j<10; j++) {
			nonTerminalsToIndices[i][j] = -1;
		}
	}
	nonTerminalsToCount = calloc(26, sizeof(int));
	numberToNonTerminal = calloc(26, sizeof(char));
	nonTerminals = calloc(20, sizeof(int));

	productions = calloc(20, sizeof(char*));
	for(int i=0; i<20; i++) {
		productions[i] = calloc(20, sizeof(char));
	}

	
	firsts = calloc(26, sizeof(char*));
	for(int i=0; i<26; i++) {
		firsts[i] = calloc(20, sizeof(char));
		firsts[i][0] = '\0';
	}

	follows = calloc(26, sizeof(char*));
	for(int i=0; i<26; i++) {
		follows[i] = calloc(20, sizeof(char));
		follows[i][0] = '\0';
	}

	file = fopen("input.txt","r");
	if(!file){
		printf("could not open the file");
		exit(0);
	}

	yyin=file;
	yylex();

	nonTerminals[numNonTerminals] = '\0';
	printf("\n");
	printf("Starting non-terminal : %c\n", start);
	printf("No of Productions : %d", numProductions);
	printf("\n");

	printf("\nExtracted productions successfully\n");
	for(int i=0;i<numProductions;i++) {
		printProduction(productions[i]);
		printf("\n");
	}

	fclose(file); 
	if (line) free(line);

	eliminateLeftRecursion();

	printf("\nEliminated Left Recursion\n");
	for(int i=0;i<numProductions;i++) {
		printProduction(productions[i]);
		printf("\n");
	}
	

	doLeftFactoring();

	printf("\nDone Left Factoring\n");
	for(int i=0;i<numProductions;i++) {
		printProduction(productions[i]);
		printf("\n");
	}
	

	findFirsts();
	
	printf("\nCalculated Firsts of non terminals\n");
	for(int i=0; i<numNonTerminals; i++) {
		printf("First(%c) = {%s}", nonTerminals[i], firsts[nonTerminals[i] - 'A']);
		printf("\n");
	}
	

	findFollows();

	printf("\nCalculated Follows of non terminals\n");
	for(int i=0; i<numNonTerminals; i++) {
		printf("Follow(%c) = {%s}", nonTerminals[i], follows[nonTerminals[i] - 'A']);
		printf("\n");
	}
	

	constructParseTable();

	return(0);
}

int yywrap(){
	return(1);
}