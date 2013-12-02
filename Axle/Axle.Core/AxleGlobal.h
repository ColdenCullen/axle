#ifndef __AXLE_CLOBAL
#define __AXLE_CLOBAL

#include <cstdint>
#include <string>

#define MAP_TYPE(newType, oldType) typedef oldType newType;

MAP_TYPE( aByte,	uint8_t );
MAP_TYPE( aInt,		int32_t );
MAP_TYPE( aUInt,	uint32_t );
MAP_TYPE( aFloat,	float );
MAP_TYPE( aString,	std::string );

#undef MAP_TYPE

#define USING_NAMESPACE( ns1, ns2 ) namespace ns1 { namespace ns2 {
#define END_USING_NAMESPACE } }

#define SAME_TYPE( t1, t2 ) (typeid(t1).hash_code()==typeid(t2).hash_code())

#endif//__AXLE_CLOBAL
