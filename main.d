import std.stdio;
import std.file : readText;
import std.range;
import parser;

int main(string[] args)
{
    if (args.empty)
    {
        writeln("Usage: ./lisp_parser file_to_parse");
        return 1;
    }

    string fileToParse = args[1];
    string filetext = readText(fileToParse);

    Parser p = new Parser(filetext);
    auto l = p.parseList();

    writeln(l);

    return 0;
}
