/++
ToolBar should/can be both used for buttons and menus
+/
module dtk.widgets.ToolBar;

// TODO: decide, whatever I need one class for menu and tool bars, or different
// classes for each

import std.typecons;

import dtk.interfaces.ContainerableWidgetI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.types.Size;

import dtk.widgets.Widget;
import dtk.widgets.mixins;

/++
Test documentation
+/
class ToolBar : Widget
{
    private
    {
        ContainerableWidgetI[] _children;
    }

    /* mixin mixin_variable!(GetterSetterBothOrNone.getterSetterAndNullable,
            "private", "_parent", "Parent", "WidgetI", ""); */

    /* mixin mixin_getForm_from_WidgetI; */

    Size calculateSizesAndPositions(Size size)
    {
        return Size();
    }

    override void redraw()
    {
    }
}
