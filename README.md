# LL-1-Parser
## Given a CFG, creates the parse table and says whether it is a LL(1) grammar or not.
### Handles elimination of Left Recursion and also does Left Factoring

Considered # as Epsilon.
Whole program is written using only C lanugage and lex.

In Grammar_Parser.l, Change input file name on line no. 525 or replace the grammar in input.txt file, to run custom grammar.

Sample Grammar Format in input file
S -> A
A -> ABd|Aa|a
B -> Be|b

Check the Outputs folder to see the outputs of the given testcases.
Check the Executables folder to access the executables of the respective testcases and operating systems.

Disclaimer : Keep your terminal/command prompt wide open to see all outputs clearly

Assuming terminal/command prompt is opened in the current folder.
To run the executables on Linux :
```
	./Executables/Windows/testcase0
 ```

To run the executables on Windows :
```
  .\Executables\Windows\testcase0.exe
 ```

To compile & execute the program from scratch on Linux :
```
	lex Grammar_Parser.l
	gcc -o custom_testcase lex.yy.c -ll
	./custom_testcase
```

To compile & execute the program from scratch on Windows :
```
	flex Grammar_Parser.l
	gcc -o custom_testcase lex.yy.c
	.\custom_testcase.exe
```
