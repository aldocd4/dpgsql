module Dpgsql;

shared static this()
{
    DerelictPQ.load();
}

public
{
    import derelict.pq.pq;
    
    import Dpgsql.Entity;
    import Dpgsql.Annotations;
    import Dpgsql.EntityManager;
    import Dpgsql.Repository;
    import Dpgsql.Reflection;
    import Dpgsql.QueryBuilder;
    import Dpgsql.SqlException;
    import Dpgsql.Types;
    import Dpgsql.DataReader;
    import Dpgsql.Connection;
    import Dpgsql.Command;
}