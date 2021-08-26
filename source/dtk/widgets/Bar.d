/++
ToolBar should/can be both used for buttons and menus
+/
module dtk.widgets.Bar;

// TODO: decide, whatever I need one class for menu and tool bars, or different
// classes for each

import std.typecons;

import dtk.interfaces.ContainerableWidgetI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.types.Size2D;

import dtk.widgets.Widget;
import dtk.widgets.mixins;

/++
Test documentation
+/
class Bar : Widget, ContainerableWidgetI
{
    private
    {
        ContainerableWidgetI[] _children;
    }


}
