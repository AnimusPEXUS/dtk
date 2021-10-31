/++
Button Widget. used both freely on form or as ToolBar button
there should not be separate radiobutton or checkbutton: this Button class
should be visually transformed to such using it's properties.
+/

module dtk.widgets.Button;

import std.stdio;
import std.typecons;

import dtk.miscs.RadioGroup;
import dtk.interfaces.ContainerableWidgetI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.types.Size2D;
import dtk.types.EventMouse;

import dtk.widgets;
import dtk.widgets.mixins;

/// Button class
class Button : Widget, ContainerableWidgetI
{
    bool button_is_down;

    this()
    {
        setFocusable(true);
    }

    override bool on_mouse_click_internal(EventMouse* event)
    {
        debug writeln("button click");
        return false;
    }

    override bool on_mouse_down_internal(EventMouse* event)
    {
        button_is_down = true;
        auto f = getForm();
        if (f !is null)
        {
            f.focusTo(this);
        }
        debug writeln("button down");
        redraw();
        return false;
    }

    override bool on_mouse_up_internal(EventMouse* event)
    {
        button_is_down = false;
        debug writeln("button up");
        redraw();
        return false;
    }

    override void redraw()
    {
        this.redraw_x(this);
    }

    /* void redraw(alias A1)()
    {
        super.redraw!(A1)();
    } */

}
