#ifndef __AXLE_SCOPE
#define __AXLE_SCOPE

#include <unordered_map>
#include <type_traits>

#include "Member.h"

NAMESPACE_AXLE

class Scope
{
public:
	static Scope		Global;
	typedef std::unordered_map<aString, Member*> MemberMap;

	Scope( Scope* parentScope ) : parent( parentScope ) { }

	template<typename T>
	T*					CreateMember( aString name )
	{
		static_assert( std::is_base_of<Member, T>::value, "Template parameter must extend Member." );

		auto newMember = new T( this );
		members[ name ] = newMember;
		return newMember;
	}

	Member*				GetMember(  aString name ) { return GetMember<Member>( name ); }
	template<typename T>
	T*					GetMember( aString name )
	{
		static_assert( std::is_base_of<Member, T>::value, "Template parameter must extend Member." );

		auto itr = members.find( name );

		if( itr != end( members ) )
			return static_cast<T*>( itr->second );
		else if( parent != nullptr )
			return parent->GetMember<T>( name );
		else
			return nullptr;
	}

protected:
	MemberMap			members;
	Scope*				parent;
};

END_NAMESPACE

#endif//__AXLE_SCOPE
