module Dpgsql.Connection;

import std.conv : to;
import std.string : toStringz;

import Dpgsql.SqlException;
import Dpgsql.pgsql;

class Connection
{
    private PGconn* m_connection;

    private string m_connectionString;

    this(in string connectionString) pure nothrow @safe @nogc
    {
        this.m_connection = null;
        this.m_connectionString = connectionString;
    }

    /** 
     * Open connection to database
     */
    public void open()
    {
        this.m_connection = PQconnectdb(toStringz(this.m_connectionString));
        
        // Check status
        if(PQstatus(this.m_connection) != ConnStatusType.CONNECTION_OK)
        {
            immutable string error = PQerrorMessage(this.m_connection).to!string();
            throw new SqlException(error);
        }
        else
        {
            if(PQsetClientEncoding(this.m_connection, toStringz("UNICODE")) != 0)
            {
                throw new SqlException("errorencoding");
            }
        }
    }

    @property
    public PGconn* connection() pure nothrow @safe @nogc
    {
        return this.m_connection;
    }
}

