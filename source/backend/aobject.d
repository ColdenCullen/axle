module backend.aobject;
import backend.ascope;
public import backend.atype;

class aObject
{
public static
{
	this()
	{
		type = new aType( typeid(aObject) );
	}

	@property aType Type() { return type; }
}

public:
	@property aScope ParentScope() { return parent; }

private:
	aObject[ string ] members;
	aScope parent;

	static aType type;
}
