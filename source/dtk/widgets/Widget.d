module dtk.widgets.Widget;

import std.stdio;
import std.conv;
import std.typecons;

import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.Property;
import dtk.types.Property_mixins;
import dtk.types.MoveT;

import dtk.types.Size2D;
import dtk.types.Position2D;

/* import dtk.widgets.WidgetLocator; */
import dtk.widgets;
import dtk.widgets.WidgetDrawingSurface;

class Widget : WidgetI
{
    private
    {
        mixin Property_gsun!(WidgetI, "parent");
    }

    mixin Property_forwarding!(WidgetI, parent, "Parent");

    // =====v===v===v===== [locator] =====v===v===v===== start

    private
    {
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

    // =====v===v===v===== [info] =====v===v===v===== start

    private
    {
        mixin Property_gs_w_d!(bool, "visible", false);
        mixin Property_gs_w_d!(bool, "enabled", false);
        mixin Property_gs_w_d!(bool, "focusable", false);
        mixin Property_gs_w_d!(bool, "focus_kb_capture", false);
        mixin Property_gs_w_d!(bool, "uses_text_input", false);
        mixin Property_gs_w_d!(MoveT, "move_type", MoveT.none);
    }

    mixin Property_forwarding!(bool, visible, "Visible");
    mixin Property_forwarding!(bool, enabled, "Enabled");
    mixin Property_forwarding!(bool, focusable, "Focusable");
    mixin Property_forwarding!(bool, focus_kb_capture, "FocusKeyboardCapture");
    mixin Property_forwarding!(bool, uses_text_input, "UsesTextInput");
    mixin Property_forwarding!(MoveT, move_type, "MoveType");

    // =====^===^===^===== [info] =====^===^===^===== end

    private
    {
        WidgetDrawingSurfaceShifted _ds;
    }

    // TODO: ensure all subclasses calls for super();
    // NOTE: ensured. init called implicitly by dlang
    this()
    {
        writeln("Widget:init() is called for ", this);
        _ds = new WidgetDrawingSurfaceShifted(this);
        this.connectToParent_onAfterChanged(&onParentChanged);
    }

    void onParentChanged(WidgetI old_v, WidgetI new_v) nothrow
    {
        try
        {
            writeln(this, " parent changed");
        }
        catch (Exception e)
        {
        }
    }

    /++ return FormI on which this Widget is placed. returns null in case if
    there is no attached form or if this widget is deeper than 200 levels to
    FormI instance (too deep); +/
    Form getForm()
    {
        WidgetI w = this;
        Form ret;

        for (byte failure_countdown = cast(byte) 200; failure_countdown != -1; failure_countdown--)
        {

            ret = cast(Form) w;
            if (ret !is null)
            {
                return ret;
            }

            if (w.isUnsetParent())
            {
                return null;
            }

            w = w.getParent();
            if (w is null)
            {
                return null;
            }
        }

        return ret;
    }

    DrawingSurfaceI getDrawingSurface()
    {
        return _ds;
    }

    /* void redraw()
    { */

    /* writeln("Widget::draw() <---------------------------- ", this);

        Form form = this.getForm();
        if (form is null)
        {
            writeln("error: redraw() function couldn't get Form. this is: ", this);
            return;
        }

        auto theme = form.getLaf();

        if (theme is null)
        {
            throw new Exception("theme not set");
        }

        static foreach (v; [
                "Form", "ButtonCheck", "ButtonRadio", "Button", "Layout", "Label"
            ])
        {
            {
                mixin(v ~ " widget = cast(" ~ v ~ ") this;");
                if (widget !is null)
                {
                    writeln("calling draw" ~ v);
                    __traits(getMember, theme, "draw" ~ v)(widget);
                    goto exit;
                }
            }
        }

    exit: */

    /* } */

    void redraw()
    {
        this.redraw_x(this);
    }

    void redraw_x(T)(T new_this)
    {

        /* alias A1 = typeof(new_this); */

        const id = __traits(identifier, new_this);
        const id_t = __traits(identifier, T);

        pragma(msg, "generating redraw_x for ", id_t);

        static if (!is(T == Widget))
        {
            const drawid = "draw" ~ id_t;
            writeln("Widget::draw() <------------------ drawid = ", drawid);

            Form form = new_this.getForm();
            if (form is null)
            {
                writeln("error: redraw() function couldn't get Form. this is: ", this);
                return;
            }

            auto theme = form.getLaf();

            if (theme is null)
            {
                throw new Exception("theme not set");
            }

            static if (!__traits(hasMember, theme, drawid))
            {
                pragma(msg, "theme doesn't have " ~ drawid ~ " function");
                writeln("theme doesn't have " ~ drawid ~ " function");
                return;
            }
            else
            {
                writeln("calling " ~ drawid);
                __traits(getMember, theme, drawid)(new_this);
            }
        }
        else
        {
            writeln("xxxxxxxxxxxxxxxxx Widget doesn't uses themes for drawing");
        }
    }

    /* void redraw()
    {

    } */

    void positionAndSizeRequest(Position2D position, Size2D size)
    {
        writeln("setting ", this, " position to ", position.x, ",", position.y);
        setPosition(position);
        setSize(size);
    }

    void recalculateChildrenPositionsAndSizes()
    {
        return;
    }

    bool handle_event_keyboard(EventKeyboard* e)
    {
        writeln("handle_event_keyboard() called ", this);
        return false;
    }

    bool handle_event_mouse(EventMouse* e)
    {
        writeln("handle_event_mouse() called ", this);
        return false;
    }

    bool handle_event_textinput(EventTextInput* e)
    {
        writeln("handle_event_textinput() called ", this);
        return false;
    }

    WidgetI getWidgetAtVisible(Position2D point)
    {
        return this;
    }

    WidgetI getNextFocusableWidget()
    {
        return null;
    }

    WidgetI getPrevFocusableWidget()
    {
        return null;
    }

    // ==============    Events   ==============

    bool on_mouse_event_internal(EventMouse* event)
    {
        return false;
    }

    bool on_mouse_click_internal(EventMouse* event)
    {
        return false;
    }

    bool on_mouse_down_internal(EventMouse* event)
    {
        return false;
    }

    bool on_mouse_up_internal(EventMouse* event)
    {
        return false;
    }

    bool on_mouse_enter_internal(EventMouse* event)
    {
        return false;
    }

    bool on_mouse_leave_internal(EventMouse* event)
    {
        return false;
    }

    bool on_mouse_over_internal(EventMouse* event)
    {
        return false;
    }

    bool on_keyboard_click_internal(EventKeyboard* event)
    {
        return false;
    }

    bool on_keyboard_down_internal(EventKeyboard* event)
    {
        return false;
    }

    bool on_keyboard_up_internal(EventKeyboard* event)
    {
        return false;
    }

    bool on_keyboard_enter_internal(EventKeyboard* event)
    {
        return false;
    }

    bool on_keyboard_leave_internal(EventKeyboard* event)
    {
        return false;
    }

}
