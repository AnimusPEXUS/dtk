module dtk.types.Property;

// TODO: Property requires clarification and determination

// import std.stdio;

public import dtk.types.Property_mixins;

import observable.signal;

/* import observable.signal.SignalConnection;  */

enum PropertyActionInCaseIfGettingUnsetValue
{
    throwException,
    returnDefault,
    returnNull,
}

/++
    NOTE: no 'null' state - use unset for this

    NOTE: isDefault() function will return true only if previously reset()
    called and no ant set() called in between.

    NOTE: getting default value (using getDefault()) and using this value with
    set() will not reset Property to default state. only reset() function resets
    Property to default state; +/
struct PropertySettings(T)
{
    // TODO: decide what to do with this
    /* T init_value = T.init;
    T default_value = T.init; /// value, to which variable is set on reset() call */

    T init_value;
    T default_value; /// value, to which variable is set on reset() call

    bool initially_value_is_default = true;
    bool initially_value_is_unset = true;
    bool default_is_unset = false; // if reset() called, property becomes unset
    alias resetting_value_makes_it_unset = default_is_unset;

    // TODO: complete this
    /* bool setting_to_default_value_makes_property_reset = false;
    bool setting_to_default_value_makes_property_unset = false; */

    bool on_unset_also_reset = false;

    bool variable_define = true;
    bool variable_private = true;

    bool gettable = true; /// define function to get value
    bool settable = true; /// define function to set value
    bool resettable = true; /// define function to reset value to default
    bool unsettable = false; /// value can have 'unset' state. also defines unset() function.

    PropertyActionInCaseIfGettingUnsetValue action_in_case_if_getting_unset_value = PropertyActionInCaseIfGettingUnsetValue
        .throwException;

    bool variable_use_on_set = true; /// actually change variable on set() call
    bool variable_use_on_get = true; /// actually get value from variable on get() call. on false - default is returned
    bool variable_use_on_reset = true;
    bool variable_use_on_unset = true; /// actually change variable on unset() call
}

struct Property(alias T1, alias T2 = PropertySettings!T1, T2 settings)
{

    static if (settings.action_in_case_if_getting_unset_value
            == PropertyActionInCaseIfGettingUnsetValue.returnNull)
    {
        static assert(__traits(compiles, cast(T1) null),
                "trying to use PropertyActionInCaseIfGettingUnsetValue.returnNull, but " ~ __traits(identifier,
                    T1) ~ " can't be null");
    }

    private
    {
        /* PropertySettings!T1 settings; */

        static if (settings.variable_define && settings.variable_private)
        {
            T variable = settings.init_value;
        }

        static if (settings.unsettable)
        {
            bool value_is_unset = settings.initially_value_is_unset;
        }

        static if (settings.resettable)
        {
            bool value_is_default = settings.initially_value_is_default;
        }

    }

    public
    {
        /* T2 settings2 = settings_ct; */

        static if (settings.variable_define && !settings.variable_private)
        {
            T1 variable = settings.init_value;
        }

        static if (settings.gettable)
        {
            Signal!() onBeforeGet;
            Signal!() onAfterGet;
        }

        static if (settings.settable)
        {
            Signal!() onBeforeSet;
            Signal!() onAfterSet;
        }

        static if (settings.resettable)
        {
            Signal!() onBeforeReset;
            Signal!() onAfterReset;
        }

        static if (settings.unsettable)
        {
            Signal!() onBeforeUnset;
            Signal!() onAfterUnset;
        }

        Signal!() onBeforeChanged;
        Signal!() onAfterChanged;

        SignalConnectionContainer propery_cc;
    }

    @disable this(this);

    /* this()
    {
        static if (settings.variable_define)
        {
            variable = settings.init_value;
        }
        static if (settings.unsettable)
        {
            value_is_unset = settings.initially_value_is_unset;
        }
        static if (settings.resettable)
        {
            value_is_default = settings.initially_value_is_default;
        }
    } */

    static if (settings.resettable)
    {
        void reset()
        {
            onBeforeChanged.emit();
            scope (success)
                onAfterChanged.emit();
            onBeforeReset.emit();
            scope (success)
                onAfterReset.emit();

            static if (settings.variable_define && settings.variable_use_on_reset)
            {
                variable = settings.default_value;
            }
            value_is_default = true;
            static if (settings.unsettable)
            {
                if (settings.resetting_value_makes_it_unset)
                {
                    value_is_unset = true;
                }
            }

        }

        bool isDefault()
        {
            return value_is_default;
        }
    }

    static if (settings.unsettable)
    {
        void unset()
        {
            onBeforeChanged.emit();
            scope (success)
                onAfterChanged.emit();
            onBeforeUnset.emit();
            scope (success)
                onAfterUnset.emit();

            static if (settings.variable_define && settings.variable_use_on_unset)
            {
                value_is_unset = true;
            }

            static if (settings.default_is_unset)
            {
                value_is_default = true;
            }

            static if (settings.on_unset_also_reset)
            {
                static if (settings.resettable)
                {
                    reset();
                }
            }

        }

        bool isUnset()
        {
            return value_is_unset;
        }

        bool isSet()
        {
            return !value_is_unset;
        }
    }

    static if (settings.gettable)
    {
        T1 get()
        {

            onBeforeGet.emit();
            scope (success)
                onAfterGet.emit();

            T1 ret = settings.default_value;

            static if (settings.variable_define && settings.variable_use_on_get)
            {
                if ({
                        static if (settings.unsettable)
                        {
                            return value_is_unset;
                        }
                        else
                        {
                            return false;
                        }
                    }())
                {
                    static if (settings.action_in_case_if_getting_unset_value
                            == PropertyActionInCaseIfGettingUnsetValue.throwException)
                    {
                        throw new Exception("value is unset");
                    }
                    static if (settings.action_in_case_if_getting_unset_value
                            == PropertyActionInCaseIfGettingUnsetValue.returnNull)
                    {
                        ret = cast(T1) null;
                    }
                }
                else
                {
                    ret = variable;
                }
            }

            return ret;
        }
    }

    static if (settings.settable)
    {
        void set(T1 new_value)
        {
            onBeforeChanged.emit();
            scope (success)
                onAfterChanged.emit();
            onBeforeSet.emit();
            scope (success)
                onAfterSet.emit();

            static if (settings.variable_define && settings.variable_use_on_set)
            {
                variable = new_value;
            }
            static if (settings.resettable)
            {
                value_is_default = false;
            }
            static if (settings.unsettable)
            {
                value_is_unset = false;
            }
        }
    }
}

mixin template Property_forwarding(T, alias property, string new_suffix,)
{
    // ["get", "set", "reset", "unset", "isDefault", "isUnset"]

    static if (__traits(hasMember, property, "get"))
    {
        mixin("T get" ~ new_suffix ~ "() { return this." ~ __traits(identifier,
                property) ~ ".get(); }");
    }

    static if (__traits(hasMember, property, "set"))
    {
        mixin("typeof(this) set" ~ new_suffix ~ "(T x) { this." ~ __traits(identifier,
                property) ~ ".set(x); return this; }");
    }

    static if (__traits(hasMember, property, "reset"))
    {
        mixin("typeof(this) reset" ~ new_suffix ~ "() { this." ~ __traits(identifier,
                property) ~ ".reset();  return this;  }");
    }

    static if (__traits(hasMember, property, "unset"))
    {
        mixin("typeof(this)  unset" ~ new_suffix ~ "() { this." ~ __traits(identifier,
                property) ~ ".unset();   return this; }");
    }

    static if (__traits(hasMember, property, "isDefault"))
    {
        mixin("bool isDefault" ~ new_suffix ~ "() { return this." ~ __traits(identifier,
                property) ~ ".isDefault(); }");
    }

    static if (__traits(hasMember, property, "isUnset"))
    {
        mixin("bool isUnset" ~ new_suffix ~ "() { return this." ~ __traits(identifier,
                property) ~ ".isUnset(); }");
    }

    static if (__traits(hasMember, property, "isSet"))
    {
        mixin("bool isSet" ~ new_suffix ~ "() { return this." ~ __traits(identifier,
                property) ~ ".isSet(); }");
    }

    // =========== signals ===========

    static foreach (v; [
            "onBeforeGet", "onAfterGet", "onBeforeSet", "onAfterSet",
            "onBeforeReset", "onAfterReset", "onBeforeUnset", "onAfterUnset",
            "onBeforeChanged", "onAfterChanged",
        ])
    {
        static if (__traits(hasMember, property, v))
        {
            mixin("void connectTo" ~ new_suffix ~ "_" ~ v ~ "( void delegate() nothrow  cb) { "
                    ~ "import observable.signal;" ~ "SignalConnection conn;" ~ "this." ~ __traits(identifier,
                        property) ~ "." ~ v ~ ".socket.connect(" ~ "conn," ~ "cb); " ~ "this." ~ __traits(identifier,
                        property) ~ ".propery_cc.add(conn);" ~ "}");
        }

    }
}

unittest
{
    import std.conv;

    {
        auto z = Property!(int, PropertySettingsCT!(int), {
            PropertySettingsCT!int x = {variable_use_on_get: true};
            return x;
        }())({ PropertySettings!int x = {}; return x; }());

        assert(z.isDefault());
        assert(__traits(hasMember, z, "isUnset") == false);
        assert(z.get() == int.init);
        z.set(1);
        assert(z.isDefault() == false);

        {
            auto x = z.get();
            assert(x == 1, to!string(x));
        }
    }

    {
        class X
        {
            public
            {
                auto prop_z = Property!(int, PropertySettingsCT!(int), {
                    PropertySettingsCT!int x = {variable_use_on_get: true};
                    return x;
                }())({ PropertySettings!int x = {}; return x; }());
            }

            mixin Property_forwarding!(int, prop_z, "PropZ");
        }

        auto x = new X();

        assert(__traits(hasMember, x, "getPropZ"));
        assert(x.isDefaultPropZ());
        assert(x.isUnsetPropZ());
        assert(x.getPropZ() == 0);
        assert(!x.isDefaultPropZ());
        assert(!x.isUnsetPropZ());
        x.setPropZ(1);
        assert(x.getPropZ() == 1);

    }

}
