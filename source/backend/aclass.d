module backend.aclass;
import backend.ascope;

class aClass : aScope
{
public:
	this( aScope parentScope )
	{
		super( parentScope );
		StaticScope = new aScope( parentScope );
	}

	//aObject CreateInstance( aString name, Scope parentScope )
	//{
	//    aObject inst = parentScope.CreateMember!aObject( name );
	//
	//    foreach( name, member; members )
	//    {
	//        if( SAME_TYPE( *member.second, aVariable ) )
	//        {
	//            auto var = inst.CreateMember!Variable( member.first );
	//            var.integer = static_cast!Variable( member.second ).integer;
	//        }
	//        else if( SAME_TYPE( *member.second, aObject ) )
	//        {
	//            auto var = inst->CreateMember!aObject( member.first );
	//
	//        }
	//    }
	//
	//    return inst;
	//}

	aScope StaticScope;
};