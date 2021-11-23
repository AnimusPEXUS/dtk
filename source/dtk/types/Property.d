module dtk.types.Property;

// TODO: Property requires clarification and determination

// import std.stdio;

public import dtk.types.Property_mixins;

import dtk.types.Signal;

import observable.signal;

/* import observable.signal.SignalConnection;  */

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

    bool variable_define = true;
    bool variable_private = true;

    bool gettable = true; /// define function to get value
    bool settable = true; /// define function to set value
    bool resettable = true; /// define function to reset value to default
    bool unsettable = false; /// value can have 'unset' state. also defines unset() function.

    PropertyWhatToReturnIfValueIsUnset whatToReturnIfUnset = PropertyWhatToReturnIfValueIsUnset
        .typeInitValue;
}

struct Property(alias T1, alias T2 = PropertySettings!T1, T2 settings)
{
	import observable.signal;
	
    static if (settings.variable_define)
    {
        static if (settings.variable_private)
        {
            private T1 variable = settings.init_value;
        }
        else
        {
            public T1 variable = settings.init_value;
        }
    }

    private
    {
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
        static if (settings.gettable)
        {
            Signal!() onBeforeGet;
            Signal!() onAfterGet;
        }
        static if (settings.settable)
        {
            Signal!(T1, T1) onBeforeSet;
            Signal!(T1, T1) onAfterSet;
        }
        static if (settings.resettable)
        {
            Signal!(T1, T1) onBeforeReset;
            Signal!(T1, T1) onAfterReset;
        }
        static if (settings.unsettable)
        {
            Signal!(T1, T1) onBeforeUnset;
            Signal!(T1, T1) onAfterUnset;
        }

        Signal!(T1, T1) onBeforeChanged;
        Signal!(T1, T1) onAfterChanged;
    }

    @disable this(this);

    static if (settings.resettable)
    {
        void reset()
        {
            T1 old_value;
            T1 new_value;

            static if (settings.variable_define)
            {
                old_value = variable;
                new_value = getUnsetValue();
            }

            onBeforeChanged.emit(old_value, new_value);
            scope (success)
                onAfterChanged.emit(old_value, new_value);
            onBeforeReset.emit(old_value, new_value);
            scope (success)
                onAfterReset.emit(old_value, new_value);

            static if (settings.variable_define)
            {
                value = settings.default_value;
            }
            value_is_default = true;
            static if (settings.unsettable)
            {
                if (settings.default_is_unset)
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
            T1 old_value;
            T1 new_value;

            static if (settings.variable_define)
            {
                old_value = variable;
                new_value = getUnsetValue();
            }

            onBeforeChanged.emit(old_value, new_value);
            scope (success)
                onAfterChanged.emit(old_value, new_value);
            onBeforeUnset.emit(old_value, new_value);
            scope (success)
                onAfterUnset.emit(old_value, new_value);

            static if (settings.variable_define)
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
    
    // NOTE: this must be defined anyway, because it can be used also for 
    //       getting default value
    // TODO: this, probably, have to be reworked
    T1 getUnsetValue()
    {
    	static if (settings.whatToReturnIfUnset == PropertyWhatToReturnIfValueIsUnset.initValue)
    	{
    		return settings.init_value;
    	}
    	static if (settings.whatToReturnIfUnset == PropertyWhatToReturnIfValueIsUnset.defaultValue)
    	{
    		return settings.default_value;
    	}
    	static if (settings.whatToReturnIfUnset == PropertyWhatToReturnIfValueIsUnset.typeInitValue)
    	{
    		return T1.init;
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

            static if (settings.variable_define)
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
                    ret = getUnsetValue();
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
            T1 old_value;

            static if (settings.variable_define)
            {
                old_value = variable;
            }

            onBeforeChanged.emit(old_value, new_value);
            scope (success)
                onAfterChanged.emit(old_value, new_value);
            onBeforeSet.emit(old_value, new_value);
            scope (success)
                onAfterSet.emit(old_value, new_value);

            static if (settings.variable_define)
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

            static if (settings.resettable)
            {
                if (settings.setting_to_default_value_makes_property_reset
                        && new_value == settings.default_value)
                {
                    reset();
                }
            }
            static if (settings.unsettable)
            {
                if (settings.setting_to_default_value_makes_property_unset
                        && new_value == settings.default_value)
                {
                    unset();
                }
            }
        }
    }
}

mixin template Property_forwarding(T, alias property, string new_suffix)
{
    // ["get", "set", "reset", "unset", "isDefault", "isUnset"]

    // TODO: refactor this
    import std.format;

   	import observable.signal;
   	
   	static assert(__traits(identifier, property) != "");
    
    static if (__traits(hasMember, property, "get"))
    {
        mixin(
        	q{
        		T get%1$s()
        		{
        			return this.%2$s.get();
        		}
        	}.format(new_suffix, __traits(identifier, property))
        	);
    }

    static foreach (func; ["set", "reset", "unset"])
    {
    	static if (__traits(hasMember, property, func)) {
    		static if (func == "set")
    		{
    			mixin(
    				q{
    					typeof(this) %1$s%2$s(T x) { 
    						this.%3$s.%1$s(x);
    						return this;
    					}
    				}.format(func, new_suffix, __traits(identifier, property))
    				);
    		} 
    		else 
    		{
    			mixin(
    				q{
    					typeof(this) %1$s%2$s() { 
    						this.%3$s.%1$s();
    						return this;
    					}
    				}.format(func, new_suffix, __traits(identifier, property))
    				);
    		}
    	}
    }
    
    static foreach (func; ["isDefault", "isUnset", "isSet"])
    {
    	static if (__traits(hasMember, property, func)) {
    		mixin(
    			q{
    				bool %1$s%2$s() { 
    					return this.%3$s.%1$s();
    				}
    			}.format(func, new_suffix, __traits(identifier, property))
    			);
    	}
    }

    // =========== signals ===========

    static foreach (v; ["onBeforeGet", "onAfterGet",])
    {
        static if (__traits(hasMember, property, v))
        {
        	
            mixin(
            	q{
            		SignalConnection connectTo%2$s_%1$s(void delegate() nothrow cb)
            		{
            			import observable.signal;
            			SignalConnection conn;
            			this.%3$s.%1$s.socket.connect(conn, cb);
            			// this.%3$s.property_cc.add(conn);
            			return conn;
            		}
            	}.format(v,new_suffix, __traits(identifier, property))
            	);
        }

    }

    static foreach (v; [
            "onBeforeSet", "onAfterSet", "onBeforeReset", "onAfterReset",
            "onBeforeUnset", "onAfterUnset", "onBeforeChanged", "onAfterChanged",
        ])
    {
        static if (__traits(hasMember, property, v))
        {
        	 mixin(
            	q{
            		SignalConnection connectTo%2$s_%1$s(void delegate(T old_value, T new_value) nothrow cb)
            		{
            			import observable.signal;
            			SignalConnection conn;
            			this.%3$s.%1$s.socket.connect(conn, cb);
            			// this.%3$s.property_cc.add(conn);
            			return conn;
            		}
            	}.format(v,new_suffix, __traits(identifier, property))
            	);
        	
             // mixin("void connectTo" ~ new_suffix ~ "_" ~ v ~ "( void delegate(T old_value, T new_value) nothrow  cb) { "
             // ~ "import observable.signal;" ~ "SignalConnection conn;" ~ "this." ~ __traits(identifier,
             // property) ~ "." ~ v ~ ".socket.connect(" ~ "conn," ~ "cb); " ~ "this." ~ __traits(identifier,
             // property) ~ ".property_cc.add(conn);" ~ "}");
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


struct PropSetting
{
    string mode;
    string type;
    string var_name;
    string title_name;
    string default_value;
}

mixin template mixin_install_multiple_properties(PropSetting[] settings)
{
    import std.format;

    static foreach (v; settings)
    {
        static if (v.mode == "gs_w_d")
        {
            mixin(
                q{
                    private {
                        mixin Property_%1$s!(%2$s, "%3$s", %5$s);
                    }

                    mixin Property_forwarding!(%2$s, %3$s, "%4$s");

                }.format(
                    v.mode,
                    v.type,
                    v.var_name,
                    v.title_name,
                    v.default_value,
                    )
                );
        }

        static if (v.mode == "gsu" || v.mode == "gs" || v.mode == "gsun")
        {
            mixin(
                q{
                    private {
                        mixin Property_%1$s!(%2$s, "%3$s");
                    }

                    mixin Property_forwarding!(%2$s, %3$s, "%4$s");

                }.format(
                    v.mode,
                    v.type,
                    v.var_name,
                    v.title_name,
                    )
                );
        }

    }
}
