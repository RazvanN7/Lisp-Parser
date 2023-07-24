import std.range;
import std.algorithm;
import std.stdio;
import std.ascii;
import std.string : isNumeric;

import core.stdc.stdlib;

enum TokType
{
    lpar,   // (
    rpar,   // )
    str,
    plus,
    minus,
    div,
    mul,
    id,
    num,
    eof,
}

string tokToString(TokType tok)
{
    switch(tok)
    {
        case TokType.lpar: return "(";
        case TokType.rpar: return ")";
        case TokType.plus: return "+";
        case TokType.minus: return "-";
        case TokType.div: return "/";
        case TokType.mul: return "*";
        case TokType.str: return "string";
        case TokType.num, TokType.id: return "atom";
        default: assert(0, "This should not be reached");
    }

    assert(0, "This should not be reached");
}

string seps = " \n\r\t\v\f,)(+-/*";

class Lexer
{
    string text;
    string currToken;
    this(string text)
    {
        this.text = text;
    }

    TokType nextToken()
    {
        if (text.empty())
            return TokType.eof;

Lagain:
        switch(text[0])
        {
            case '(' :
                currToken = "(";
                text.popFront();
                return TokType.lpar;
            case ')' :
                currToken = ")";
                text.popFront();
                return TokType.rpar;
            case '+' :
                currToken = "+";
                text.popFront();
                return TokType.plus;
            case '-' :
                currToken = "-";
                text.popFront();
                return TokType.minus;
            case '/' :
                currToken = "/";
                text.popFront();
                return TokType.div;
            case '*' :
                currToken = "*";
                text.popFront();
                return TokType.mul;
            case ' ':
            case '\n':
            case '\r':
            case '\t':
            case '\v':
            case '\f':
                text.popFront();
                goto Lagain;
            case '"' :
                text.popFront();
                auto str = text.find!(a => a == '\"');

                if (str.empty())
                {
                    writeln("Error: unterminated string");
                    exit(1);
                }

                currToken = text[0 .. str.ptr - text.ptr];
                text = str;
                text.popFront();

                return TokType.str;
            default:
                auto textTmp = text.findAmong(seps);
                currToken = text[0 .. textTmp.ptr - text.ptr];
                text = textTmp;

                if (currToken.isNumeric())
                    return TokType.num;

                if (!text.empty() && text[0].isDigit())
                {
                    writeln("Error: An atom cannot start with a number");
                    exit(1);
                }

                return TokType.id;
        }

        assert(0, "This should not be reached");
    }
}

/* ============================================================================
                                Unittests
 */

// initial example
unittest
{
    Lexer lex = new Lexer("(first (list2 1 (+ 2 3) 9))");
    assert(lex.nextToken == TokType.lpar);

    assert(lex.nextToken == TokType.id);
    assert(lex.currToken == "first");

    assert(lex.nextToken == TokType.lpar);

    assert(lex.nextToken == TokType.id);
    assert(lex.currToken == "list2");

    assert(lex.nextToken == TokType.num);
    assert(lex.currToken == "1");

    assert(lex.nextToken == TokType.lpar);
    assert(lex.nextToken == TokType.plus);

    assert(lex.nextToken == TokType.num);
    assert(lex.currToken == "2");

    assert(lex.nextToken == TokType.num);
    assert(lex.currToken == "3");

    assert(lex.nextToken == TokType.rpar);

    assert(lex.nextToken == TokType.num);
    assert(lex.currToken == "9");
    assert(lex.nextToken == TokType.rpar);
    assert(lex.nextToken == TokType.rpar);
}

// strings
unittest
{
    Lexer lex = new Lexer("(first \"one str\" \"two str\")");
    assert(lex.nextToken == TokType.lpar);
    assert(lex.nextToken == TokType.id);
    assert(lex.currToken == "first");
    assert(lex.nextToken == TokType.str);
    assert(lex.currToken == "one str");
    assert(lex.nextToken == TokType.str);
    assert(lex.currToken == "two str");
    assert(lex.nextToken == TokType.rpar);
}

// whitespaces
unittest
{
    Lexer lex = new Lexer("\n\n   ( \v\n\r\f\t a (    + 2 - -))");
    assert(lex.nextToken == TokType.lpar);
    assert(lex.nextToken == TokType.id);
    assert(lex.currToken == "a");
    assert(lex.nextToken == TokType.lpar);
    assert(lex.nextToken == TokType.plus);
    assert(lex.nextToken == TokType.num);
    assert(lex.currToken == "2");
    assert(lex.nextToken == TokType.minus);
    assert(lex.nextToken == TokType.minus);
    assert(lex.nextToken == TokType.rpar);
    assert(lex.nextToken == TokType.rpar);
}

// invalid parser code, but valid lexer code
unittest
{
    Lexer lex = new Lexer("(first");
    assert(lex.nextToken == TokType.lpar);
    assert(lex.nextToken == TokType.id);
    assert(lex.currToken == "first");
}
