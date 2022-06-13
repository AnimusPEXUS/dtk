module dtk.wm.WindowDecoration;

import std.stdio;
import std.format;
import std.typecons;

import dtk.interfaces.LaFI;
import dtk.interfaces.WindowI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.types.WindowBorderSizes;

import dtk.laf.chicago98.Chicago98Laf;

import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.Color;
import dtk.types.Image;
import dtk.types.Widget;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.Property;
import dtk.types.EventForm;

import dtk.widgets.Form;
import dtk.widgets.Button;
import dtk.widgets.TextEntry;
// import dtk.widgets.Image;

// import dtk.signal_mixins.Window;

const auto WindowDecorationProperties = cast(PropSetting[])[
    PropSetting("gsun", "WindowI", "window", "Window", ""),

    PropSetting("gsun", "Widget", "focusedWidget", "FocusedWidget", ""),
    PropSetting("gsun", "Widget", "defaultWidget", "DefaultWidget", ""),
];

class WindowDecoration : Form
{
    mixin mixin_multiple_properties_define!(WindowDecorationProperties);
    mixin mixin_multiple_properties_forward!(WindowDecorationProperties, true);

    WidgetChild buttonClose;
    WidgetChild buttonMaximize;
    WidgetChild buttonMinimize;

    WidgetChild caption;

    WidgetChild menuButton;

    Chicago98Laf laf;

    this(WindowI window)
    {
        setWindow(window);

        laf = new Chicago98Laf();

        buttonClose = new WidgetChild(this, new Button());
        buttonMaximize = new WidgetChild(this, new Button());
        buttonMinimize = new WidgetChild(this, new Button());

        caption = new WidgetChild(this, Label("Title (caption)"));

        menuButton = new WidgetChild(this, new Button());

        performLayout = &stdWindowLayout;

        /* buttonClose.setParent(this);
        buttonMaximize.setParent(this);
        buttonMinimize.setParent(this);
        menuButton.setParent(this); */
    }

    override DrawingSurfaceI getDrawingSurface()
    {
        DrawingSurfaceI ret;
        if (isSetWindow())
            ret = getWindow().getDrawingSurface();
        return ret;
    }

    void stdWindowLayout(Widget w)
    {
        int formWidth = getWidth();
        int titleItemsTop = 5;
        int buttonWidth = 16;
        int buttonHeight = 14;

        buttonClose.setX(formWidth - 20);
        buttonClose.setY(titleItemsTop);
        buttonClose.setWidth(buttonWidth);
        buttonClose.setHeight(buttonHeight);

        buttonMaximize.setX(buttonClose.getX() - 18);
        buttonMaximize.setY(titleItemsTop);
        buttonMaximize.setWidth(buttonWidth);
        buttonMaximize.setHeight(buttonHeight);

        buttonMinimize.setX(buttonMaximize.getX() - buttonWidth);
        buttonMinimize.setY(titleItemsTop);
        buttonMinimize.setWidth(buttonWidth);
        buttonMinimize.setHeight(buttonHeight);

        caption.setX(24);
        caption.setY(titleItemsTop);
        int captWidth = formWidth - caption.getX() - buttonMinimize.getX() - 5;
        if (captWidth < 0)
            captWidth = 0;
        caption.setWidth(captWidth);
        caption.setHeight(buttonHeight);
    }

    override WidgetChild[] calcWidgetChildren()
    {
        WidgetChild[] ret;
        if (this.buttonClose)
            ret ~= this.buttonClose;
        if (this.buttonMaximize)
            ret ~= this.buttonMaximize;
        if (this.buttonMinimize)
            ret ~= this.buttonMinimize;
        if (this.caption)
            ret ~= this.caption;
        return ret;
    }

    WindowBorderSizes getBorderSizes()
    {
        WindowBorderSizes ret;
        ret.leftTop.width = 2;
        ret.leftTop.height = 20;
        ret.rightBottom.width = 2;
        ret.rightBottom.height = 2;
        return ret;
    }

    override Image renderImage()
    {
        auto w = getWidth();
        auto h = getHeight();

        auto ds = cast(DrawingSurfaceI)(new Image(w, h));

        laf.drawBewel(ds, Position2D(0, 0), Size2D(w, h), false);
        ds.drawRectangle(
            Position2D(2,2),
            Size2D(w-4, 18),
            LineStyle(Color(cast(ubyte[3])[0x00, 0x04, 0x83])),
            nullable(FillStyle(Color(cast(ubyte[3])[0x00, 0x04, 0x83])))
            );

        // TODO: draw caption gradient
		return cast(Image) ds;
    }

    override void intMouseMove(Widget widget, EventForm* event)
    {
        debug writeln("mouse movement detected");
    }

    override void intMousePressRelease(Widget widget, EventForm* event)
    {
        auto w = getWindow();
        w.printParams();
    }
}
