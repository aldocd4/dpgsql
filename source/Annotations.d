module Dpgsql.Annotations;

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