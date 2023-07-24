import lexer;
import ast_nodes;

import std.stdio : writefln, writeln;
import core.stdc.stdlib : exit;

class Parser : Lexer
{
    this(string text)
    {
        super(text);
        check(nextToken(), TokType.lpar);
    }

    LispList parseList()
    {
        AstNode[] listMembers;
        while(1)
        {
            auto tokType = nextToken();
            switch(tokType)
            {
                case TokType.lpar:
                    listMembers ~= parseList();
                    break;
                case TokType.rpar:
                    LispList res = new LispList(listMembers);
                    return res;
                case TokType.str:
                    listMembers ~= new String(currToken);
                    break;
                case TokType.num:
                    listMembers ~= new Atom(currToken, true);
                    break;
                case TokType.id:
                case TokType.plus:
                case TokType.minus:
                case TokType.div:
                case TokType.mul:
                    listMembers ~= new Atom(currToken, false);
                    break;
                case TokType.eof:
                    writeln("Error: found `EOF` when expecting list member or `)`");
                    exit(1);
                default:
                    assert(0);
            }
        }

        assert(0, "parser end");
    }

    void check(TokType current, TokType expected)
    {
        if (current != expected)
    {
            writefln("Error: expected `%s`, but found `%s`", tokToString(expected), tokToString(current));
        }
    }
}

// initial test
unittest
{
    string test = "(first (list2 1 (+ 2 3) 9))";
    Parser p = new Parser(test);
    assert(p.parseList().toString() == "[first, [list2, 1, [+, 2, 3], 9]]");
}
