module dtk.types.Property_prefabs;

import dtk.types.Property;

Property!(T, PropertySettings!(T)) makeProperty_gsu(T)()
{
    PropertySettings!T settings = {
        // init_value : T.init, // note: here must be T.init, not cast(T) null
        // default_value : T.init,

        gettable: true, settable: true, unsettable: true, resettable: false,

        initially_value_is_default: true, initially_value_is_unset: true,
    };

    static if (__traits(compiles, cast(T) null))
    {
        settings.init_value = cast(T) null;
    }
    else
    {
        settings.init_value = T.init;
    }
    settings.default_value = settings.init_value;

    auto ret = new Property!(T)(settings);
    return ret;
}

Property!(T, PropertySettings!(T)) makeProperty_gsun(T)()
{
    PropertySettings!T settings = {
        //init_value : cast(T) null,
        //default_value : cast(T) null,

        gettable: true, settable: true, unsettable: true, resettable: false,

        initially_value_is_default: true, initially_value_is_unset: true,
    };

    static if (is(T == class))
    {
        settings.whatToReturnIfUnset = PropertyWhatToReturnIfValueIsUnset.initValue;
        settings.init_value = cast(T) null;
    }
    else
    {
        static if (__traits(compiles, cast(T) null))
        {
            settings.init_value = cast(T) null;
        }
        else
        {
            settings.init_value = T.init;
        }
    }
    settings.default_value = settings.init_value;

    auto ret = new Property!(T)(settings);
    return ret;
}

Property!(T, PropertySettings!(T)) makeProperty_gs(T)()
{
    PropertySettings!T settings = {
        //init_value : T.init,
        //default_value : T.init,

        gettable: true, settable: true, unsettable: false, resettable: false,

        initially_value_is_default: true,
    };

    static if (__traits(compiles, cast(T) null))
    {
        settings.init_value = cast(T) null;
    }
    else
    {
        settings.init_value = T.init;
    }
    settings.default_value = settings.init_value;

    auto ret = new Property!(T)(settings);
    return ret;
}

Property!(T, PropertySettings!(T)) makeProperty_gs_w_d(T)(T default_value)
{
    PropertySettings!T settings = {
        init_value: default_value, default_value: default_value, gettable: true, settable: true,
        unsettable: false, resettable: false, initially_value_is_default: true,
    };
    auto ret = new Property!(T)(settings);
    return ret;
}

Property!(T, PropertySettings!(T)) makeProperty_gs_w_d_nrp(T)(T default_value)
{
    PropertySettings!T settings = {
        init_value: default_value, default_value: default_value, gettable: true, settable: true, unsettable: false, resettable: false,

        initially_value_is_default: true, recursiveChangeProtection: false,
    };
    auto ret = new Property!(T)(settings);
    return ret;
}
