module Test.Item;

import Dpgsql;

import Test.Character;

@Table("item")
class Item : IEntity
{
    @Column("id")
    private int id;

    @Column("character_id")
    private int characterId;

    @ManyToOne("character_id")
    private Character character;

    mixin Entity!(Item);
}