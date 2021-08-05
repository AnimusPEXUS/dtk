/++ used to position and size Widget on parent with automatic or manual layout
and positioning. or on widgets with +/

module dtk.widgets.WidgetLocator;

import dtk.interfaces.WidgetI;
/* import dtk.interfaces.WidgetLocatorI; */

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.Property;

import dtk.widgets.Layout;

struct WidgetLocator //  : WidgetLocatorI
{
    private{
        mixin Property_gsu!(WidgetI, "widget");
        /* mixin Property_gsu!(Layout, "layout"); */

        mixin Property_gs_w_d!(bool, "vertical_expand", false);
        mixin Property_gs_w_d!(bool, "horizontal_expand", false);
        mixin Property_gs_w_d!(bool, "vertical_fill", false);
        mixin Property_gs_w_d!(bool, "horizontal_fill", false);

        mixin Property_gsu!(Size2D, "preferred_size");
        mixin Property_gsu!(Position2D, "preferred_local_position");
        mixin Property_gsu!(Size2D, "preferred_minimal_size");
        mixin Property_gsu!(Size2D, "preferred_maximal_size");

        mixin Property_gsu!(Size2D, "calculated_minimal_size");
        mixin Property_gsu!(Size2D, "calculated_maximal_size");
        mixin Property_gs!(Size2D, "calculated_size");
        mixin Property_gs!(Position2D, "calculated_local_position");
        mixin Property_gs!(Position2D, "calculated_form_position");

        /* bool _widget_requested_layout_resize;
        Size2D _widget_layout_resize_request; */
    }

    mixin Property_forwarding!(WidgetI, widget, "Widget");
    /* mixin Property_forwarding!(Layout, layout, "Layout"); */

    // NOTE: those two properties are really a synonym for their //Horizontal//
    //       analogs
    mixin Property_forwarding!(bool, horizontal_expand, "Expand");
    mixin Property_forwarding!(bool, horizontal_fill, "Fill");

    mixin Property_forwarding!(bool, vertical_expand, "VerticalExpand");
    mixin Property_forwarding!(bool, horizontal_expand, "HorizontalExpand");
    mixin Property_forwarding!(bool, vertical_fill, "VerticalFill");
    mixin Property_forwarding!(bool, horizontal_fill, "HorizontalFill");

    mixin Property_forwarding!(Size2D, preferred_size, "PreferredSize");
    mixin Property_forwarding!(Position2D, preferred_local_position, "PreferredLocalPosition");
    mixin Property_forwarding!(Size2D, preferred_minimal_size, "PreferredMinimalSize");
    mixin Property_forwarding!(Size2D, preferred_maximal_size, "PreferredMaximalSize");


    mixin Property_forwarding!(Size2D, calculated_minimal_size, "CalculatedMinimalSize");
    mixin Property_forwarding!(Size2D, calculated_maximal_size, "CalculatedMaximalSize");
    mixin Property_forwarding!(Size2D, calculated_size, "CalculatedSize");
    mixin Property_forwarding!(Position2D, calculated_local_position, "CalculatedLocalPosition");
    mixin Property_forwarding!(Position2D, calculated_form_position, "CalculatedFormPosition");

    this(WidgetI widget)
    {
        this.setWidget(widget);
    }

    /* mixin Property_forwarding!(Layout, layout, "Layout");
    mixin Property_forwarding!(Layout, layout, "Layout");

    mixin Property_forwarding!(Layout, layout, "Layout");
    mixin Property_forwarding!(Layout, layout, "Layout"); */


    /++ request widget to recalculate own size (so it could be gotten throug
    getCalculatedSize()). Widget is supposed to recursively call calculateSize on all it's
    children and return it's own Size2D +/
    Size2D calculateSize(){
        // TODO: todo
        return getCalculatedSize();
    }

    Position2D calculateLocalPosition() {
        // TODO: todo
        return getCalculatedLocalPosition();
    }

    Position2D calculateFormPosition() {
        // TODO: todo
        return getCalculatedFormPosition();
    }

    /* void draw()
    {
        widget.draw();
    } */

}
