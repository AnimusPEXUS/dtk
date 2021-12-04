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
            auto isunset = this.isUnsetChild(); // __traits(getMember, this, "isUnsetChild")();
            if (isunset)
            {
                return tuple(cast(WidgetI)this, local_x, local_y);
            }

            WidgetI c = this.getChild();
            if (c is null)
            {
                return tuple(cast(WidgetI)this, local_x, local_y);
            }

            auto c_pos = c.getPosition();
            auto c_size = c.getSize();

            if (
            	x >= c_pos.x && x <= (c_pos.x + c_size.width) && y >= c_pos.y
                    && y <= (c_pos.y + c_size.height))
            {
                return c.getWidgetAtPosition(Position2D(x - c_pos.x, y - c_pos.y));
            }
        }

        // if this have many children - search the right one and work with it
        static if (__traits(hasMember, this, "getChildren"))
        {

            auto children = this.getChildren();
            if (children.length == 0)
            {
                return tuple(cast(WidgetI)this, local_x, local_y);
            }

            // TODO: optimize for visible part
            foreach (c; children)
            {
                auto c_pos = c.getPosition();
                auto c_size = c.getSize();

                if (x >= c_pos.x && x <= (c_pos.x + c_size.width) && y >= c_pos.y
                        && y <= (c_pos.y + c_size.height))
                {
                    return c.getWidgetAtPosition(Position2D(x - c_pos.x, y - c_pos.y));
                }
            }

        }

        return tuple(cast(WidgetI)this, local_x, local_y);
    }
}

