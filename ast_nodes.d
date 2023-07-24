interface AstNode
{
    string toString();
}

class LispList : AstNode
{
    AstNode[] listMembers;
    this(AstNode[] listMembers)
    {
        this.listMembers = listMembers;
    }

    override string toString()
    {
        string res = "[";
        foreach(item; listMembers)
        {
            res ~= item.toString();
            res ~= ", ";
        }

        res = res[0 .. $-2];
        res ~= "]";
        return res;
    }
}

class Atom : AstNode
{
    bool isNumber;
    string literal;

    this(string literal, bool isNumber)
    {
        this.literal = literal;
        this.isNumber = isNumber;
    }

    override string toString()
    {
        return literal;
    }
}

class String : AstNode
{
    string stringLiteral;

    this(string stringLiteral)
    {
        this.stringLiteral = stringLiteral;
    }

    override string toString()
    {
        return stringLiteral;
    }
}
