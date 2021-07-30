module dtk.widgets.Image;

import std.typecons;

import dtk.interfaces.ContainerableWidgetI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.types.Size;

import dtk.widgets.Widget;
import dtk.widgets.mixins;

class Image : Widget
{
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
