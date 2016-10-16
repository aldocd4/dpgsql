module Dpgsql.EntityManager;

debug import std.stdio;

import Dpgsql.Connection;
import Dpgsql.Command;
import Dpgsql.DataReader;
import Dpgsql.Repository;
import Dpgsql.Singleton;

class EntityManager
{
	mixin Singleton!();

	/// Repositories list
	private IRepository[ClassInfo] m_repositories;

	/// Database connection
	private Connection m_connection;
	
	private this(Connection connection)
	{
		debug writeln("New Entity Manager");
		
		this.m_connection = connection;
	}

	public auto getRepository(T)()
	{
		auto repository = T.classinfo in this.m_repositories;
		
		if(repository is null)
		{
			debug writeln("New repository for " ~ T.stringof);
			
			auto newRepository = new Repository!T(this.m_connection, this);
			this.m_repositories[T.classinfo] = newRepository;
			return newRepository;
		}
		else return cast(Repository!T)*repository;
	}


	@property
	public Connection connection() pure nothrow @safe @nogc
	{
		return this.m_connection;
	}

    @property
	public void connection(Connection value) pure nothrow @safe @nogc
	{
		this.m_connection = value;
	}
}