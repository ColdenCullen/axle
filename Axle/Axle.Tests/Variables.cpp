#include <CppUnitTest.h>
#include <CppUnitTestAssert.h>

#include "Scope.h"
#include "Variable.h"

using namespace Axle::Backend;
using namespace Microsoft::VisualStudio::CppUnitTestFramework;

namespace AxleTests
{		
	TEST_CLASS(Variables)
	{
	public:
		TEST_METHOD(Create)
		{
			auto testVar = Scope::Global.CreateMember<Variable>( "testFloat" );

			Assert::AreNotSame( 0, reinterpret_cast<aInt>( testVar ), L"Variable not created." );
		}
	};
}