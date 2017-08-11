module Dpgsql;

shared static this()
{
    DerelictPQ.load();
}

public
{
    import derelict.pq.pq;
    
    import dpgsql.Entity;
    import dpgsql.Annotations;
    import dpgsql.EntityManager;
    import dpgsql.Repository;
    import dpgsql.Reflection;
    import dpgsql.QueryBuilder;
    import dpgsql.SqlException;
    import dpgsql.Types;
    import dpgsql.DataReader;
    import dpgsql.Connection;
    import dpgsql.Command;
}