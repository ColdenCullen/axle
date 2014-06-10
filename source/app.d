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
        if( args.length == 1 )
        {
            printHelp();
            return;
        }

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
