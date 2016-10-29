module Test.Character;

import Dpgsql;

import Test.Item;

@Table("character")
class Character : IEntity
{
    @Column("id")
    private int id;

    @Column("name")
    private wstring name;

    @OneToMany("character_id")
    private Item[] items;

    public void beforeInsert()
    {
        import std.stdio;
        writeln("Before insert!");
    }

    public void afterInsert()
    {
        import std.stdio;
        writeln("After insert!");
    }

    mixin Entity!(Character);
}