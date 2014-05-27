import console.scanner;
import std.stdio;

version( unittest )
{
    void main() { }
}
else
{
    void main( string[] args )
    {
        switch( args[ 1 ] )
        {
            case "scanner":
                runTerminal();
                break;
            default:
                writeln( args );
                printHelp();
        }
    }
}

void printHelp()
{

}
