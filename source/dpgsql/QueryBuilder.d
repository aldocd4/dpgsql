module dpgsql.QueryBuilder;

import std.string;
import std.array;
        
debug import std.stdio;

import dpgsql.Connection;
import dpgsql.Command;
import dpgsql.DataReader;

struct QueryBuilder
{
    private Connection m_connection;

    private string[] m_selectColumns;
    private string m_tableName;
    
    public this(Connection connection)
    {
        this.m_connection = connection;
    }
        
    public QueryBuilder* select(string columns)
    {
        this.m_selectColumns ~= columns.split(',');
        
        return &this;
    }

    public QueryBuilder* from(string table)
    {
        this.m_tableName = table;
        return &this;
    }
    
    public DataReader fetch()
    {
        immutable string query = format("SELECT %s FROM %s", this.m_selectColumns.join(','), this.m_tableName);
        
        this.m_selectColumns = [];
        
        version(LogQuery)
        {
            writeln(query);
        }
        
        auto command = Command(this.m_connection, query);
        return command.executeReader();
    }
}
