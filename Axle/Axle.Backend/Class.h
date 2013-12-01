#ifndef __AXLE_CLASS
#define __AXLE_CLASS

#include "Member.h"
#include "Scope.h"

USING_NAMESPACE( Axle, Backend )

class Class : public Member, public Scope
{
public:
	template<typename T>
	T*					CreateStaticMember( aString name )
	{
		static_assert( std::is_base_of<Member, T>::value, "Invalid type parameter for CreateMember." );

		T* newMember = new T;
		staticMembers[ name ] = newMember;
		return newMember;
	}

	template<typename T = Member>
	T*					GetStaticMember( aString name )
	{
		auto itr = staticMembers.find( name );

		if( itr != end( staticMembers ) )
			return static_cast<T*>( itr->second );
		else
			return nullptr;
	}

private:
	Scope::MemberMap	staticMembers;
};

END_USING_NAMESPACE

#endif//__AXLE_CLASS
