module Dpgsql.Command;

debug import std.stdio;

import std.conv : to;
import std.string : toStringz;

import Dpgsql.Connection;
import Dpgsql.Parameter;
import Dpgsql.DataReader;
import Dpgsql.SqlException;
import derelict.pq.pq;

struct Command
{
    private PGconn* m_connection;

    private string m_query;

    /// List of parameters
    private Parameter[] m_parameters;
    
    private Object m_lock = new Object();

    public this(Connection sqlConnection, in string query = "") pure nothrow @safe @nogc
    {
        this.m_connection = sqlConnection.connection;
        this.m_query = query;
    }
    
    
    /**
     * Executes a query 
     */
    private PGresult* execute() @trusted
    {
        int[] length = new int[this.m_parameters.length];
        auto values = new ubyte*[this.m_parameters.length];
        int[] binary = new int[this.m_parameters.length];
        
        foreach(i, ref parameter; this.m_parameters)
        {			
            binary[i] = parameter.isBinary();
            values[i] = parameter.value.ptr;
            length[i] = cast(int)parameter.value.length;			
        }
                
        synchronized(this.m_lock)
        {
            version(LogQuery)
            {
                write(this.m_query);
            }

            // Execute query and get the result
            auto result = PQexecParams(this.m_connection, toStringz(this.m_query), this.m_parameters.length,
                null,
                values.ptr,
                length.ptr,
                binary.ptr,
                0);
            
            checkError(result);
    
            return result;
        }
    }
    
    /**
     * Executes a query and returns a numeric value
     */
    public T executeScalar(T)() @trusted
    {
        return this.getValue!T(this.execute(), 0, 0);
    }
    
    public int executeScalar() @trusted
    {
        return this.executeScalar!(int)();
    }

    /**
     * Executes a query and returns the count of affected rows
     */
    public int executeNonQuery() @trusted
    {
        // Get affected rows count
        char* value = PQcmdTuples(this.execute());
        
        if(*value == 0)
        {
            return 0;
        }

        return value.to!(char[]).to!int();
    }

    /**
     * Executes a query and returns a DataReader
     * 
     */
    public DataReader executeReader() @trusted
    {
        // Execute query and get the result
        auto result = this.execute();
        return DataReader(result);
    }

    private T getValue(T)(in PGresult* result, in int row, in int column) @trusted
    {
        synchronized(this.m_lock)
        {
            char* value = cast(char*)PQgetvalue(result, row, column);
            
            if(value is null)
                return 0;
            
            // ASCII value to string
            char[] strValue = to!(char[])(value);
    
            return strValue.to!T();
        }
    }

    /**
     * Adds parameter for the next query
     * Parameters must be added in good order
     * Params:
     *		value : value
     */
    public void addParameter(T)(in T value)
    {
        auto parameter = Parameter(value);
        
        this.m_parameters ~= parameter;
    }

    /**
     * Checks for error
     */
    public void checkError(in PGresult* result) @trusted
    {
        immutable string status = PQresStatus(PQresultStatus(result)).to!string();
        
        version(LogQuery)
        {
            writeln(" : " , status);
        }
        
        if(status == "PGRES_FATAL_ERROR")
        {
            // Throw error
            immutable string error = PQerrorMessage(this.m_connection).to!string();
            throw new SqlException(error);
        }
    }

    @property
    public void query(in string value) pure nothrow @safe @nogc
    {
        this.m_query = value;
    }
    
    @property
    public string query() const pure nothrow @safe @nogc
    {
        return this.m_query;
    }
}