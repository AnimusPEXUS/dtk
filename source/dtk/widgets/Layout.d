module dtk.widgets.Layout;

import std.container;
import std.algorithm;

import dtk.interfaces.ContainerableI;
import dtk.types.Property;

enum LayoutOverflowBehavior
{
    Ignore, // do nothing
    Scroll, // show scrollbar
    Clip, // don't draw overflow areas
    Resize, // resize self to fit everything
}

class Layout : ContainerableI
{
    Property!LayoutOverflowBehavior vertival_overflow_behavior;
    Property!LayoutOverflowBehavior horizontal_overflow_behavior;

    private
    {
        Array!ContainerableI _children;
    }

    this()
    {
        vertival_overflow_behavior = new Property!LayoutOverflowBehavior(
                LayoutOverflowBehavior.Resize);
        horizontal_overflow_behavior = new Property!LayoutOverflowBehavior(
                LayoutOverflowBehavior.Resize);
    }

    size_t getChildrenCount()
    {
        return _children.length;
    }

    ContainerableI getChildByIndex(size_t index)
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

    void insertChild(size_t index, ContainerableI item)
    {
        _children.insertAfter(_children[1 .. 2], item);
    }

    void insertChild(ContainerableI after_this, ContainerableI item)
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

    void putChildToStart(ContainerableI item)
    {
        _children.insert(item);
    }

    void putChildToEnd(ContainerableI item)
    {
        _children.insertAfter(_children[], item);
    }
}
