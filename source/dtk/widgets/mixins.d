module dtk.widgets.mixins;

import std.stdio;

import dtk.widgets;

mixin template mixin_getWidgetAtPosition()
{
	import std.typecons;
	import dtk.types.Position2D;
	
    /// Note: x/y are local to widget the function is running at
    override Tuple!(WidgetI, ulong, ulong) getWidgetAtPosition(Position2D point)
    {
        auto x = point.x;
        auto y = point.y;
        
        ulong local_x;
        ulong local_y;
        {
        	// auto pos = this.getPosition();
        	local_x=x;
        	local_y=y;
        }
        
        // if this have only single child - work with it
        static if (__traits(hasMember, this, "getChild"))
        {
            debug writeln("getting child of ", this);
            /* auto isunset = __traits(getMember, this, "isUnsetChild")(); */
            auto isunset = this.isUnsetChild(); // __traits(getMember, this, "isUnsetChild")();
            if (isunset)
            {
                debug writeln("child of ", this, " is not set");
                return tuple(cast(WidgetI)this, local_x, local_y);
            }

            /* WidgetI c = __traits(getMember, this, "getChild")(); */
            WidgetI c = this.getChild();
            if (c is null)
            {
                debug writeln("child of ", this, " is null");
                return tuple(cast(WidgetI)this, local_x, local_y);
            }

            debug writeln("child of ", this, " is ", c);

            // TODO: what is this?
            // if (c.isUnsetPosition() || c.isUnsetSize())
            // {
                // return tuple(cast(WidgetI)this, local_x, local_y);
            // }

            auto c_pos = c.getPosition();
            auto c_size = c.getSize();

            if (
            	x >= c_pos.x && x <= (c_pos.x + c_size.width) && y >= c_pos.y
                    && y <= (c_pos.y + c_size.height))
            {
                debug writeln("x/y is in ", c);
                return c.getWidgetAtPosition(Position2D(x - c_pos.x, y - c_pos.y));
            }
            else
            {
                debug writeln("x/y is not in ", c);
            }
        }

        // if this have many children - search the right one and work with it
        static if (__traits(hasMember, this, "getChildren"))
        {

            debug writeln("getting children of ", this);
            auto children = this.getChildren();
            if (children.length == 0)
            {
                debug writeln("children of ", this, " is not set");
                return tuple(cast(WidgetI)this, local_x, local_y);
            }

            // TODO: optimize for visible part
            foreach (c; children)
            {
            	// TODO: what is this?
                // if (c.isUnsetPosition() || c.isUnsetSize())
                // {
                    // return tuple(cast(WidgetI)this, local_x, local_y);
                // }

                auto c_pos = c.getPosition();
                auto c_size = c.getSize();

                if (x >= c_pos.x && x <= (c_pos.x + c_size.width) && y >= c_pos.y
                        && y <= (c_pos.y + c_size.height))
                {
                    debug writeln("x/y is in ", c);
                    return c.getWidgetAtPosition(Position2D(x - c_pos.x, y - c_pos.y));
                }
                else
                {
                    debug writeln("x/y is not in ", c);
                }
            }

        }

        debug writeln("returning ", this, " as a child");
        return tuple(cast(WidgetI)this, local_x, local_y);
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

mixin template mixin_widget_set_multiple_properties(PropSetting[] settings)
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
