module dtk.miscs.layoutTools;

import std.format;

import dtk.types.Widget;

import dtk.widgets.Layout;

void alignParentChild(float valign, float halign, Widget parent, Widget child)
in
{
    assert(valign >= 0 && valign <= 1);
    assert(halign >= 0 && halign <= 1);
    assert(parent !is null);
    assert(child !is null);
}
do
{
    bool haveChild = parent.haveChild(child);

    {
        auto l = cast(Layout) parent;
        if (l)
            haveChild |= l.haveLayoutChild(child);
    }

    if (!haveChild)
    {
        throw new Exception("%s not child of %s".format(child, parent));
    }

    auto w = parent.getWidth();
    auto h = parent.getHeight();

    auto cw = child.getWidth();
    auto ch = child.getHeight();

    child.setX(cast(int)((w - cw) * halign));
    child.setY(cast(int)((h - ch) * valign));

    return;
}
