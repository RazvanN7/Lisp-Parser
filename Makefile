DC = dmd

lisp_parser: main.o lexer.o parser.o ast_nodes.o
	$(DC) $^ -of=$@

main.o: main.d
	$(DC) -c $^

lexer.o: lexer.d
	$(DC) -c $^

parser.o: parser.d
	$(DC) -c $^

ast_nodes.o: ast_nodes.d
	$(DC) -c $^

unittest:
	dmd -unittest -main parser.d lexer.d ast_nodes.d
	./parser

clean:
	rm -rf *.o lexer parser lisp_parser
