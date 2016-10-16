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

    mixin Entity!(Character);
}

auto entitManager = EntityManager.getInstance();
entitManager.connection = connection;

auto repo = entitManager.getRepository!Character();

auto character = repo.find(5);
writeln(character.getName());

auto characterHi = repo.findBy(["name": "Coco"])[0];
writeln(characterHi.getName());

character.setName("hi");
character.update(); // or repo.update(character);

writeln(repo.insert(character));
```
