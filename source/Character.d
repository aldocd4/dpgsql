module Test.Character;

import Dpgsql;

@Table("character")
class Character : IEntity
{
    @Column("id")
    private int id;

    @Column("name")
    private wstring name;

    mixin Entity!(Character);
}