module dtk.widgets.MenuItem;

import std.stdio;
import std.format;

import dtk.types.Property;
import dtk.types.Widget;
import dtk.types.EventForm;
import dtk.types.WindowCreationSettings;

import dtk.widgets.Form;
import dtk.widgets.Menu;
import dtk.widgets.TextEntry;
import dtk.widgets.mixins;

import dtk.miscs.layoutTools;

const auto MenuItemProperties = cast(PropSetting[])[
    PropSetting("gsun", "Menu", "submenu", "Submenu", q{null}),
    // PropSetting("gsun", "Widget", "widget", "Submenu", q{null}),
];

class MenuItem : Widget
{
    mixin mixin_multiple_properties_define!(MenuItemProperties);
    mixin mixin_multiple_properties_forward!(MenuItemProperties, false);
    mixin mixin_Widget_renderImage!("MenuItem");

    this(Widget w = null)
    {
        mixin(mixin_multiple_properties_inst(MenuItemProperties));
        setWidget(w);
        performLayout = delegate void(Widget w1) {
            auto w = cast(MenuItem) w1;
            auto c = w.getWidget();

            if (c)
            {
                debug writeln("MenuItem propagates PL to child");
                c.propagatePerformLayout();
                debug writeln(" [[MenuItem propagates PL to child]]:end");
                auto dw = c.getDesiredWidth();
                auto dh = c.getDesiredHeight();
                debug writeln(" [[MenuItem child desired WxH]]: %sx%s".format(dw, dh));

                setDesiredWidth(dw + 5);
                setDesiredHeight(dh + 5);

                c.setWidth(w.getWidth());
                c.setHeight(w.getHeight());

                // c.propagatePerformLayout();

                //widget.setWidth(getWidth()-5);
                //widget.setHeight(getHeight()-5);
                alignParentChild(0.5, 0.5, this, c);
                debug writeln("MenuItem %sx%sx%sx%s".format(getX(), getY(),
                        getWidth(), getHeight()));
                debug if (c)
                {
                    writeln("	child %sx%sx%sx%s ".format(c.getX(), c.getY(),
                            c.getWidth(), c.getHeight()));
                }
            }
        };
    }

    private
    {
        WidgetChild widget;
    }

    MenuItem setWidget(Widget w)
    {
        if (w is null)
        {
            if (this.widget)
            {
                this.widget.child.setParent(null);
            }
            this.widget = null;
        }
        else
        {
            this.widget = new WidgetChild(this, w);
            w.setParent(this);
            {
                auto w2 = cast(TextEntry) w;
                if (w2)
                {
                    w2.captionMode = true;
                }
            }
        }
        return this;
    }

    Widget getWidget()
    {
        if (widget && widget.child)
            return widget.child;
        return null;
    }

    override WidgetChild[] calcWidgetChildren()
    {
        WidgetChild[] ret;
        if (this.widget)
            ret ~= this.widget;
        return ret;
    }

    override void intMousePressRelease(Widget widget, EventForm* event)
    {
        debug writeln("click");
        // if (onMousePressRelease)
        // onMousePressRelease(event);
        if (isSetSubmenu())
        {
            showSubmenu();
        }
    }

    void showSubmenu()
    {
        int desX;
        int desY;

        auto win = getForm().getWindow();
        auto p = win.getPlatform();
        auto borderSizes = win.getBorderSizes();
        auto pos = calcPosRelativeToForm(getLeftBottomPos());

        desX = pos.x + borderSizes.leftTop.width + win.getX();
        desY = pos.y + borderSizes.leftTop.height + win.getY();

        WindowCreationSettings wcs = {
            title: "Popup",
            x: desX,
            y: desY,
            w: 50,
            h: 50,
            resizable: true,
            // popup_menu: true,
            // borderless: true
        };

        auto w = p.createWindow(wcs);

        w.setDebugName("menu window");

        w.setX(desX);
        w.setY(desY);

        auto f = new Form();
        w.setForm(f);
        f.setMainWidget(getSubmenu());

        f.performLayout = delegate void(Widget w1)
        {
            auto w = cast(Form) w1;
            auto c = w.getMainWidget();
            if (c)
            {
                c.propagatePerformLayout();

                // auto cdx = c.getDesiredX();
                // auto cdy = c.getDesiredY();
                auto cdw = c.getDesiredWidth();
                auto cdh = c.getDesiredHeight();

                // w.setDesiredX(cdx);
                // w.setDesiredY(cdy);
                w.setDesiredWidth(cdw);
                w.setDesiredHeight(cdh);

                c.setWidth(cdw);
                c.setHeight(cdh);

                c.propagatePerformLayout();

                alignParentChild(0.5, 0.5, w, c);
            }

            debug writeln(
                "popup form performLayout:\n",
                "   form size : %sx%s\n".format(getWidth(), getHeight()),
                "   form dsize: %sx%s\n".format(getDesiredWidth(), getDesiredHeight()), !c

                ? "   (no child)"
                : "   child size : %sx%s\n".format(c.getWidth(), c.getHeight())
                ~ "   child dsize: %sx%s\n".format(c.getDesiredWidth(), c.getDesiredHeight())
                );
        };

    }
}
