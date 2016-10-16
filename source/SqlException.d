module Dpgsql.SqlException;

class SqlException : Exception
{
    public this(string msg, string file = __FILE__, size_t line = __LINE__) 
    {
        super(msg, file, line);
    }
}

class InvalidColumnIndexException : Exception
{
    public this(string msg, string file = __FILE__, size_t line = __LINE__) 
    {
        super(msg, file, line);
    }
}