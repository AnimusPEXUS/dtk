// MenuItem should be used as a placeholder for other widgets.
// Usual MenuItem is used with Label child and looks like usual menu item with
// text (and all it's common things, like hotkey textual representation)
module dtk.widgets.MenuItem;

import std.typecons;

import dtk.interfaces.ContainerableWidgetI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.types.Size;

import dtk.widgets.mixins;

class MenuItem : ContainerableWidgetI
{
    private
    {
        ContainerableWidgetI _contained;
    }

    mixin mixin_child!("Primary");

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
