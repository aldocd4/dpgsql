module Dpgsql.Repository;

debug import std.stdio;
import std.string;
import std.exception;
import std.traits;
import std.conv;
import std.variant;

import Dpgsql.EntityManager;
import Dpgsql.Connection;
import Dpgsql.Command;
import Dpgsql.DataReader;
import Dpgsql.Parameter;
import Dpgsql.Entity;
import Dpgsql.Reflection;
import Dpgsql.Annotations;
import Dpgsql.Types;

interface IRepository
{
    
}

class Repository(T) : IRepository
{
    enum tableName = getTableName!(T);

    private Connection m_connection;
    private EntityManager m_em;
    
    public this(Connection connection, EntityManager em) pure nothrow @safe @nogc
    {
        this.m_connection = connection;
        this.m_em = em;
    }

    /**
     * Finds one entity by id
     * Params:
     *		id : id to find
     */
    public T find(in int id)
    {
        return this.findOneBy(["id" : id.to!string()]);
    }
        
    public T findOneBy(in string[string] parameters)
    {
        auto ret = this.findBy(parameters);

        if(ret.length)
        {
            return ret[0];
        }
        else return null;
    }
    
    /**
     * Finds entities
     * Params:
     *		parameters : parameters 
     */
    public T[] findBy(in string[string] parameters)
    {
        auto command = Command(this.m_connection);
        
        string clause;
        
        int i;
        foreach(key; parameters.byKey)
        {
            clause ~= format("%s = $%d AND ", key, ++i);	
            command.addParameter(parameters[key]);
        }

        command.query = format("SELECT %s FROM %s WHERE %s", getTableColumns!(T).chomp(","), tableName, clause.chomp(" AND "));

        version(LogQuery)
        {
            writeln(command.query);
        }
        
        auto dataReader = command.executeReader();
        
        if(dataReader.empty)
        {
            return null;
        }

        T[] ret = new T[dataReader.count];
        
        for(i = 0; i < dataReader.length; i++)
        {
            ret[i] = this.generateEntityFromRow(dataReader);
            dataReader.popFront();
        }
        
        return ret;
    }

    public bool remove(T : IEntity)(T entity)
    {
        auto command = Command(this.m_connection, format("DELETE FROM %s WHERE id = $1::int", tableName));
        command.addParameter(entity.id);
        
        version(LogQuery)
        {
            writeln(command.query);
        }

        return command.executeNonQuery() != 0;
    }

    /**
     * Inserts entity in table and returns ID
     * Params:
     *      entity : entity to insert
     */
    public int insert(T : IEntity)(T entity)
    {
        debug writeln("Inserting entity of type " , T.stringof);
        
        auto command = Command(this.m_connection);
        
        string values, columns;

        int paramIndex;
    
        foreach(i, dummy ; typeof(T.tupleof))
        {
            enum attributes = __traits(getAttributes, T.tupleof[i]);

            foreach(j, UDA; attributes)
            {
                static if(is(typeof(UDA) == Column))
                {
                    columns ~= UDA.columnName ~ ',';

                    static if(UDA.columnName == "id")
                    {
                        // ID
                        values ~= "default,";
                    }
                    else
                    {	
                        // $1::integer, 
                        values ~= format("$%d::%s,", ++paramIndex, getDbType!( typeof(T.tupleof[i]) )() );
                        
                        command.addParameter(entity.tupleof[i]);			
                    }
                }

            } // end foreach UDAs
        }

        command.query = format("INSERT INTO %s(%s) VALUES (%s) RETURNING id", tableName, columns.chomp(","), values.chomp(","));

        version(LogQuery)
        {
            writeln(command.query);
        }
        
        entity.setId(command.executeScalar());

        return entity.getId();
    }
    
    public bool update(T : IEntity)(T entity)
    {
        auto command = Command(this.m_connection);
                
        string values;
        
        int paramIndex;
        foreach(i, dummy ; typeof(T.tupleof))
        {
            enum attributes = __traits(getAttributes, T.tupleof[i]);

            foreach(j, UDA; attributes)
            {
                static if(is(typeof(UDA) == Column))
                {
                    static if(UDA.columnName != "id")
                    {         
                        // $1::integer, 
                        values ~= format("%s = $%d::%s,", UDA.columnName, ++paramIndex, getDbType!( typeof(T.tupleof[i]) )() );
                        
                        command.addParameter(entity.tupleof[i]);
                    }
                }
            }
        }
            
        command.query = format("UPDATE %s SET %s WHERE id = %d", tableName, values.chomp(","), entity.getId());
        
        version(LogQuery)
        {
            writeln(command.query);
        }

        return command.executeNonQuery() != 0;
    }

    /**
     * Generates entity from Datareader
     * Params:
     * 		 dataReader : dataReader
     */
    private T generateEntityFromRow(ref DataReader dataReader)
    {
        T toRet = new T();

        foreach(i, dummy ; typeof(toRet.tupleof))
        {
            enum attributes = __traits(getAttributes, toRet.tupleof[i]);

            foreach(j, UDA; attributes)
            {
                static if(is(typeof(UDA) == Column))
                {
                    toRet.tupleof[i] = dataReader.read!(typeof(T.tupleof[i]))(UDA.columnName);
                }
            }
        }

        return toRet;
    }
}
