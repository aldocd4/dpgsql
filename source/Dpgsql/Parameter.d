module Dpgsql.Parameter;

import Dpgsql.Types;

import std.conv;
import std.bitmanip;

struct Parameter
{
    private DbType m_type;

    private ubyte[] m_value = null;
    
    public this(T)(in T v)
    {
        this.m_type = getDbType!(T)();
        
        static if(is(T == bool))
        {
            this.m_value = [v];
        }
        else static if(is(T == string))
        {
            this.m_value = cast(ubyte[])(v ~ '\0');
        }
        else static if(is(T == wstring))
        {
            this.m_value = cast(ubyte[])(v.to!string() ~ '\0');
        }
        else static if(is(T == int))
        {
            this.m_value = [0, 0, 0, 0];
            this.m_value.write!uint(v, 0);
        }
        else static if(is(T == float))
        {
            this.m_value = [0, 0, 0, 0, 0, 0, 0, 0];
            this.m_value.write!double(v, 0);
        }
    }
    
    public bool isBinary() const pure nothrow @safe @nogc
    {
        return this.m_type == DbType.Bool || this.m_type == DbType.Int || this.m_type == DbType.Float8;
    }

    @property
    public ubyte[] value() pure nothrow @safe @nogc
    {
        return this.m_value;
    }
}

