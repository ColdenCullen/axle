module core.anative;
import core.aobject;
import std.traits;

class aNative( T ) : aObject if( isBasicType!T )
{
public:
	T value;
}
