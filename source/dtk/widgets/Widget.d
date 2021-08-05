module dtk.widgets.Widget;

import std.stdio;
import std.conv;

import dtk.interfaces.WidgetI;

import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.Property;
import dtk.types.Property_mixins;

import dtk.types.Size2D;
import dtk.types.Position2D;

import dtk.widgets.WidgetLocator;
import dtk.widgets.Form;

class Widget : WidgetI
{
    private {
        mixin Property_gsu!(WidgetI, "parent");
    }

    public {
        // NOTE: this (locator) should always be a part of Widget and so should
        //       not be created with Property or it's mixins
        WidgetLocator locator;
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
