###############################################################################
#
#   Sample Makefile
#
###############################################################################

SHELL = /bin/sh
CC = gcc
LEX = flex
YACC = yacc
EXECUTABLE = PROGRAM
UNAME_S := $(shell uname -s)
FILE = mg.f23
all: 
	$(LEX) lexer.l
	$(YACC) parser.y -v -d
	$(CC) -o $(EXECUTABLE) y.tab.c -ll
	./$(EXECUTABLE) < $(FILE) | tee proofOfOutput.txt
	$(CC) f23.c -lm; ./a.out | tee -a proofOfOutput.txt

touch:
	touch *

1: set1 all

2: set2 all

3: set3 all

4: set4 all

mg.f23: set5 all

set1: 
	$(eval FILE=te1.f23)
	
set2: 
	$(eval FILE=te2.f23)

set3:
	$(eval FILE=te3.f23)

set4:
	$(eval FILE=te4.f23)

set5:
	$(eval FILE=mg.f23)

help:
	@echo 'Your options are the following:'
	@echo "    make help"
	@echo "        Print a help message"
	@echo "    make all"
	@echo "        Makes the simple example program and runs it"
	@echo "    make clean"
	@echo "        Removes extra files, but leaves f23.c intact"

clean:
	rm -f $(EXECUTABLE) zzz lex.yy.c y.output y.tab.c y.tab.h a.out yourmain.h

###############################################################################
#
# C'est finis
#
###############################################################################

