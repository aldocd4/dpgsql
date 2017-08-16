module dpgsql.Annotations;

struct Table
{
    public string tableName;
}

struct Column
{
    enum Type
    {
        Default,
        Int,
        String,
        Boolean,
        DateTime,
    }

    public string columnName;
    public Column.Type columnType = Column.Type.Default;
}

struct ForeignKey
{
    enum Type
    {
        Default,
        Int,
        String,
        Boolean,
        DateTime,
    }

    public string columnName;
    public Column.Type columnType = Column.Type.Default;
}

struct OneToMany
{   
    public string foreignKey;
	public FetchMode fetchMode = FetchMode.Eager;
}

struct ManyToOne
{   
    public string foreignKey;
	public FetchMode fetchMode = FetchMode.Eager;
}

struct OneToOne
{
    public string foreignKey;
}

enum FetchMode
{
	Eager,
	Lazy
}
