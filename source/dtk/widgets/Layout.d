module dtk.widgets.Layout;

import std.stdio;
import std.container;
import std.algorithm;
import std.typecons;
import std.array;

import dtk.interfaces.ContainerableWidgetI;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.Property;

import dtk.interfaces.FormI;
import dtk.interfaces.WidgetI;

import dtk.widgets.mixins;
/* import dtk.widgets.WidgetLocator; */
import dtk.widgets.Widget;

enum LayoutOverflowBehavior
{
    Ignore, // do nothing
    Scroll, // show scrollbar
    Clip, // don't draw overflow areas
    Resize, // resize self to fit everything
}

enum LayoutDirections : ubyte {
    undefined,
    leftToRightTopToBottom,
    leftToRightBottomToTop,
    topToBottomLeftToRight,
    topToBottomRightToLeft,
    rightToLeftTopToBottom,
    rightToLeftBottomToTop,
    bottomToTopLeftToRight,
    bottomToTopRightToLeft,
}

enum LayoutType : ubyte {
    undefined,
    linearScrolled,
    linearWrapped,
}

class Layout : Widget, ContainerableWidgetI
{

    private
    {
        ContainerableWidgetI[] children;

        mixin Property_gs_w_d!(LayoutOverflowBehavior, "vertical_overflow_behavior", LayoutOverflowBehavior.Resize);
        mixin Property_gs_w_d!(LayoutOverflowBehavior, "horizontal_overflow_behavior", LayoutOverflowBehavior.Resize);
    }

    mixin Property_forwarding!(LayoutOverflowBehavior, vertical_overflow_behavior, "VerticalOverflowBehavior");
    mixin Property_forwarding!(LayoutOverflowBehavior, vertical_overflow_behavior, "HorizontalOverflowBehavior");

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
        assert(false, "todo");
    }

    void packStart(ContainerableWidgetI widget, bool expand, bool fill)
    {
        if (!children.canFind(widget))
        {
            children = children ~ widget;
            auto WidgetX = cast(Widget) widget;
            WidgetX.setExpand(expand);
            WidgetX.setFill(fill);
            WidgetX.setParent(this);
        }
    }

    void packEnd(ContainerableWidgetI widget, bool expand, bool fill)
    {
        if (!children.canFind(widget))
        {
            children = widget ~ children;
            auto WidgetX = cast(Widget) widget;
            WidgetX.setExpand(expand);
            WidgetX.setFill(fill);
            WidgetX.setParent(this);
        }
    }

    override void positionAndSizeRequest(Position2D position, Size2D size)
    {
        /* setCalculatedPosition(position);
        setCalculatedSize(size); */
        super.positionAndSizeRequest(position, size);

        uint counter;
        foreach (v; children) {
            v.positionAndSizeRequest(
                Position2D(counter*(20+2),counter*(20+2)),
                Size2D((counter*(20+2)+20), (counter*(20+2)+20))
                );
            counter++;
        }

    }

    override void redraw() {
        super.redraw();
        foreach (size_t i, v; children) {
            writeln(i," - Layout child redraw()");
            v.redraw();
        }
    }
}
