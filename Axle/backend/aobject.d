module backend.aobject;
import backend.ascope;

class aObject
{
public:
	@property aScope ParentScope() { return parent; }

private:
	aObject[ string ] members;
	aScope parent;
}
