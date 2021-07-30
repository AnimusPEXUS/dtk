module dtk.widgets.Layout;

import std.container;
import std.algorithm;
import std.typecons;
import std.array;

import dtk.interfaces.ContainerableWidgetI;
import dtk.types.Size;
import dtk.types.Property;

import dtk.interfaces.FormI;
import dtk.interfaces.WidgetI;

import dtk.widgets.mixins;
import dtk.widgets.WidgetLocator;
import dtk.widgets.Widget;

enum LayoutOverflowBehavior
{
    Ignore, // do nothing
    Scroll, // show scrollbar
    Clip, // don't draw overflow areas
    Resize, // resize self to fit everything
}

class Layout : Widget
{

    private
    {
        ContainerableWidgetI[] children;

        mixin Property_gs_w_d!(LayoutOverflowBehavior, "vertical_overflow_behavior", LayoutOverflowBehavior.Resize);
        mixin Property_gs_w_d!(LayoutOverflowBehavior, "horizontal_overflow_behavior", LayoutOverflowBehavior.Resize);
    }

    this()
    {
    }

    mixin Property_forwarding!(LayoutOverflowBehavior, vertical_overflow_behavior, "VerticalOverflowBehavior");
    mixin Property_forwarding!(LayoutOverflowBehavior, vertical_overflow_behavior, "HorizontalOverflowBehavior");

    Size calculateSizesAndPositions(Size size)
    {
        return Size();
    }

    size_t getChildrenCount()
    {
        return children.length;
    }

    WidgetI getChildByIndex(size_t index)
    {
        return children[index];
    }

    void removeChild(size_t index)
    {
        children = children[index .. index + 1];
    }

    void removeChild(ContainerableWidgetI widget)
    {
        auto x = children.find(widget);
        children = children[  ] ;
    }

    /* void swapChildren(size_t index0, size_t index1)
    {
        auto z = children[index0];
        children[index0] = children[index1];
        children[index1] = z;
    } */

    void packStart(ContainerableWidgetI widget, bool expand, bool fill)
    {
        if (!children.canFind(widget))
        {
            children = children ~ widget;
            auto WidgetX = cast(Widget) widget;
            WidgetX.locator.setExpand(expand);
            WidgetX.locator.setFill(fill);
        }
    }

    void packEnd(ContainerableWidgetI widget, bool expand, bool fill)
    {
        if (!children.canFind(widget))
        {
            children = widget ~ children;
            auto WidgetX = cast(Widget) widget;
            WidgetX.locator.setExpand(expand);
            WidgetX.locator.setFill(fill);
        }
    }
}
