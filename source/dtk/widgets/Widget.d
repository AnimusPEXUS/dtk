module dtk.widgets.Widget;

import std.stdio;
import std.conv;

import dtk.interfaces.WidgetI;

import dtk.types.Property;
import dtk.types.Property_mixins;

import dtk.types.Size;
import dtk.types.Point;

import dtk.widgets.WidgetLocator;
import dtk.widgets.Form;

class Widget : WidgetI
{
    private {
        mixin Property_gsu!(WidgetI, "parent");
        /* mixin Property_gsu!(WidgetLocator, "widget_locator"); */
        /* mixin Property_gs!(Size, "minimal_size"); */
        /* mixin Property_gs!(Size, "maximal_size"); */

        // NOTE: this should always be a part of Widget and so should not
        //       be created with Property or it's mixins
    }

    public {
        WidgetLocator locator;
    }

    mixin Property_forwarding!(WidgetI, parent, "Parent");
    /* mixin Property_forwarding!(WidgetLocator, widget_locator, "WidgetLocator"); */
    /* mixin Property_forwarding!(Size, minimal_size, "MinimalSize"); */
    /* mixin Property_forwarding!(Size, maximal_size, "MaximalSize"); */

    /* this()
    {
        widget_locator = new WidgetLocator;
    } */

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

    // called by parrent to indicate the event of it's resizing;
    /* void event_parentResized(); // todo: is this needed? */
    // called if this widget is resized
    /* void event_resized(); */

    /* void event_pointerEnter();
    void event_pointerLeave();
    void event_tabEnter();
    void event_tabLeave();
    void event_press();
    void event_depress();
    void event_click();
    void event_dblclick();
    void event_textentry(); */

    void event_mouse();
    void event_keyboard();

    // NOTE: this function final only for limited period of time.
    //       users should be allowed to override this redraw() function
    final void redraw() {
        Form form = this.getForm();
        if (form is null)
        {
            writeln("error: redraw() function couldn't get Form. this is: ", this);
            return;
        }

        auto theme = form.getTheme();
        auto ds = form.getDrawingSurface();

        static foreach (v; ["Form"])
        {
            {
                mixin(v~" widget = cast("~v~") this;");
                /* __traits(toType, v) widget = cast(__traits(toType, v)) this; */
                if (widget !is null)
                {
                    (__traits(getMember, theme, "draw"~v))(ds, widget);
                }
            }
        }

        writeln("TODO: redraw() function does not supports "~ to!string(this));
    }
}
