#include <CppUnitTest.h>
#include <CppUnitTestAssert.h>

#include "Class.h"
#include "Variable.h"

using namespace Axle;
using namespace Microsoft::VisualStudio::CppUnitTestFramework;

namespace AxleTests
{
	TEST_CLASS(Classes)
	{
	public:
		/*TEST_METHOD(Create)
		{
		auto className = "TestClass";
		auto varName = "testInt";
		auto value = 5;

		Class* TestClass = Scope::Global.CreateMember<Class>( className );

		auto testInt = TestClass->StaticScope.CreateMember<Variable>( varName );

		testInt->integer = value;

		Assert::AreEqual( value, Scope::Global.GetMember<Class>( className )->StaticScope.GetMember<Variable>( varName )->integer,
		L"Variable test failed." );
		}*/
	};
}