// MenuItem should be used as a placeholder for other widgets.
// Usual MenuItem is used with Label child and looks like usual menu item with
// text (and all it's common things, like hotkey textual representation)
module dtk.widgets.MenuItem;

import std.typecons;

import dtk.interfaces.ContainerableWidgetI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.types.Size2D;

import dtk.widgets.Widget;
import dtk.widgets.mixins;

class MenuItem : Widget, ContainerableWidgetI
{
    private
    {
        ContainerableWidgetI _contained;
    }

}
