module Dpgsql.Reflection;

import std.string;

import Dpgsql.Annotations;

/**
 * Returns all members of entity T for SELECT query
 */
template getTableColumns(T)
{
	string getTableColumnsImpl()
	{
		string names = "";
		
		foreach(i, dummy ; typeof(T.tupleof))
        {
            enum attributes = __traits(getAttributes, T.tupleof[i]);

            foreach(j, UDA; attributes)
            {
                static if(is(typeof(UDA) == Column))
                {
                    enum name = T.tupleof[i].stringof;                    
                    enum type = typeof(T.tupleof[i]).stringof;

                    // We check the type of the column (important for DateTime)
                    static if(UDA.columnType == Column.Type.DateTime)
                    {
                        names ~= format("extract (epoch from %s) as %s,", UDA.columnName, UDA.columnName);
                    }
                    else
                    {
                        names ~= UDA.columnName ~ ',';
                    }
                }
            }
        }

		return names;
	}
	
	enum getTableColumns = getTableColumnsImpl();
}


/**
 * Returns entity T's table name
 */
template getTableName(T)
{
	string getTableNameImpl()
	{
        string tableName;

		enum attributes = __traits(getAttributes, T);
		
		foreach(attribute; attributes)
		{
			static if(is(typeof(attribute) : Table))
			{
				tableName = attribute.tableName;
			}
		}

        tableName = T.stringof.toLower();
		return tableName;
	}
	
	enum getTableName = getTableNameImpl();
}


template genEntityProperties(T)
{
	string genEntityPropertiesImpl()
	{
		string toRet = "";

        foreach(i, dummy ; typeof(T.tupleof))
        {
            enum attributes = __traits(getAttributes, T.tupleof[i]);

            foreach(j, UDA; attributes)
            {
                static if(is(typeof(UDA) == Column))
                {
                    enum name = T.tupleof[i].stringof;                    
                    enum type = typeof(T.tupleof[i]).stringof;
                    
                    toRet ~= format(`
                        @property
                        public %s get%s() pure nothrow @safe @nogc
                        {
                            return this.%s;
                        }

                        @property
                        public void set%s(%s value) pure nothrow @safe @nogc
                        {
                            this.%s = value;
                        }
                    `, type, name.capitalize(), name, name.capitalize(), type, name);
                }					
                else static if(is(typeof(UDA) : JoinColumn))
                {

                }
                else static if(UDA.stringof.startsWith("OneToMany"))
                {
            
                }
            }
		}
			
		return toRet;
	}
	
	enum genEntityProperties = genEntityPropertiesImpl();
}
