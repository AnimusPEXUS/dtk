module dtk.widgets.mixins;

import std.stdio;

import dtk.widgets;

mixin template mixin_getWidgetAtVisible()
{
    /// Note: x/y are local to widget the function is running at
    override WidgetI getWidgetAtVisible(Position2D point)
    {
        auto x = point.x;
        auto y = point.y;
        static if (__traits(hasMember, this, "getChild"))
        {
            writeln("getting child of ", this);
            /* auto isunset = __traits(getMember, this, "isUnsetChild")(); */
            auto isunset = this.isUnsetChild(); // __traits(getMember, this, "isUnsetChild")();
            if (isunset)
            {
                writeln("child of ", this, " is not set");
                return this;
            }

            /* WidgetI c = __traits(getMember, this, "getChild")(); */
            WidgetI c = this.getChild();
            if (c is null)
            {
                writeln("child of ", this, " is null");
                return this;
            }

            writeln("child of ", this, " is ", c);

            if (c.isUnsetPosition() || c.isUnsetSize())
            {
                return this;
            }

            auto c_pos = c.getPosition();
            auto c_size = c.getSize();

            if (x >= c_pos.x && x < (c_pos.x + c_size.width) && y >= c_pos.y
                    && y < (c_pos.y + c_size.height))
            {
                writeln("x/y is in ", c);
                return c.getWidgetAtVisible(Position2D(x - c_pos.x, y - c_pos.y));
            }
            else
            {
                writeln("x/y is not in ", c);
            }
        }

        static if (__traits(hasMember, this, "getChildren"))
        {

            writeln("getting children of ", this);
            auto children = this.getChildren();
            if (children.length == 0)
            {
                writeln("children of ", this, " is not set");
                return this;
            }

            // TODO: optimize for visible part
            foreach (c; children)
            {
                if (c.isUnsetPosition() || c.isUnsetSize())
                {
                    return this;
                }

                auto c_pos = c.getPosition();
                auto c_size = c.getSize();

                if (x >= c_pos.x && x < (c_pos.x + c_size.width) && y >= c_pos.y
                        && y < (c_pos.y + c_size.height))
                {
                    writeln("x/y is in ", c);
                    return c.getWidgetAtVisible(Position2D(x - c_pos.x, y - c_pos.y));
                }
                else
                {
                    writeln("x/y is not in ", c);
                }
            }

        }

        writeln("returning ", this, " as a child");
        return this;
    }
}

/* mixin template mixin_widget_redraw_callTheme()
{
    void draw2(){
        writeln("Widget::draw() <---------------------------- ", this);

        Form form = this.getForm();
        if (form is null)
        {
            writeln("error: redraw() function couldn't get Form. this is: ", this);
            return;
        }

        auto theme = form.getTheme();

        if (theme is null)
        {
            throw new Exception("theme not set");
        }

        /* auto v = __traits(identifier, typeof(this)); * /
        /* {
            import std.algorithm;
            assert(!v.canFind("."));
        } * /
        writeln("calling draw"~__traits(identifier, typeof(this)));
        __traits(getMember, theme, "draw"~__traits(identifier, typeof(this)))(this);
    }

} */
