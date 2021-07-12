// ToolBar should/can be both used for buttons and menus
module dtk.widgets.ToolBar;

import std.typecons;

import dtk.interfaces.ContainerableWidgetI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.types.Size;

import dtk.widgets.mixins;

class ToolBar : ContainerableWidgetI
{
    private
    {
        ContainerableWidgetI[] _children;
    }

    mixin mixin_getWidgetType!"ToolBar";

    mixin mixin_variable!(GetterSetterBothOrNone.getterSetterAndNullable,
            "private", "_parent", "Parent", "WidgetI", "");

    mixin mixin_getForm_from_WidgetI;

    Size calculateSizesAndPositions(Size size)
    {
        return Size();
    }

    void redraw()
    {
    }
}
