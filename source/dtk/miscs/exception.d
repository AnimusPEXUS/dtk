module dtk.miscs.exception;

import std.format;


mixin template QE(string N, string P="Exception")
{
    mixin(
        q{
            class %s : %s
            {
                this(string msg, string file = __FILE__, size_t line = __LINE__) {
                    super(msg, file, line);
                }
            }
        }.format(N, P)
        );
}


/*
mixin template QE(alias N, alias P=Exception)
{
    class N : P
    {
        this(string msg, string file = __FILE__, size_t line = __LINE__) {
            super(msg, file, line);
        }
    }
}
*/
