lex scanner.flex
yacc -d parser.y -v --warnings=none
gcc y.tab.c -g 
./a.out test.c