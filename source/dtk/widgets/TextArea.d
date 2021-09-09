module dtk.widgets.TextArea;

import std.typecons;

import dtk.types.Size2D;

import dtk.interfaces.ContainerableWidgetI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.widgets.Widget;
import dtk.widgets.mixins;

class TextArea : Widget, ContainerableWidgetI
{
    this()
    {
        setFocusable(true);
        setFocusKeyboardCapture(true);
    }

}
