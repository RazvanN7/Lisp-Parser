import std.stdio;
import std.file : readText;
import std.range;
import parser;

int main(string[] args)
{
    if (args.length < 2)
    {
        writeln("Usage: ./lisp_parser file_to_parse");
        return 1;
    }

    string fileToParse = args[1];
    string filetext = readText(fileToParse);

    Parser p = new Parser(filetext);
    auto stmts = p.parseModule();

    foreach(stmt; stmts)
        writeln(stmt);

    return 0;
}
