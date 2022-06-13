module dtk.widgets.Menu;

import std.stdio;
import std.format;

import dtk.types.Property;
import dtk.types.Widget;
import dtk.types.Orientation;

import dtk.miscs.layoutCollection;

import dtk.widgets.Layout;
import dtk.widgets.MenuItem;
import dtk.widgets.mixins;

enum MenuMode : ubyte
{
    bar,
    popup
}

const auto MenuProperties = cast(PropSetting[])[
    PropSetting("gs_w_d", "MenuMode", "mode", "Mode", q{MenuMode.popup}),
    PropSetting("gsu", "Widget", "isSubmenuFor", "IsSubmenuFor", q{null}),
];

Menu MenuBar()
{
    return new Menu(MenuMode.bar);
}

Menu MenuPopup()
{
    return new Menu(MenuMode.popup);
}

class Menu : Widget
{
    mixin mixin_multiple_properties_define!(MenuProperties);
    mixin mixin_multiple_properties_forward!(MenuProperties, false);
    mixin mixin_Widget_renderImage!("Menu");

    private
    {
        WidgetChild layout;
    }

    this(MenuMode mode)
    {
        mixin(mixin_multiple_properties_inst(MenuProperties));
        setMode(mode);
        setLayout(new Layout());
        performLayout = delegate void(Widget w1) {
            auto w = cast(Menu) w1;

            w.propagatePerformLayoutToChildren();

            auto c = w.getLayout();

            final switch (mode)
            {
            case MenuMode.bar:
                if (c)
                {
                    c.setWidth(w.getWidth());
                    c.setHeight(w.getHeight());
                }
                break;
            case MenuMode.popup:
                if (c)
                {
                    auto cdw = c.getDesiredWidth();
                    auto cdh = c.getDesiredHeight();

                    debug writeln("%s %s desired WxH: %sx%s".format(
                        this,
                        c,
                        cdw,
                        cdh
                        )
                        );

                    c.setWidth(cdw);
                    c.setHeight(cdh);

                    w.setDesiredWidth(cdw);
                    w.setDesiredHeight(cdh);

                }
                break;
            }

            debug
            {

                writeln("Menu size: %sx%s".format(w.getWidth(), w.getHeight(),));

                if (c)
                {
                    writeln(
                        "   menu child size: %sx%s".format(
                            c.getWidth(),
                            c.getHeight()
                            )
                        );
                }
            }
        };
    }

    Layout getLayout()
    {
        if (!layout || !layout.child)
            return null;
        return cast(Layout)(layout.child);
    }

    private Menu setLayout(Layout l)
    {
        layout = new WidgetChild(this, l);
        l.setParent(this);

        l.exceptionIfLayoutChildInvalid = delegate void(Widget child) {
            if (cast(MenuItem) child is null)
            {
                throw new Exception("child didn'd passed exceptionIfChildInvalid check");
            }
        };

        l.setPerformLayout(&stdLayoutFunction);
        return this;
    }

    void stdLayoutFunction(Widget w1)
    {
        auto w = cast(Layout) w1;
        auto m = w.findMenu();

        if (!m)
        {
            throw new Exception("this layout function designed for Menu widget");
        }

        w.setViewPortWidth(w.getWidth());
        w.setViewPortHeight(w.getHeight());

        final switch (m.getMode())
        {
        case MenuMode.bar:

            int targetW;
            int targetH;

            for (int i = 0; i != w.getLayoutChildCount(); i++)
            {
                auto c = w.getLayoutChild(i);
                if (!c)
                {
                    // TODO: assert? exception?
                    debug writeln("warning: getLayoutChild returned null");
                    continue;
                }
                auto cw = c.getDesiredWidth();
                auto ch = c.getDesiredHeight();
                if (ch > targetH)
                    targetH = ch;
                targetW += cw;
            }

            for (int i = 0; i != w.getLayoutChildCount(); i++)
            {
                auto c = w.getLayoutChild(i);
                if (!c)
                {
                    // TODO: assert? exception?
                    debug writeln("warning: getLayoutChild returned null");
                    continue;
                }
                auto cw = c.getDesiredWidth();
                auto ch = c.getDesiredHeight();
                c.setWidth(cw);
                c.setHeight(targetH);
            }

            w.setDesiredWidth(targetW);
            w.setDesiredHeight(targetH);

            linearLayout(w, Orientation.horizontal);

            break;
        case MenuMode.popup:

            int targetW;
            int targetH;

            for (int i = 0; i != w.getLayoutChildCount(); i++)
            {
                auto c = w.getLayoutChild(i);
                if (!c)
                {
                    // TODO: assert? exception?
                    debug writeln("warning: getLayoutChild returned null");
                    continue;
                }
                auto cw = c.getDesiredWidth();
                auto ch = c.getDesiredHeight();
                if (cw > targetW)
                    targetW = cw;
                targetH += ch;
            }

            for (int i = 0; i != w.getLayoutChildCount(); i++)
            {
                auto c = w.getLayoutChild(i);
                if (!c)
                {
                    // TODO: assert? exception?
                    debug writeln("warning: getLayoutChild returned null");
                    continue;
                }
                auto cw = c.getDesiredWidth();
                auto ch = c.getDesiredHeight();
                c.setWidth(targetW);
                c.setHeight(ch);
            }

            w.setDesiredWidth(targetW);
            w.setDesiredHeight(targetH);

            linearLayout(w, Orientation.vertical);

            break;
        }

        w.propagatePerformLayoutToChildren();
        w.propagatePerformLayoutToLayoutChildren();

        debug
        {
            auto f = getForm();
            writeln(" Menu:    size: %s x %s\n".format(w.getWidth(), w.getHeight()),
                    "      des size: %s x %s\n".format(w.getDesiredWidth(), w.getDesiredHeight()),
                    "      vp  size: %s x %s\n".format(w.getViewPortWidth(), w.getViewPortHeight()),
                    "     form size: %s x %s".format(f.getWidth(), f.getHeight()),
                    );

            for (int i = 0; i != w.getLayoutChildCount(); i++)
            {
                auto c = w.getLayoutChild(i);
                writeln("  menu child %d\n".format(i), "         size: %s x %s\n".format(c.getWidth(),
                        c.getHeight()), "     des size: %s x %s".format(c.getDesiredWidth(),
                        c.getDesiredHeight()),);
            }
        }
    }

    override WidgetChild[] calcWidgetChildren()
    {
        WidgetChild[] ret;
        if (layout)
            ret ~= layout;
        return ret;
    }

}
