module dpgsql.Entity;

interface IEntity
{
    
}

template Entity(T)
{
    protected EntityManager m_em;

    public this()
    {
        this.m_em = EntityManager.getInstance();
    }
    
    public void update()
    {
        this.m_em.getRepository!T().update(cast(T)this);
    }
    
    public int insert()
    {
        return this.m_em.getRepository!T().insert(cast(T)this);
    }
    
    public void beforeUpdate()
    {

    }

    public void afterUpdate()
    {

    }

    public void beforeInsert()
    {

    }

    public void afterInsert()
    {

    }

    //pragma(msg, genEntityProperties!(T));
    mixin(genEntityProperties!(T));
}
