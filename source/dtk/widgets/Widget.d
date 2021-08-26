module dtk.widgets.Widget;

import std.stdio;
import std.conv;

import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.Property;
import dtk.types.Property_mixins;

import dtk.types.Size2D;
import dtk.types.Position2D;

/* import dtk.widgets.WidgetLocator; */
import dtk.widgets.Form;
import dtk.widgets.WidgetDrawingSurface;

class Widget : WidgetI
{
    private {
        mixin Property_gsu!(WidgetI, "parent");
    }

    // =====^===^===^===== [locator] =====^===^===^===== start

    private {
        mixin Property_gs_w_d!(bool, "vertical_expand", false);
        mixin Property_gs_w_d!(bool, "horizontal_expand", false);
        mixin Property_gs_w_d!(bool, "vertical_fill", false);
        mixin Property_gs_w_d!(bool, "horizontal_fill", false);

        mixin Property_gsu!(Position2D, "position");
        mixin Property_gsu!(Size2D, "size");
        mixin Property_gsu!(Size2D, "minimal_size");
        mixin Property_gsu!(Size2D, "maximal_size");
    }

    // NOTE: those two properties are really a synonym for their //Horizontal//
    //       analogs
    mixin Property_forwarding!(bool, horizontal_expand, "Expand");
    mixin Property_forwarding!(bool, horizontal_fill, "Fill");

    mixin Property_forwarding!(bool, vertical_expand, "VerticalExpand");
    mixin Property_forwarding!(bool, horizontal_expand, "HorizontalExpand");
    mixin Property_forwarding!(bool, vertical_fill, "VerticalFill");
    mixin Property_forwarding!(bool, horizontal_fill, "HorizontalFill");

    mixin Property_forwarding!(Position2D, position, "Position");
    mixin Property_forwarding!(Size2D, size, "Size");
    mixin Property_forwarding!(Size2D, minimal_size, "MinimalSize");
    mixin Property_forwarding!(Size2D, maximal_size, "MaximalSize");


    // =====^===^===^===== [locator] =====^===^===^===== end


    public {
        // NOTE: this (locator) should always be a part of Widget and so should
        //       not be created with Property or it's mixins
        /* WidgetLocator locator; */
    }

    private {
        WidgetDrawingSurfaceShifted _ds;
    }

    mixin Property_forwarding!(WidgetI, parent, "Parent");

    /++ return FormI on which this Widget is placed. returns null in case if
    there is no attached form or if this widget is deeper than 200 levels to
    FormI instance (too deep); +/
    Form getForm() {
        WidgetI w = this;
        ubyte failure_countdown = 200;
    begin:

        if (failure_countdown == 0)
        {
            return null;
        }

        Form ret = cast(Form) w;
        if (ret !is null)
        {
            return ret;
        }

        w = w.getParent();
        if (w is null)
        {
            return null;
        }

        failure_countdown--;

        goto begin;
    }

    DrawingSurfaceI getDrawingSurface() {
        if (_ds is null || !_ds.isValid() )
        {
            _ds = new WidgetDrawingSurfaceShifted(this);
        }
        return _ds;
    }

    void redraw() {

        writeln("Widget::draw() <----------------------------");

        Form form = this.getForm();
        if (form is null)
        {
            writeln("error: redraw() function couldn't get Form. this is: ", this);
            return;
        }

        auto theme = form.getTheme();
        /* auto ds = form.getDrawingSurface(); */

        if (theme is null)
        {
            throw new Exception("theme not set");
        }

        /* if (ds is null)
        {
            throw new Exception("drawing surface not set");
        } */

        /* auto x = __traits(getMember, theme, "draw"~v);
        x(ds, widget);
         */

        static foreach (v; ["Form"])
        {
            {
                mixin(v~" widget = cast("~v~") this;");
                /* __traits(toType, v) widget = cast(__traits(toType, v)) this; */
                if (widget !is null)
                {
                    __traits(getMember, theme, "draw"~v)(widget);
                }
            }
        }

        /* writeln("Widget::draw() <----------------------------");
        writeln("   this widget is Form?:", (cast(Form) this !is null )); */
    }

    void positionAndSizeRequest(Position2D position, Size2D size)
    {
        setPosition(position);
        setSize(size);
    }

    void handle_event_keyboard(EventKeyboard* e)
    {
        writeln("handle_event_keyboard() called ", this);
    }

    void handle_event_mouse(EventMouse* e)
    {
        writeln("handle_event_mouse() called ", this);
    }

    void handle_event_textinput(EventTextInput* e)
    {
        writeln("handle_event_textinput() called ", this);
    }
}
