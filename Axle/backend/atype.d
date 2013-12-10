module backend.atype;
import backend.aobject;

class aType : aObject
{
public:
	this( string name )
	{
		className = name;
	}

	string className;
}
