%{
        #include <stdio.h>
        #include <stdlib.h>
		#include <string.h>

		int infor = 0;
		int nrTabs = 0;

		char declaredVariables[1000][100];
        char lists[1000][100];          // liste declarate cu List
        char arrayLists[1000][100];     // liste declarate cu ArrayList
        char linkedLists[1000][100];    // liste declarate cu LinkedList
		int nrVariables = 0;            // numarul de primitive declarate
        int nrLists = 0;        // numarul de liste declarate cu List
        int aLists = 0;         // numarul de liste declarate cu ArrayList
        int lLists = 0;         // numarul de liste declarate cu LinkedList

        char myOp[100];
		char myName[100];

		/*
		Instructiunile pe care le parseaza si traduce programul sunt:
            - if
            - else
            - while
            - for / for each
            - declararea unei variabile
            - initializarea/asignarea unei variabile
            - afisarea unui string
            - declararea unei metode
		*/
%}

%union{
        char* num;
		char* flt;
        char* var;
        char* string;
        char* comment;
}
%token IF ELSE WHILE FOR LE GE EQ NE AND OR INT FLOAT
%token ARRAYLIST LINKEDLIST LIST_INTERFACE NEW CLASS VOID RETURN PRINT
%token <num> INTNUM
%token <flt> FLOATNUM
%token <string> NAME
%token <comment> ANYTHING
%type <string> declaration value operation asign cond F exp ifst elsest whilest forst statement initialization

%right '='
%left AND OR
%left '<' '>' LE GE EQ NE

%left '+' '-'
%left '*' '/' '%'
%left '(' ')'
%%

/*
 - un program este format din instructiuni
*/
program: instructions
        ;

/*
 - o instructiune este un statement urmat de mai multe instructiuni
    sau doar un statement
*/
instructions: statement instructions
        | statement
        ;

/*
- o valoare poate fi integer sau float
*/
value: INTNUM {$$ = strdup($1);}	/* un value poate fi intreg sau fractional*/
	| FLOATNUM {$$ = strdup($1);}
	;

statement:  whilest			{printf("\n");}		  /*tot ce poate fi un statement*/
			| ifst elsest 	{printf("\n");}	      /*else poate exista doar daca exista un if precedent*/
			| ifst 			{printf("\n");}
            | declaration ';'
			| asign ';'
			| {infor = 1;} forst	{printf("\n");}
            | method    {printf("\n");}
            | printst    {printf("\n");}
			;

/*
- o declarare poate fi primitiva sau lista
- o lista poate fi declarata cu List, ArrayList sau LinkedList
- la fiecare declarare retin in cate un sir variabelele,
    pentru ca mai tarziu sa verific daca au fost declarate
- listele se adauga in siruri diferite (cate un sir pentru fiecare sir)
*/
declaration: INT NAME       {strcpy(declaredVariables[nrVariables], strdup($2)); nrVariables++;}
            | FLOAT NAME    {strcpy(declaredVariables[nrVariables], strdup($2)); nrVariables++;}
            | ARRAYLIST '<' '>' NAME        {strcpy(arrayLists[aLists], strdup($4)); aLists++;}
            | LINKEDLIST '<' '>' NAME       {strcpy(linkedLists[lLists], strdup($4)); lLists++;}
            | LIST_INTERFACE '<' '>' NAME   {strcpy(lists[nrLists], strdup($4)); nrLists++;}
		;

/*
 - o initializare este similara cu o declarare, dar se asigneaza ceva la denumire
*/
initialization: INT NAME '=' INTNUM { // initializarea unui int poate fi doar cu un numar intreg
									sprintf(myOp, "%s = %s", $2, $4);
									$$ = strdup(myOp);
                                    // adaug in lista de variabile
									strcpy(declaredVariables[nrVariables], strdup($2)); nrVariables++;
									}
		| FLOAT NAME '=' INTNUM { 	// un float poate fi initializat si cu numar intreg si cu numar real
									sprintf(myOp, "%s = %s", $2, $4);
									$$ = strdup(myOp);
                                    // adaug in lista de variabile
									strcpy(declaredVariables[nrVariables], strdup($2)); nrVariables++;
								}
		| FLOAT NAME '=' FLOATNUM {
									sprintf(myOp, "%s = %s", $2, $4);
									$$ = strdup(myOp);
                                    // adaug in lista de variabile
									strcpy(declaredVariables[nrVariables], strdup($2)); nrVariables++;
								}
        | LIST_INTERFACE '<' '>' NAME '=' NEW ARRAYLIST '<' '>' '(' ')'    {
									sprintf(myOp, "%s = []", $4);
									$$ = strdup(myOp);
                                    // adaug in lista de liste
									strcpy(lists[nrLists], strdup($4)); nrLists++;
								}
        | LIST_INTERFACE '<' '>' NAME '=' NEW LINKEDLIST '<' '>' '(' ')'   {
                                    sprintf(myOp, "%s = []", $4);
                                    $$ = strdup(myOp);
                                    // adaug in lista de liste
                                    strcpy(lists[nrLists], strdup($4)); nrLists++;
                                }
        | ARRAYLIST '<' '>' NAME '=' NEW ARRAYLIST '<' '>' '(' ')'    {
									sprintf(myOp, "%s = []", $4);
									$$ = strdup(myOp);
                                    // adaug in lista de arrayList-uri
									strcpy(arrayLists[aLists], strdup($4)); aLists++;
								}
        | LINKEDLIST '<' '>' NAME '=' NEW LINKEDLIST '<' '>' '(' ')'    {
									sprintf(myOp, "%s = []", $4);
									$$ = strdup(myOp);
                                    // adaug in lista de linkedList-uri
									strcpy(linkedLists[lLists], strdup($4)); lLists++;
								}
		;

/*
 - if statement
 - contine 'if', conditie intre paranteze si o instructiune sau mai multe instructiuni
    similar si pentru else, while si for
 - se incrementeasa contorul nrTabs dupa inceputul fiecarei instructiuni
    si se decrementeaza dupa finalizarea fiecareia pentru
    a sti cate taburi sa se afiseze
 - functia printStatement este folosita pentru fiecare statement, inafara de for si print
*/
ifst:	IF '(' cond ')' '{' {printStatement("if", $3); nrTabs++;} instructions '}'    {nrTabs--;}
        | IF '(' cond ')'   {printStatement("if", $3); nrTabs++;} statement           {nrTabs --;}
        ;

/*
 - un else statement poate fi cu o conditie de if sau fara
*/
elsest:  ELSE IF '(' cond ')'       {printStatement("else if", $4); nrTabs++;} statement    {nrTabs --;}
        | ELSE IF '(' cond ')' '{'  {printStatement("else if", $4); nrTabs++;} instructions '}' {nrTabs--;}
        | ELSE      {printStatement("else", ""); nrTabs++;} statement
        | ELSE '{'  {printStatement("else", ""); nrTabs++;} instructions '}' {nrTabs--;}
        ;

whilest:WHILE '(' cond ')'          {printStatement("while", $3); nrTabs++;} statement {nrTabs--;}
        | WHILE '(' cond ')' '{'    {printStatement("while", $3); nrTabs++;} instructions '}' {nrTabs --;}
        ;

/*
- avem for simplu si for each
- pentru for each se verifica daca se parcurge o lista
    (daca al doilea name este in unul din sirurile pentru liste)
*/
forst: FOR '(' asign ';' cond ';' asign ')'     { printFor($3, $5);} '{' instructions '}' {nrTabs--;}
		| FOR '(' asign ';' cond ';' asign ')'    { printFor($3, $5);} statement {nrTabs--;}
        | FOR '(' NAME ':' NAME ')' {
            if (!declared($5, lists, nrLists) && !declared($5, arrayLists, aLists) && !declared($5, linkedLists, lLists)){
                printf("%s is not a list!", $5);    // daca nu este o lista, afisez mesaj de eroare si opresc executia
                return;
            }
            strcpy(declaredVariables[nrVariables], strdup($3)); // adaug elementul cu care se parcurge in lista de elemente declarate
            nrVariables++;                                      // pentru a putea fi folosita in interiorul for-ului
            printForEach($3, $5);
        } '{' instructions '}' {nrTabs--;}
        | FOR '(' NAME ':' NAME ')' {
            if (!declared($5, lists, nrLists) && !declared($5, arrayLists, aLists) && !declared($5, linkedLists, lLists)){
                printf("%s is not a list!", $5);    // daca nu este o lista, afisez mesaj de eroare si opresc executia
                return;
            }
            strcpy(declaredVariables[nrVariables], strdup($3));
            nrVariables++;
            printForEach($3, $5);
        } {nrTabs--;}
		;

/*
 - un parametru al unei metode poate fi o declarare
    sau mai multe declarari separate prin virgula
*/
parameters: declaration ',' parameters
        | declaration
        ;

/*
 - o metoda poate fi void sau poate sa returneze un tip de date
 - cele care sunt declarate cu un tip de date trebuie sa returneze ceva
*/
method: VOID NAME '(' parameters ')' '{' {printStatement("def", $2); nrTabs++;} instructions '}' {nrTabs--;}
        | INT NAME '(' parameters ')' '{' {printStatement("def", $2); nrTabs++;} instructions RETURN operation ';'
                                            {printStatement("return ", $10);} '}' {nrTabs--;}
        | FLOAT NAME '(' parameters ')' '{' {printStatement("def", $2); nrTabs++;} instructions RETURN operation ';'
                                            {printStatement("return ", $10);} '}' {nrTabs--;}
        | INT NAME '(' parameters ')' '{' {printStatement("def", $2); nrTabs++;} RETURN operation ';'
                                            {printStatement("return ", $9);} '}' {nrTabs--;}
        | FLOAT NAME '(' parameters ')' '{' {printStatement("def", $2); nrTabs++;} RETURN operation ';'
                                            {printStatement("return ", $9);} '}' {nrTabs--;}
        ;

/*
 - print statement
 - intre paranteze poate avea un string intre ghilimele
*/
printst:    PRINT '(' ANYTHING ')' ';' {printPrint($3);}

/*
 - F poate fi o valoare sau o denumire (nu denumire de lista)
 - daca este o denumire, se verifica sa fie declarata
*/
F:      value {$$ = strdup($1);}
        | NAME {
            $$ = strdup($1);
            if (!declared($1, declaredVariables, nrVariables)) {
            	printf("%s is not declared!", $1);
            	return;
            }
		}
        ;

/*
 - operation reprezinta o operatie de adunare, scadere, inmultire sau impartire intre alte doua operatii,
    poate poate fi o operatie intre paranteze sau poate fi un F cu sau fara minus
*/
operation:  /*NAME {sprintf(myOp, "%s", $1); $$ = strdup(myOp);}
  			| value {sprintf(myOp, "%s", $1); $$ = strdup(myOp);}*/
  			operation '+' operation {sprintf(myOp, "%s + %s", $1, $3); $$ = strdup(myOp);}
            | operation '-' operation {sprintf(myOp, "%s - %s", $1, $3); $$ = strdup(myOp);}
            | operation '*' operation {sprintf(myOp, "%s * %s", $1, $3); $$ = strdup(myOp);}
            | operation '/' operation {sprintf(myOp, "%s / %s", $1, $3); $$ = strdup(myOp);}
            | '(' operation ')' { sprintf(myOp, "(%s)", $2); $$ = strdup(myOp);}
			| '-' F {sprintf(myOp, "-%s", $2); $$ = strdup(myOp);}
            | F     {sprintf(myOp, "%s", $1); $$ = strdup(myOp);}
            ;


/*
 o asignare poate fi:
    - o asigrare dintre un nume si o operatie
    - un nume si doi de '+'
    - un nume asignat la un constructor de ArrayList sau LinkedList
    - o initializare
*/
asign:  NAME '=' operation {    // verific daca variabila a fost declarata
                                // daca nu, afisez mesaj de eroare si opresc executia
                                if (!declared($1, declaredVariables, nrVariables)) {
                                    printf("%s is not declared!", $1);
                                    return;
                                }

                                sprintf(myName, "%s = %s", $1, $3);
                                $$ = strdup(myName);
                                // infor este folosita pentru a sti daca sunt intr-un for sau nu
                                // daca nu sunt in for, afisez asignarea, daca da, va fi afisata de printFor
                                if (infor == 0)
                                    printAsign($$);
                            }
        |NAME '+''=' operation {    // verific daca variabila a fost declarata
                                        // daca nu, afisez mesaj de eroare si opresc executia
                                        if (!declared($1, declaredVariables, nrVariables)) {
                                            printf("%s is not declared!", $1);
                                            return;
                                        }

                                        sprintf(myName, "%s += %s", $1, $4);
                                        $$ = strdup(myName);
                                        // infor este folosita pentru a sti daca sunt intr-un for sau nu
                                        // daca nu sunt in for, afisez asignarea, daca da, va fi afisata de printFor
                                        if (infor == 0)
                                            printAsign($$);
                                    }

		| NAME '+''+' {sprintf(myName, "%s += %s", $1, "1"); $$ = strdup(myName); if (infor == 0) printAsign($$);}
        | NAME '=' NEW ARRAYLIST '<' '>' '(' ')' {
                                        if (!declared($1, lists, nrLists) && !declared($1, arrayLists, aLists)) {
                                            printf("%s is not declared!", $1);
                                            return;
                                        }

                                        sprintf($$, "%s = []", $1);
                                        if (infor == 0)
                                            printAsign($$);
                                    }
        | NAME '=' NEW LINKEDLIST '<' '>' '(' ')' {
                                        if (!declared($1, lists, nrLists) && !declared($1, linkedLists, lLists)) {
                                            printf("%s is not declared!", $1);
                                            return;
                                        }

                                        sprintf($$, "%s = []", $1);
                                        if (infor == 0)
                                            printAsign($$);
                                    }
        | initialization {$$ = strdup($1); if (infor == 0) printAsign($$);}
		;

/*
 - o conditie poate fi un AND sau OR intre alte doua conditii sau o expresie (exp)
*/
cond:   cond OR cond {sprintf($$, "%s || %s", $1, $3);}
        | cond AND cond {sprintf($$, "%s && %s", $1, $3);}
        | exp {$$ = strdup($1);}
        ;

/*
 - o expresie poate fi o conditie de egalitate intre 2 factori
*/
exp:    F '>' F         {sprintf(myName, "%s > %s", $1, $3); $$ = myName;}
        | F '<' F       {sprintf(myName, "%s < %s", $1, $3); $$ = myName;}
        | F LE F        {sprintf(myName, "%s <= %s", $1, $3); $$ = myName;}
        | F GE F        {sprintf(myName, "%s >= %s", $1, $3); $$ = myName;}
        | F EQ F        {sprintf(myName, "%s == %s", $1, $3); $$ = myName;}
        | F NE F        {sprintf(myName, "%s != %s", $1, $3); $$ = myName;}
        ;


%%
#include "lex.yy.c"
#include <ctype.h>

/*
 - functie care verifica declararea unui element sau a unei liste
 - v este sirul de string-uri in care va fi cautat numele name si are lungimea n
 - returneaza 1 daca a fost gasit, 0 in caz contrar
*/
int declared(char* name, char v[1000][100], int n){
	for (int i = 0; i < n; i++){
		if (strcmp(name, v[i]) == 0){     // verific daca este vreun element egal in sir folosind strcmp
			return 1;
		}
	}
	return 0;
}

/*
 - functie folosita pentru extragerea ultimului numar dintr-o conditie / asignare
 - folostia pentru afisarea for-ului (determinarea numarului care trebuie pus in range)
 - de exemplu pentru "i <= 100" va returna 100
*/
int extractInt(char* str){
	int number = 0;
	int x;
	for (x = strlen(str) - 1; x >= 0; x--){    // parcurg inapoi string-ul pana cand dau de un caracter care nu este cifra
		if (str[x] < '0' || str[x] > '9'){
			break;
		}
	}
	x++;   // x va fi index-ul ultimului caracter care nu este cifra, asa ca il incrementez pentru a fi la prima cifra
	for (int i = x; i < strlen(str); i++){ // construiesc numarul in "number", apoi il returnez
		number = number * 10 + str[i] - '0';
	}
	return number;
}

/*
 - functie folosita pentru afisarea unei instructiuni for simpla
*/
void printFor(char* asign, char* cond){
	int num = 0;
	int end = 0;

    // extrag numarul din asignarea de pornire si din conditie
	num = extractInt(asign);
	end = extractInt(cond);

	char stat[100];    // aici pun string-ul final

	if (num == 0){     // daca numarul de pornire este 0, in functia range pun doar ultimul numar
		sprintf(stat, "for %s in range(%d)", asign, end);
	}else{             // altfel, le pun pe ambele separate prin virgula
		sprintf(stat, "for %s in range(%d, %d)", asign, num, end);
	}
	printStatement(stat, "", nrTabs);  // la final folosesc functia de afisare a unui statement
    nrTabs++;   // incrementez numarul de tab-uri pentru instructiunile din interiorul for-ului
	infor = 0;
}

/*
 - functie pentru afisarea unei instructiuni for each
*/
void printForEach(char* var, char* list){
    char stat[100];
    sprintf(stat, "for %s in %s", var, list);   // afisez normal un for each in python
    printStatement(stat, "");
    nrTabs++;   // incrementez numarul de tab-uri pentru instructiunile din interiorul for-ului
    infor = 0;
}

/*
 - functie folosita pentru afisarea uneui asignari
*/
void printAsign(char* asign){
	char t[1000] = "";     // in t pun numarul de taburi necesar inainte de a afisa asignarea
	for (int i = 0; i < nrTabs; i++){
		strcat(t, "    ");
	}
	printf("%s%s\n", t, asign);
}

/*
 - functie pentru afisarea unui statement
 - are ca parametrii: denumirea statement-ului si conditia
*/
void printStatement(char* st, char* cond){
	char t[1000] = "";     // in t pun numarul de taburi necesar inainte de a afisa asignarea
	for (int i = 0; i < nrTabs; i++){
		strcat(t, "    ");
	}
	if (strlen(cond) != 0) // daaca conditia nu este goala, pun un spatiu intre denumire si conditie
		printf("%s%s %s:\n", t, st, cond);
	else
		printf("%s%s%s:\n", t, st, cond);
}

/*
 - functie folosita pentru afisarea print-ului
*/
void printPrint(char* comment){
	char t[1000] = "";
	for (int i = 0; i < nrTabs; i++){
		strcat(t, "    ");
	}
	printf("print(%s)", comment);
}

void main()
{
    yyparse();
}
