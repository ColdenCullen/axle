module core.aobject;
import core.ascope;
public import core.atype;

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
