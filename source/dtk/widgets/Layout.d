module dtk.widgets.Layout;

import std.conv;
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

import dtk.widgets;
import dtk.widgets.mixins;

enum LayoutOverflowBehavior
{
    Ignore, // do nothing
    Scroll, // show scrollbar
    Clip, // don't draw overflow areas
    Resize, // resize self to fit everything
}

enum LayoutDirections : ubyte
{
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

enum LayoutType : ubyte
{
    undefined,
    linearScrolled,
    linearWrapped,
}

/++

    new layouts can be implimented by inheriting Layout and overriding functions
    such as positionAndSizeRequest() and redraw().

    NOTE: Layout should not do any changes to any positions and sizes of it's
    own children.

+/
class Layout : Widget, ContainerableWidgetI
{

    private
    {
        ContainerableWidgetI[] children;

        mixin Property_gs_w_d!(LayoutOverflowBehavior,
                "vertical_overflow_behavior", LayoutOverflowBehavior.Resize);
        mixin Property_gs_w_d!(LayoutOverflowBehavior,
                "horizontal_overflow_behavior", LayoutOverflowBehavior.Resize);
    }

    mixin Property_forwarding!(LayoutOverflowBehavior,
            vertical_overflow_behavior, "VerticalOverflowBehavior");
    mixin Property_forwarding!(LayoutOverflowBehavior,
            vertical_overflow_behavior, "HorizontalOverflowBehavior");

    final ContainerableWidgetI[] getChildren()
    {
        return children;
    }

    final size_t getChildrenCount()
    {
        return children.length;
    }

    final WidgetI getChildByIndex(size_t index)
    {
        return children[index];
    }

    final void removeChild(size_t index)
    {
        children = children[index .. index + 1];
    }

    final void removeChild(ContainerableWidgetI widget)
    {
        assert(false, "todo");
    }

    final void packStart(ContainerableWidgetI widget, bool expand, bool fill)
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

    final void packEnd(ContainerableWidgetI widget, bool expand, bool fill)
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
        this.recalculateChildrenPositionsAndSizes();
    }

    override void recalculateChildrenPositionsAndSizes()
    {
        foreach (size_t counter, v; children)
        {
        	// TODO: what is this?
            // if (v.isUnsetPosition() || v.isUnsetSize())
            // {
                // throw new Exception(to!string(this) ~ " child size or position is not set");
            // }
            v.recalculateChildrenPositionsAndSizes();
        }
    }

    override void redraw()
    {

        super.redraw();

        this.redraw_x(this);
        

        foreach (size_t i, v; children)
        {
            debug writeln(i, " - Layout child redraw()");
            auto p = v.getPosition();
            auto s = v.getSize();
            debug writeln(i, " child position is ", p.x, ",", p.y);
            debug writeln(i, " child size is     ", s.width, ",", s.height);
            v.redraw();
        }
    }

    mixin mixin_getWidgetAtPosition;
}
