module dtk.interfaces.WidgetI;

import dtk.interfaces.FormI;

import dtk.types.Size;

interface WidgetI
{
    WidgetI getParent();
    void setParent(WidgetI widget);
    void nullifyParent();

    /++ return FormI on which this Widget is placed. throws exception in case if
    there is no attached form or if this widget if deeper than 200 in level to
    FormI instance (too deep); +/
    FormI getForm();

    /++ calculate sizes of children (by recursively calling
    calculateSizesAndPositions()) and than calculate own size and return own
    size. size - maximum size, which parent allows this child to resize it self.
    +/
    Size calculateSizesAndPositions(Size size);
    void redraw();
}
