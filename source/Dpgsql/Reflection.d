module Dpgsql.Reflection;

import std.string;
import std.ascii : toUpper;

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

        pragma(msg, "Generating properties for " ~ T.stringof);

        foreach(i, dummy ; typeof(T.tupleof))
        {
            enum attributes = __traits(getAttributes, T.tupleof[i]);

            foreach(j, UDA; attributes)
            {
                static if(is(typeof(UDA) == Column))
                {
                    enum name = T.tupleof[i].stringof;                    
                    enum type = typeof(T.tupleof[i]).stringof;
                    
                    toRet ~= `
                        @property
                        public %TYPE get%VARUPPERCASE%() pure nothrow @safe @nogc
                        {
                            return this.%VARLOWERCASE%;
                        }

                        @property
                        public void set%VARUPPERCASE%(%TYPE value) pure nothrow @safe @nogc
                        {
                            this.%VARLOWERCASE% = value;
                        }
                    `.replace("%TYPE", type)
                    .replace("%VARUPPERCASE%", name[0].toUpper() ~ name[1..$])
                    .replace("%VARLOWERCASE%", name);
                }					
                else static if(is(typeof(UDA) == OneToMany))
                {
                    enum name = T.tupleof[i].stringof;                    
                    enum type = typeof(T.tupleof[i]).stringof;
                    enum realType = type[0..type.stringof.indexOf('[') - 1];
                    
                    // this.m_items = this.m_em.getRepository!Item().findBy(["character_id" : this.m_id.to!string]);
                    toRet ~= `
                        @property
                        public %TYPE%[] get%VARUPPERCASE%()
                        {   
                            if(this.%VARLOWERCASE% == null)
                            {
                                import std.conv : to;                            
                                this.%VARLOWERCASE% = this.m_em.getRepository!%TYPE%().findBy(["%FK%" : this.id.to!string()]);

                                foreach(e; this.%VARLOWERCASE%)
                                {
                                    e.set%CURRENT_T_TYPE%(this);
                                }
                            }
                            return this.%VARLOWERCASE%;
                        }

                        @property
                        public void set%VARUPPERCASE%(%TYPE%[] value) pure nothrow @safe @nogc
                        {
                            this.%VARLOWERCASE% = value;
                        }
                    `.replace("%TYPE%", realType)
                    .replace("%VARUPPERCASE%", name[0].toUpper() ~ name[1..$])
                    .replace("%VARLOWERCASE%", name)
                    .replace("%FK%", UDA.foreignKey)
                    .replace("%CURRENT_T_TYPE%", T.stringof);
                }
                else static if(is(typeof(UDA) == ManyToOne))
                {
                    enum name = T.tupleof[i].stringof;                    
                    enum type = typeof(T.tupleof[i]).stringof;
                    
                    // Will generate :
                    // @Column("character_id")
                    // private int character_id;

                    // this.m_character = this.m_em.getRepository!Item().findBy(this.character_id);
  
                    toRet ~= `
                        @property
                        public %TYPE% get%TYPE%()
                        {   
                            if(this.%VARNAME% is null)
                            {
                                import std.conv : to;                            
                                this.%VARNAME% = this.m_em.getRepository!%TYPE%().find(this.%VARNAME%Id);
                            }
                            return this.%VARNAME%;
                        }

                        @property
                        public void set%TYPE%(%TYPE% value) pure nothrow @safe @nogc
                        {
                            this.%VARNAME% = value;
                            this.%VARNAME%Id= value.getId();
                        }
                    `.replace("%TYPE%", type)
                    .replace("%VARNAME%", name);
                }
            }
        }
            
        return toRet;
    }
    
    enum genEntityProperties = genEntityPropertiesImpl();
}
