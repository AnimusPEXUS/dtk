module dtk.types.Property_mixins;

/// with getter, setter and unsetter
mixin template Property_gsu(T, string variable)
{
    import std.format;

    mixin(q{
    Property!(T, PropertySettings!T, {
        PropertySettings!T x = {
            init_value : T.init, // note: here must be T.init, not cast(T) null

            gettable: true,
            settable: true,
            unsettable: true,
            resettable: false,

            initially_value_is_default: true,
            initially_value_is_unset: true,

            variable_define: true,
            variable_private: false,
        };
        static if (__traits(compiles, cast(T)null))
        {
            x.init_value = cast(T) null;
        } else
        {
            x.init_value = T.init;
        }
        x.default_value = x.init_value;
        return x;
    }()) %1$s;
    }.format(variable));
}

/// with getter, setter and unsetter. get after unset returns null
mixin template Property_gsun(T, string variable)
{
    import std.format;

    mixin(q{
    Property!(T, PropertySettings!T, {
        PropertySettings!T x = {
            init_value : cast(T) null,
            default_value : cast(T) null,

            gettable: true,
            settable: true,
            unsettable: true,
            resettable: false,

            initially_value_is_default: true,
            initially_value_is_unset: true,

            variable_define: true,
            variable_private: false,

        };
        static if (__traits(compiles, cast(T)null))
        {
            x.init_value = cast(T) null;
        } else
        {
            x.init_value = T.init;
        }
        x.default_value = x.init_value;
        return x;
    }()) %1$s;
    }.format(variable));
}

/// getter and setter only
mixin template Property_gs(T, string variable)
{
    import std.format;

    mixin(q{
    Property!(T, PropertySettings!T, {
        PropertySettings!T x = {
            init_value : T.init,
            default_value : T.init,

            gettable: true,
            settable: true,
            unsettable: false,
            resettable: false,

            initially_value_is_default: true,

            variable_define: true,
            variable_private: false,
        };
        static if (__traits(compiles, cast(T)null))
        {
            x.init_value = cast(T) null;
        } else
        {
            x.init_value = T.init;
        }
        x.default_value = x.init_value;
        return x;
    }()) %1$s ;
    }.format(variable));
}

/// getter and setter only, but with default specifier
mixin template Property_gs_w_d(T, string variable, alias defaultValue)
{
    import std.format;

    mixin(q{
    Property!(T, PropertySettings!T, {
        PropertySettings!T x = {
            init_value : defaultValue,
            default_value: defaultValue,

            gettable: true,
            settable: true,
            unsettable: false,
            resettable: false,

            initially_value_is_default: true,

            variable_define: true,
            variable_private: false,
        };
        return x;
    }()) %1$s ;
    }.format(variable));
}
