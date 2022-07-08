module dtk.miscs.signal_tools;

import std.typecons;

public import observable.signal : SignalConnection, SignalConnectionContainer;

// import dtk.types.FormEvent;
// import dtk.types.Position2D;

// import dtk.interfaces.FormI;
// import dtk.interfaces.WidgetI;

// import dtk.widgets.Form;

mixin template mixin_installSignal(
    string name,
    string var_name,
    bool for_interface,
    P...
    )
{
    import std.format;
    import observable.signal;

    static if (!for_interface)
    {
        private
        {
            mixin(q{
                    Signal!(P) %1$s;
                }.format(var_name));
        }
    }

    static if (!for_interface)
    {
        mixin(
            q{
                SignalConnection connectToSignal_%1$s(
                    void delegate(P) nothrow cb
                    )
                {
                    SignalConnection conn;
                    this.%2$s.socket.connect(conn, cb);
                    return conn;
                }

                void emitSignal_%1$s(P...)(P args)
                {
                    this.%2$s.emit(args);
                }
            }.format(name, var_name)
        );
    }
    else
    {
        mixin(q{
                SignalConnection connectToSignal_%1$s( void delegate(P) nothrow cb);
                void emitSignal_%1$s(P...)(P args);
            }.format(name));
    }
}
