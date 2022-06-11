module dtk.wm.WindowDecoration;

import dtk.interfaces.WindowI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.types.WindowBorderSizes;

import dtk.laf.chicago98.Chicago98Laf;

import dtk.types.Image;
import dtk.types.Widget;
import dtk.types.Position2D;
import dtk.types.Size2D;

import dtk.widgets.Form;
import dtk.widgets.Button;
import dtk.widgets.TextEntry;
// import dtk.widgets.Image;

// import dtk.signal_mixins.Window;


class WindowDecoration : Form
{
    WidgetChild buttonClose;
    WidgetChild buttonMaximize;
    WidgetChild buttonMinimize;

    WidgetChild caption;

    WidgetChild menuButton;

    Chicago98Laf laf;

	WindowI window;

    this(WindowI window)
    {
		this.window = window;
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
        if (window)
            ret = window.getDrawingSurface();
        return ret;
    }

    void stdWindowLayout(Widget w)
    {
        int formWidth = getWidth();
        int titleItemsTop = 5;
        int buttonWidth = 16;
        int buttonHeight = 14;

        buttonClose.setX(titleItemsTop);
        buttonClose.setY(formWidth - 20);
        buttonClose.setWidth(buttonWidth);
        buttonClose.setHeight(buttonHeight);

        buttonMaximize.setX(titleItemsTop);
        buttonMaximize.setY(buttonClose.getY() - 18);
        buttonMaximize.setWidth(buttonWidth);
        buttonMaximize.setHeight(buttonHeight);

        buttonMinimize.setX(titleItemsTop);
        buttonMinimize.setY(buttonMaximize.getY() - buttonWidth);
        buttonMinimize.setWidth(buttonWidth);
        buttonMinimize.setHeight(buttonHeight);

        caption.setX(titleItemsTop);
        caption.setY(24);
        int captWidth = formWidth - caption.getY() - buttonMinimize.getY() - 5;
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

		auto ds = new Image(w, h);

		laf.drawBewel(ds, Position2D(0, 0), Size2D(w, h), false);

        // TODO: draw caption gradient
		return ds;
    }

}
