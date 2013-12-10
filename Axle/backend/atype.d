module backend.atype;
import backend.aobject;

template Property( string type, string name, string setterAccess = "private", string checkExpr = "true" ) {
	const char[] Property = 
		"private " ~ type ~ " _" ~ name ~ ";\n" ~
		"public @property " ~ type ~ " " ~ name ~ "() { return _" ~ name ~ "; }\n" ~
		setterAccess ~ " @property void " ~ name ~ "( " ~ type ~ " val ) { if( " ~ checkExpr ~ " ) _" ~ name ~ " = val; }\n";
}

class aType : aObject
{
public:
	mixin( Property!( "string", "name" ) );
	mixin( Property!( "aType", "base" ) );

	this( TypeInfo_Class type )
	{
		this.name = type.name;

		if( type.base !is null )
		{
			this.base = new aType( type.base );
		}
	}
}
