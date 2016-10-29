dpgsql
======

dpgsql is a basic PostgreSQL client for D language.

## How to use

### Basic query

```d
auto connection = new Connection("user=postgres password=root dbname=hoho port=5432");
connection.open();

auto command = Command(connection, "SELECT * FROM character");
writeln(command.executeScalar());
```

### Data Reader

```d
auto dataReader = command.executeReader();
for (;!dataReader.empty; dataReader.popFront()) 
{
  writeln(dataReader.read!string("name"));
}

// or 
foreach(row; dataReader)
{
	writeln(row);
}
```

### Query Builder

```d
import std.algorithm;
auto qb = QueryBuilder(connection);
writeln(qb.select("name, id").from("character").fetch().filter!(c => c.id > 6));
```

### Entity Manager

```d
import Dpgsql;

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

auto entitManager = EntityManager.getInstance();
entitManager.connection = connection;

auto repo = entitManager.getRepository!Character();

auto character = repo.find(5);
writeln(character.getName());

auto coco = repo.findBy(["name": "Coco"])[0];
writeln(coco.getName());

character.setName("hi");
character.update(); // or repo.update(character);

foreach(i; character.getItems())
{
    writeln(i.getId());
}

writeln(repo.insert(character));
```
