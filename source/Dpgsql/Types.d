module dpgsql.Types;

enum DbType : int
{
    Bool = 16,
    Byte = 17,
    Char = 18,
    NAMEOID = 19,
    Long = 20,
    Short = 21,
    INT2VECTOROID = 22,
    Int = 23,
    REGPROCOID = 24,
    Text = 25,
    OIDOID = 26,
    TIDOID = 27,
    XIDOID = 28,
    CIDOID = 29,
    OIDVECTOROID = 30,
    Json = 114,
    Xml = 142,
    PGNODETREEOID = 194,
    PGDDLCOMMANDOID = 32,
    POINTOID = 600,
    LSEGOID = 601,
    PATHOID = 602,
    BOXOID = 603,
    POLYGONOID = 604,
    LINEOID = 628,
    Float = 700,
    Float8 = 701,
    ABSTIMEOID = 702,
    RELTIMEOID = 703,
    TINTERVALOID = 704,
    UNKNOWNOID = 705,
    CIRCLEOID = 718,
    CASHOID = 790,
    MACADDROID = 829,
    INETOID = 869,
    CIDROID = 650,
    INT2ARRAYOID = 1005,
    INT4ARRAYOID = 1007,
    TEXTARRAYOID = 1009,
    OIDARRAYOID = 1028,
    FLOAT4ARRAYOID = 1021,
    ACLITEMOID = 1033,
    CSTRINGARRAYOID = 1263,
    BPCHAROID = 1042,
    Varchar = 1043,
    DATEOID = 1082,
    TIMEOID = 1083,
    Timestamp = 1114,
    TIMESTAMPTZOID = 1184,
    INTERVALOID = 1186,
    TIMETZOID = 1266,
    BITOID = 1560,
    VARBITOID = 1562,
    Numeric = 1700,
    REFCURSOROID = 1790,
    REGPROCEDUREOID = 2202,
    REGOPEROID = 2203,
    REGOPERATOROID = 2204,
    REGCLASSOID = 2205,
    REGTYPEOID = 2206,
    REGROLEOID = 4096,
    REGNAMESPACEOID = 4089,
    REGTYPEARRAYOID = 2211,
    UUIDOID = 2950,
    LSNOID = 3220,
    TSVECTOROID = 3614,
    GTSVECTOROID = 3642,
    TSQUERYOID = 3615,
    REGCONFIGOID = 3734,
    REGDICTIONARYOID = 3769,
    JSONBOID = 3802,
    INT4RANGEOID = 3904,
    RECORDOID = 2249,
    RECORDARRAYOID = 2287,
    CSTRINGOID = 2275,
    ANYOID = 2276,
    ANYARRAYOID = 2277,
    VOIDOID = 2278,
    TRIGGEROID = 2279,
    EVTTRIGGEROID = 3838,
    LANGUAGE_HANDLEROID = 2280,
    INTERNALOID = 2281,
    OPAQUEOID = 2282,
    ANYELEMENTOID = 2283,
    ANYNONARRAYOID = 2776,
    ANYENUMOID = 3500,
    FDW_HANDLEROID = 3115,
    TSM_HANDLEROID = 3310,
    ANYRANGEOID = 3831 
}

/**
 * Returns pgsql Oid from base type
 */
DbType getDbType(T)()
{
    static if(is(T == bool))
    {
        return DbType.Bool;
    }
    else static if(is(T == int))
    {
        return DbType.Int;
    }
    else static if(is(T == long) || is(T == ulong))
    {
        return DbType.Long;
    }
    else static if(is(T == float) || is(T == double))
    {
        return DbType.Float8;
    }
    else return DbType.Text;
}