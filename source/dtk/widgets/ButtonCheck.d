module dtk.widgets.ButtonCheck;

import std.stdio;

import dtk.types.EventMouse;

import dtk.widgets;

class ButtonCheck : Button
{
    this()
    {
        setFocusable(true);
    }

    public bool checked;

    override bool on_mouse_click_internal(EventMouse* event)
    {
        writeln("ButtonCheck click");
        checked = !checked;
        redraw();
        return false;
    }

    override bool on_mouse_down_internal(EventMouse* event)
    {
        auto f = getForm();
        if (f !is null){
            f.focusTo(this);
        }

        writeln("ButtonCheck down");
        redraw();
        return false;
    }

    override bool on_mouse_up_internal(EventMouse* event)
    {
        writeln("ButtonCheck up");
        return false;
    }

}
