module Dpgsql.DataReader;

import std.conv : to;
import std.string : toStringz;
import std.traits;
import std.variant;

import Dpgsql.Types;
import Dpgsql.SqlException;
import derelict.pq.pq;

struct Row
{
    public Variant[string] values;

    // row.name
    @property auto opDispatch(string column)() 
    {
        return this.values[column];
    }
}

struct DataReader
{
    /// Rows count
    private int m_rowsCount;

    /// Columns count
    private int m_columnsCount;

    /// Current row index
    private int m_currentRowIndex;

    /// Query result
    private PGresult* m_result;

    public this(PGresult* result)
    {
        this.m_result = result;
        this.m_rowsCount = PQntuples(result);        
        this.m_columnsCount = PQnfields(result);
    }

    /**
     * Reads a value by column index and automatically deduce value type 
     * Params:
     *		column : column index
     */
    public Variant read(in int column) @trusted
    {
        assert(column <= this.m_columnsCount);

        switch(PQftype(this.m_result, column))
        {
            case DbType.Varchar : return Variant(this.read!string(column));
            case DbType.Bool: return Variant(this.read!bool(column));
            case DbType.Short: return Variant(this.read!short(column));
            case DbType.Int: return Variant(this.read!int(column));
            case DbType.Long: return Variant(this.read!long(column));
            case DbType.Float: return Variant(this.read!float(column));
            case DbType.Float8: return Variant(this.read!double(column));
                
            default : 
                return Variant(this.read!string(column));
        }
    }
    
    /**
     * Reads a value by column name
     * Params:
     *   	 columnName : column name
     */
    public T read(T)(in string columnName) @trusted
    {
        immutable columnIndex = PQfnumber(this.m_result, columnName.ptr);

        if(columnIndex == -1)
        {
            import std.string : format;
            throw new InvalidColumnIndexException(format("Invalid column \"%s\".", columnName));
        }

        return this.read!T(columnIndex);
    }

    /**
     * Reads a value by column index
     * Params:
     *   	 column : column index
     */
    public T read(T)(in int column) @trusted
    {
         assert(column <= this.m_columnsCount);

        char* value = cast(char*)PQgetvalue(this.m_result, this.m_currentRowIndex, column);
        
        if(value is null || *value == '\0')
        {
            // String
            static if(isSomeString!T)
            {
                return "null";
            }
            else return 0;
        }
        
        return value.to!(char[]).to!T();
    }
    
    public bool read(T : bool)(in int column)
    {
        return this.read!string(column) == "t" ?  true : false;
    }

    public void popFront() pure nothrow @safe @nogc
    {
        this.m_currentRowIndex++;
    }

    @property
    public Row front()
    {
        Variant[string] ret;

        foreach(i; 0..this.m_columnsCount)
        {
            char* columnName = PQfname(this.m_result, i);

            ret[columnName.to!(char[]).to!string()] = this.read(i);
        }

        return Row(ret);
    }

    @property 
    public bool empty() const pure nothrow @safe @nogc
    {
        return this.m_currentRowIndex == this.m_rowsCount;
    }

    @property
    public int length() const pure nothrow @safe @nogc
    {
        return this.m_rowsCount;
    }
    
    @property
    public int currentRow() const pure nothrow @safe @nogc
    {
        return this.m_currentRowIndex;
    }
}

