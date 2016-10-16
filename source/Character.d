module Test.Character;

import Dpgsql.Entity;
import Dpgsql.Annotations;
import Dpgsql.EntityManager;
import Dpgsql.Repository;
import Dpgsql.Reflection;

@Table("character")
class Character : IEntity
{
    @Column("id")
    private int id;

    @Column("name")
    private wstring name;

    mixin Entity!(Character);
}