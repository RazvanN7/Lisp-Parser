import std.range;
import std.algorithm : findAmong, find;
import std.stdio : writefln;
import std.ascii : isDigit;
import std.string : isNumeric;

import core.stdc.stdlib : exit;

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

string seps = "\n\r\v\f \t;)(+-/*";

class Lexer
{
    private string text;
    string currToken;
    int line = 1;

    this(string text)
    {
        this.text = text;
    }

    /*
       All lexing is done here.
       The first character is scanned to see if it is a special character.
       Spaces, comments and newlines are skipped.
       Atoms and stringed are stored in the `currToken` and the cursor is
       advanced to the next character.
    */
    TokType nextToken()
    {

Lagain:
        if (text.empty())
            return TokType.eof;

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
            case ';' :
                auto textTmp = text.findAmong(seps[0 .. 4]);
                currToken = text[0 .. textTmp.ptr - text.ptr];
                text = textTmp;
                goto Lagain;
            case '\n':
            case '\r':
            case '\v':
            case '\f':
                ++line;
                goto case;
            case ' ':
            case '\t':
                text.popFront();
                goto Lagain;
            case '"' :
                text.popFront();
                auto str = text.find!(a => a == '\"');

                if (str.empty())
                {
                    writefln("Error(%d): missing ending quote for string", line);
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

                if (!text.empty() && currToken[0].isDigit())
                {
                    writefln("Error(%d): An atom cannot start with a number: `%s`", line, currToken);
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

// comments are lexed properly
unittest
{
    Lexer lex = new Lexer("; comment \n (list)");
    assert(lex.nextToken == TokType.lpar);
    assert(lex.nextToken == TokType.id);
    assert(lex.currToken == "list");
    assert(lex.nextToken == TokType.rpar);
}
