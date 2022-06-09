module dtk.types.Property;

// TODO: move Property to miscs

// TODO: Property requires clarification and determination

// import std.stdio;

// public import dtk.types.Property_mixins;
public import dtk.types.Property_prefabs;

import core.sync.mutex;
import std.exception;

import observable.signal;

/* import observable.signal.SignalConnection;  */

import dtk.miscs.signal_tools;
import dtk.miscs.recursionGuard;

enum PropertyWhatToReturnIfValueIsUnset
{
    defaultValue,
    initValue,
    typeInitValue
}

/++
TODO: notes is outdated. need to update

NOTE: no 'null' state - use unset for this

NOTE: isDefault() function will return true only if previously reset()
called and no ant set() called in between.

NOTE: getting default value (using getDefault()) and using this value with
set() will not reset Property to default state. only reset() function resets
Property to default state; +/
struct PropertySettings(T)
{
    // TODO: decide what to do with this. needs fixing
    /* T init_value = T.init;
    T default_value = T.init; /// value, to which variable is set on reset() call */

    T init_value;
    T default_value; /// value, to which variable is set on reset() call

    bool initially_value_is_default = true;
    bool initially_value_is_unset = true;
    bool default_is_unset = false; // if reset() called, property becomes unset
    /* alias resetting_value_makes_it_unset = default_is_unset; */

    // TODO: complete this
    bool setting_to_default_value_makes_property_reset = false;
    bool setting_to_default_value_makes_property_unset = false;

    bool on_unset_also_reset = false;

    // bool variable_define = true;
    // bool variable_private = true;

    bool gettable = true; /// define function to get value
    bool settable = true; /// define function to set value
    bool resettable = true; /// define function to reset value to default
    bool unsettable = false; /// value can have 'unset' state. also defines unset() function.

    bool recursiveChangeProtection = true;
    bool recursiveChangeDebugWarn = false;
    bool recursiveChangeException = true;

    PropertyWhatToReturnIfValueIsUnset whatToReturnIfUnset = PropertyWhatToReturnIfValueIsUnset
        .typeInitValue;
}

// class Property(alias T1, alias T2 = PropertySettings!T1, T2 settings)
class Property(alias T1, alias T2 = PropertySettings!T1)
{
    T2 settings;

    private T1 variable;

    private
    {
        bool value_is_unset;
        bool value_is_default;
    }

    public
    {
        Signal!() onBeforeGet;
        Signal!() onAfterGet;

        Signal!(T1, T1) onBeforeSet;
        Signal!(T1, T1) onAfterSet;

        Signal!(T1, T1) onBeforeReset;
        Signal!(T1, T1) onAfterReset;

        Signal!(T1, T1) onBeforeUnset;
        Signal!(T1, T1) onAfterUnset;

        Signal!(T1, T1) onBeforeChanged;
        Signal!(T1, T1) onAfterChanged;
    }

    private
    {
        bool changeCallInProgress;
        // TODO: maybe this have to be shared or __gshared
        Mutex changeCallMutex;
    }

    // @disable this(this);
    this(T2 settings)
    {
        this.settings = settings;
        this.variable = settings.init_value;
        this.value_is_unset = settings.initially_value_is_unset;
        this.value_is_default = settings.initially_value_is_default;
        changeCallMutex = new Mutex();
    }

    private void recursiveChangeReaction()
    {
        debug if (settings.recursiveChangeDebugWarn)
        {
            import std.stdio;

            writeln("recursive change detected: ", collectException({
                    throw new Exception("recursion");
                }()));
        }

        if (settings.recursiveChangeException)
        {
            throw new Exception("recursion");
        }
    }

    private void reset_priv()
    {
        if (!settings.resettable)
        {
            throw new Exception("not resettable");
        }

        T1 old_value;
        T1 new_value;

        old_value = variable;
        new_value = getUnsetValue();

        onBeforeChanged.emit(old_value, new_value);
        scope (success)
            onAfterChanged.emit(old_value, new_value);
        onBeforeReset.emit(old_value, new_value);
        scope (success)
            onAfterReset.emit(old_value, new_value);

        variable = settings.default_value;

        value_is_default = true;
        if (settings.unsettable)
        {
            if (settings.default_is_unset)
            {
                value_is_unset = true;
            }
        }
    }

    void reset()
    {
        if (settings.recursiveChangeProtection)
        {
            recursionGuard(changeCallInProgress, changeCallMutex, delegate void() {
                recursiveChangeReaction();
            }, &reset_priv,);
        }
        else
        {
            reset_priv();
        }
    }

    bool isDefault()
    {
        return value_is_default;
    }

    private void unset_priv()
    {
        if (!settings.unsettable)
        {
            throw new Exception("not unsettable");
        }

        T1 old_value;
        T1 new_value;

        old_value = variable;
        new_value = getUnsetValue();

        onBeforeChanged.emit(old_value, new_value);
        scope (success)
            onAfterChanged.emit(old_value, new_value);
        onBeforeUnset.emit(old_value, new_value);
        scope (success)
            onAfterUnset.emit(old_value, new_value);

        value_is_unset = true;

        if (settings.default_is_unset)
        {
            value_is_default = true;
        }

        if (settings.on_unset_also_reset)
        {
            if (settings.resettable)
            {
                reset_priv();
            }
        }

    }

    void unset()
    {
        if (settings.recursiveChangeProtection)
        {
            recursionGuard(changeCallInProgress, changeCallMutex, delegate void() {
                recursiveChangeReaction();
            }, &unset_priv,);
        }
        else
        {
            unset_priv();
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

    // NOTE: this must be defined anyway, because it can be used also for
    //       getting default value
    // TODO: this, probably, have to be reworked
    T1 getUnsetValue()
    {
        final switch (settings.whatToReturnIfUnset)
        {
        case PropertyWhatToReturnIfValueIsUnset.initValue:
            return settings.init_value;
        case PropertyWhatToReturnIfValueIsUnset.defaultValue:
            return settings.default_value;
        case PropertyWhatToReturnIfValueIsUnset.typeInitValue:
            static if (is(T1 == class))
            {
                return cast(T1) null;
            }
            else
            {
                return T1.init;
            }
        }
    }

    T1 get()
    {
        if (!settings.gettable)
        {
            throw new Exception("not unsettable");
        }

        onBeforeGet.emit();
        scope (success)
            onAfterGet.emit();

        T1 ret = settings.default_value;

        if (settings.unsettable && value_is_unset)
        {
            ret = getUnsetValue();
        }
        else
        {
            ret = variable;
        }

        return ret;
    }

    private void set_priv(T1 new_value)
    {
        if (!settings.settable)
        {
            throw new Exception("not unsettable");
        }

        T1 old_value;

        old_value = variable;

        onBeforeChanged.emit(old_value, new_value);
        scope (success)
            onAfterChanged.emit(old_value, new_value);
        onBeforeSet.emit(old_value, new_value);
        scope (success)
            onAfterSet.emit(old_value, new_value);

        variable = new_value;

        if (settings.resettable)
        {
            value_is_default = false;
        }
        if (settings.unsettable)
        {
            value_is_unset = false;
        }

        if (settings.resettable)
        {
            if (settings.setting_to_default_value_makes_property_reset
                    && new_value == settings.default_value)
            {
                reset_priv();
            }
        }
        if (settings.unsettable)
        {
            if (settings.setting_to_default_value_makes_property_unset
                    && new_value == settings.default_value)
            {
                unset_priv();
            }
        }
    }

    void set(T1 new_value)
    {
        assert(this !is null);
        if (settings.recursiveChangeProtection)
        {
            recursionGuard(changeCallInProgress, changeCallMutex, delegate void() {
                recursiveChangeReaction();
            }, &set_priv, new_value);
        }
        else
        {
            set_priv(new_value);
        }
    }

}

mixin template Property_forwarding(T, string property, string new_suffix, bool super_forward)
{
    // ["get", "set", "reset", "unset", "isDefault", "isUnset"]

    // TODO: refactor this
    import std.format;

    import observable.signal;

    static assert(__traits(identifier, property) != "");

    static if (!super_forward)
    {
        mixin(q{
   				T get%1$s()
   				{
   					return this.%2$s.get();
   				}
   			}.format(new_suffix, property));
    }
    else
    {
        mixin(q{
   				override T get%1$s()
   				{
   					return super.get%1$s();
   				}
   			}.format(new_suffix));
    }

    static foreach (func; ["set", "reset", "unset"])
    {
        static if (func == "set")
        {
            static if (!super_forward)
            {
                mixin(q{
    					typeof(this) %1$s%2$s(T x) {
    						this.%3$s.%1$s(x);
    						return this;
    					}
    				}.format(func, new_suffix, property));
            }
            else
            {
                override mixin(q{
    					typeof(this) %1$s%2$s(T x) {
    						super.%1$s%2$s(x);
    						return this;
    					}
    				}.format(func, new_suffix));
            }
        }
        else
        {
            static if (!super_forward)
            {
                mixin(q{
    					typeof(this) %1$s%2$s() {
    						this.%3$s.%1$s();
    						return this;
    					}
    				}.format(func, new_suffix, property));
            }
            else
            {
                override mixin(q{
    					typeof(this) %1$s%2$s() {
    						super.%1$s%2$s();
    						return this;
    					}
    				}.format(func, new_suffix));
            }
        }
    }

    static foreach (func; ["isDefault", "isUnset", "isSet"])
    {
        static if (!super_forward)
        {
            mixin(q{
    				bool %1$s%2$s() {
    					return this.%3$s.%1$s();
    				}
    			}.format(func, new_suffix, property));
        }
        else
        {
            mixin(q{
    				override bool %1$s%2$s() {
    					return super.%1$s%2$s();
    				}
    			}.format(func, new_suffix));
        }
    }

    // =========== signals ===========

    static foreach (v; ["onBeforeGet", "onAfterGet",])
    {
        static if (!super_forward)
        {
            mixin(q{
    				SignalConnection connectTo%2$s_%1$s(void delegate() nothrow cb)
    				{
    					import observable.signal;
    					SignalConnection conn;
    					this.%3$s.%1$s.socket.connect(conn, cb);
    					// this.%3$s.property_cc.add(conn);
    					return conn;
    				}
    			}.format(v, new_suffix, property));
        }
        else
        {
            mixin(q{
    				override SignalConnection connectTo%2$s_%1$s(void delegate() nothrow cb)
    				{
    					return super.connectTo%2$s_%1$s(cb);
    				}
    			}.format(v, new_suffix));
        }
    }

    static foreach (v; [
            "onBeforeSet", "onAfterSet", "onBeforeReset", "onAfterReset",
            "onBeforeUnset", "onAfterUnset", "onBeforeChanged", "onAfterChanged",
        ])
    {
        static if (!super_forward)
        {
            mixin(q{
    				SignalConnection connectTo%2$s_%1$s(void delegate(T old_value, T new_value) nothrow cb)
    				{
    					import observable.signal;
    					SignalConnection conn;
    					this.%3$s.%1$s.socket.connect(conn, cb);
    					return conn;
    				}
    			}.format(v, new_suffix, property));
        }
        else
        {
            mixin(q{
    				override SignalConnection connectTo%2$s_%1$s(void delegate(T old_value, T new_value) nothrow cb)
    				{
    					return super.connectTo%2$s_%1$s(cb);
    				}
    			}.format(v, new_suffix));
        }
    }
}

// TODO: add new unittests

struct PropSetting
{
    string mode;
    string type;
    string var_name;
    string title_name;
    string default_value;
}

mixin template mixin_multiple_properties_define(PropSetting[] settings)
{
    import std.format;

    static foreach (v; settings)
    {
        mixin(q{
    			private {
    				Property!(%1$s) %2$s;
    			}
    		}.format(v.type, v.var_name,));
    }
}

string mixin_multiple_properties_inst(const PropSetting[] settings)
{
    import std.format;

    string ret;

    foreach (v; settings)
    {
        if (v.mode == "gs_w_d")
        {
            ret ~= q{
				this.%2$s = makeProperty_gs_w_d!(%1$s)(%3$s);
			}.format(v.type, v.var_name, v.default_value,);
        }
        else if (v.mode == "gs_w_d_nrp")
        {
            ret ~= q{
				this.%2$s = makeProperty_gs_w_d_nrp!(%1$s)(%3$s);
			}.format(v.type, v.var_name, v.default_value,);
        }
        else if (v.mode == "gsu" || v.mode == "gs" || v.mode == "gsun")
        {
            ret ~= q{
				this.%3$s = makeProperty_%1$s!(%2$s)();
			}.format(v.mode, v.type, v.var_name,);
        }
        else
        {
            throw new Exception("invalid PropSetting.mode value");
        }
    }
    return ret;
}

// on super_forward
// from Dlang interface documentation:
//           A reimplemented interface must implement all the interface
//           functions, it does not inherit them from a super class.
// this mixin is to /forward/ properties in widgets
mixin template mixin_multiple_properties_forward(PropSetting[] settings, bool super_forward)
{
    import std.format;

    static foreach (v; settings)
    {
        mixin(q{
				mixin Property_forwarding!(%1$s, "%2$s", "%3$s", %4$s);
			}.format(v.type, v.var_name, v.title_name, super_forward));
    }
}
