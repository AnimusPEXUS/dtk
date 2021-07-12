module dtk.widgets.Layout;

import std.container;
import std.algorithm;
import std.typecons;

import dtk.interfaces.ContainerableWidgetI;
import dtk.types.Size;

import dtk.interfaces.FormI;
import dtk.interfaces.WidgetI;

import dtk.widgets.mixins;

enum LayoutOverflowBehavior
{
    Ignore, // do nothing
    Scroll, // show scrollbar
    Clip, // don't draw overflow areas
    Resize, // resize self to fit everything
}

class Layout : ContainerableWidgetI
{

    private
    {
        Array!ContainerableWidgetI _children;
    }

    this()
    {
        _vertival_overflow_behavior = LayoutOverflowBehavior.Resize;
        _horizontal_overflow_behavior = LayoutOverflowBehavior.Resize;
    }

    mixin mixin_getWidgetType!"Layout";

    mixin mixin_variable!(GetterSetterBothOrNone.getterAndSetter, "private",
            "_vertival_overflow_behavior", "VerticalOverflowBehavior",
            "LayoutOverflowBehavior", "");

    mixin mixin_variable!(GetterSetterBothOrNone.getterAndSetter, "private",
            "_horizontal_overflow_behavior", "HorizontalOverflowBehavior",
            "LayoutOverflowBehavior", "");

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

    size_t getChildrenCount()
    {
        return _children.length;
    }

    ContainerableWidgetI getChildByIndex(size_t index)
    {
        return _children[index];
    }

    void deleteChild(size_t index)
    {
        _children.linearRemove(_children[index .. index + 1]);
    }

    void swapChildren(size_t index0, size_t index1)
    {
        auto z = _children[index0];
        _children[index0] = _children[index1];
        _children[index1] = z;
    }

    void insertChild(size_t index, ContainerableWidgetI item)
    {
        _children.insertAfter(_children[1 .. 2], item);
    }

    void insertChild(ContainerableWidgetI after_this, ContainerableWidgetI item)
    {
        int pos;
        for (int i = 0; i != _children.length; i++)
        {
            if (_children[i] == after_this)
            {
                pos = i;
                break;
            }
        }
        if (pos != -1)
        {
            _children.insertAfter(_children[pos .. pos + 1], item);
        }
    }

    void putChildToStart(ContainerableWidgetI item)
    {
        _children.insert(item);
    }

    void putChildToEnd(ContainerableWidgetI item)
    {
        _children.insertAfter(_children[], item);
    }
}
