module core.ascope;
import core.aobject;

class aScope : aObject
{
public static
{
	aScope Global;

	this()
	{
		type = new aType( typeid(aScope) );
		Global = new aScope( null );
	}
}

public:
	this( aScope parentScope )
	{
		parent = parentScope;
	}

	T GetMember( T = aObject )( string name )
	{
		T found = members[ name ];

		if( found != null )
			return cast(T)( found );
		else if( parent != null )
			return parent.GetMember!T( name );
		else
			return null;
	}

	T CreateMember( T )( string name )
	{
		auto newMember = new T( this );
		members[ name ] = newMember;
		return newMember;
	}

protected:
	aScope				parent;

	unittest
	{
		assert( aScope.Type.className == "aScope" );
	}
}
