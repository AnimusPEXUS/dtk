module dtk.widgets.Label;

import std.typecons;

import dtk.types.Size;

import dtk.interfaces.ContainerableWidgetI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.widgets.mixins;

class Label : ContainerableWidgetI
{

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
