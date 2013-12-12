module backend.anative;
import backend.aobject;
import std.traits;

class aNative( T ) : aObject if( isBasicType!T )
{
public:
	T value;
}
