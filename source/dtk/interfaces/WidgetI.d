module dtk.interfaces.WidgetI;

import dtk.interfaces.FormI;

import dtk.types.Size;

interface WidgetI
{
    /* bool haveContainer();
    ContainerI getContainer(); */

    /* bool havePadding();
    Offset getPadding();

    bool haveMargin();
    Offset getMargin();

    bool haveAlignment();
    Alignment getAlignment(); */

    /* bool haveVerticalScrolling();
    ScrollingI getVerticalScrolling();

    bool haveHorizontalScrolling();
    ScrollingI getHorizontalScrolling(); */

    /* void calculateChildrenSizes(); // for internal usage */ // note: probably, this function is not needed

    void setParent(WidgetI widget);
    void unsetParent();

    FormI getForm();

    Size calculateSize();
    void calculateChildrenPositions();
    void redraw();
}
