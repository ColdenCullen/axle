module backend.ascope;
import backend.aobject;

class aScope : aObject
{
public static
{
	aScope Global;

	this()
	{
		Global = new aScope( null );
	}
}

public:
	this( aScope parentScope )
	{
		parent = parentScope;
	}

	T CreateMember( T : aObject )( string name )
	{
		auto newMember = new T( this );
		members[ name ] = newMember;
		return newMember;
	}

	T GetMember( T : aObject = aObject )( string name )
	{
		T found = members[ name ];

		if( found != null )
			return cast(T)( found );
		else if( parent != null )
			return parent.GetMember!T( name );
		else
			return null;
	}

protected:
	aScope				parent;
}
