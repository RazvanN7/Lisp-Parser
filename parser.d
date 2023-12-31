import lexer : Lexer;
import ast_nodes;

import std.stdio : writefln;
import core.stdc.stdlib : exit;

class Parser : Lexer
{
    this(string text)
    {
        super(text);
    }

    /* A module is a collection of lists
       Parse each list and store it in an array.
     */
    LispList[] parseModule()
    {
        LispList[] stmts;
        auto tok = nextToken();
        while(tok != TokType.eof)
        {
            check(tok, TokType.lpar);
            stmts ~= parseList();
            tok = nextToken();
        }

        return stmts;
    }

    /*
       A list is a collection of atoms and strings.
       Scan until a closing parens in encountered.
     */
    private LispList parseList()
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
                    writefln("Error(%d): found `EOF` when expecting list member or `)`", line-1);
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
            writefln("Error(%d): expected `%s`, but found `%s`", line, tokToString(expected), currToken);
            exit(1);
        }
    }
}

/* ==============================================================================
                            Unittests
 */

// initial test
unittest
{
    string test = "(first (list2 1 (+ 2 3) 9))";
    Parser p = new Parser(test);
    auto stmts = p.parseModule();
    assert(stmts[0].toString() == "[first, [list2, 1, [+, 2, 3], 9]]");
}

// multiple statements
unittest
{
    string test = "(first (list2 1 (+ 2 3) 9))\n(first (list2 1 (+ 2 3) 9))";
    Parser p = new Parser(test);
    auto stmts = p.parseModule();
    foreach(stmt; stmts)
        assert(stmt.toString() == "[first, [list2, 1, [+, 2, 3], 9]]");
}

// test with lisp code that calculates the fth number in the Fibonnacci series
unittest
{
    string test =
        "(defun fib (f)
          (if (numberp f)
              (if (integerp f)
        	  (if (<= 0 f)
        	      (if (or (zerop f) (= f 1))
        		  1
        		  (+ (fib (- f 1))
        		     (fib (- f 2))))
        	      (error \"Argument Is Negative\"))
        	  (error \"Argument Is Not An Integer Number\"))
              (error \"Argument Is Not A Number!!!\")))
        ";

    Parser p = new Parser(test);
    auto stmts = p.parseModule();

    assert(stmts[0].toString() == "[defun, fib, [f], [if, [numberp, f], [if, [integerp, f], [if, [<=, 0, f], [if, [or, [zerop, f], [=, f, 1]], 1, [+, [fib, [-, f, 1]], [fib, [-, f, 2]]]], [error, Argument Is Negative]], [error, Argument Is Not An Integer Number]], [error, Argument Is Not A Number!!!]]]");

}

// fibonaci golden with comments
unittest
{
    string test =
        ";; implementation of the fibonacci sequence 
         ;; calculation with the golden ratio formula:
         ;; Nx = ( (phi)^x - (1 - phi)^x ) / sqrt(5)
         ;; where phi, the golden ratio, is:
         ;; phi = 1.6180339887...

         (defparameter phi 1.6180339887)

         (defun fib_gold (n)
           (if (numberp n)
               (if (integerp n)
         	  (if (>= n 0)
         	      (floor (/ (- (expt phi n) (expt (- 1 phi) n) ) (sqrt 5)))
         	      (error \"Argument Is Negative !!!\"))
         	  (error \"Argument Is Not An Integer !!!\"))
            (error \"Argument Is Not A Number\")))
        ";

    Parser p = new Parser(test);
    auto stmts = p.parseModule();

    assert(stmts[0].toString() == "[defparameter, phi, 1.6180339887]");
    assert(stmts[1].toString() == "[defun, fib_gold, [n], [if, [numberp, n], [if, [integerp, n], [if, [>=, n, 0], [floor, [/, [-, [expt, phi, n], [expt, [-, 1, phi], n]], [sqrt, 5]]], [error, Argument Is Negative !!!]], [error, Argument Is Not An Integer !!!]], [error, Argument Is Not A Number]]]");
}
