module dtk.types.Property_mixins;

/// with getter, setter and unsetter
mixin template Property_gsu(T, string variable)
{
    mixin("
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

            action_in_case_if_getting_unset_value:
                PropertyActionInCaseIfGettingUnsetValue.throwException,
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
    }()) " ~ variable ~ ";
    ");
}

/// with getter, setter and unsetter. get after unset returns null
mixin template Property_gsun(T, string variable)
{
    mixin("
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

            action_in_case_if_getting_unset_value:
                PropertyActionInCaseIfGettingUnsetValue.returnNull,
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
    }()) " ~ variable ~ ";
    ");
}


/// getter and setter only
mixin template Property_gs(T, string variable)
{
    mixin("
    Property!(T, PropertySettings!T, {
        PropertySettings!T x = {
            gettable: true,
            settable: true,
            unsettable: false,
            resettable: false,

            initially_value_is_default: true,
            initially_value_is_unset: false,

            variable_define: true,
            variable_private: false,

            action_in_case_if_getting_unset_value:
                PropertyActionInCaseIfGettingUnsetValue.throwException,
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
    }()) " ~ variable ~ ";
    ");
}

/// getter and setter only, but with default specifier
mixin template Property_gs_w_d(T, string variable, alias defaultValue)
{
    mixin("
    Property!(T, PropertySettings!T, {
        PropertySettings!T x = {
            init_value : defaultValue,
            default_value: defaultValue,

            gettable: true,
            settable: true,
            unsettable: false,
            resettable: false,

            initially_value_is_default: true,
            initially_value_is_unset: false,

            variable_define: true,
            variable_private: false,

            action_in_case_if_getting_unset_value:
                PropertyActionInCaseIfGettingUnsetValue.throwException,
        };
        return x;
    }()) " ~ variable ~ ";
    ");
}
