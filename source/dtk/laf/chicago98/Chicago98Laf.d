module dtk.laf.chicago98.Chicago98Laf;

import std.format;
import std.stdio;
import std.typecons;
import std.math;

import dtk.types.Color;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.fontinfo;
import dtk.types.TextStyle;

// import dtk.types.WindowEventMgrHandler;
import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.Image;
import dtk.types.Widget;
import dtk.types.Orientation;

import dtk.interfaces.LaFI;
import dtk.interfaces.WindowI;

// import dtk.interfaces.FormI;
import dtk.interfaces.DrawingSurfaceI;

// import dtk.interfaces.WindowEventMgrI;

import dtk.miscs.DrawingSurfaceShift;

import dtk.widgets.Form;
import dtk.widgets.Button;

// import dtk.widgets.ButtonRadio;
import dtk.widgets.ButtonCheck;

// import dtk.widgets.Picture;
import dtk.widgets.Layout;
import dtk.widgets.Menu;
import dtk.widgets.MenuItem;
import dtk.widgets.ScrollBar;
import dtk.widgets.TextEntry;

// TODO: deprecate Position2D and Size2D and pass values directly

const
{
    auto P_45 = PI / 4;
    auto P_M45 = -P_45;
    auto P_135 = PI / 2 + P_45;
    auto P_135M2 = PI * 2 - P_45;
}

class Chicago98Laf : LaFI
{

    Color formBackground = Color(0xc0c0c0);
    Color buttonBorderColor = Color(cast(ubyte[3])[0, 0, 0]);
    Color buttonColor = Color(0xc0c0c0);

    Color elementLightedColor = Color(0xffffff);
    Color elementLightedColor2 = Color(0xdfdfdf);

    Color elementDarkedColor = Color(0x000000);
    Color elementDarkedColor2 = Color(0x808080);

    void drawBewel(DrawingSurfaceI ds, Position2D pos, Size2D size, bool inverted)
    {
        auto c1 = elementLightedColor, c2 = elementDarkedColor,
            c3 = elementLightedColor2, c4 = elementDarkedColor2;

        if (inverted)
        {
            c1 = elementDarkedColor2;
            c2 = elementLightedColor2;
            c3 = elementLightedColor2;
            c4 = elementLightedColor;
        }

        ds.drawRectangle(pos, size, LineStyle(c1), LineStyle(c2), Nullable!FillStyle());

        ds.drawRectangle(
            Position2D(pos.x + 1, pos.y + 1),
            Size2D(size.width - 2, size.height - 2),
            LineStyle(c3),
            LineStyle(c4),
            Nullable!FillStyle()
            );
    }

    void drawForm(Form e, DrawingSurfaceI ds)
    {
        const int pos_x = 0;
        const int pos_y = 0;
        auto size_w = e.getWidth();
        auto size_h = e.getHeight();

        /*         ds.drawRectangle(
        Position2D(pos_x, pos_y),
        Size2D(size_w, size_h),
        LineStyle(formBackground),
        LineStyle(formBackground),
        LineStyle(formBackground),
        LineStyle(formBackground),
        nullable(FillStyle(formBackground))
        );
        */

        ds.drawRectangle(
            Position2D(pos_x, pos_y),
            Size2D(size_w, size_h),
            LineStyle(formBackground),
            nullable(FillStyle(formBackground))
            );
    }

    void drawButton(Button e, DrawingSurfaceI ds)
    {
        bool is_default = delegate bool() {
            auto f = e.getForm();
            if (f is null)
                return false;
            auto def = f.getDefaultWidget();
            return e == def;
        }();
        bool is_focused = delegate bool() {
            auto f = e.getForm();
            if (f is null)
                return false;
            auto curvid = f.getFocusedWidget();
            return e == curvid;
        }();
        bool is_down = e.getVisuallyPressed();

        auto pos_x = cast(int) 0;
        auto pos_y = cast(int) 0;
        auto size_w = cast(int) e.getWidth();
        auto size_h = cast(int) e.getHeight();

        if (is_default)
        {
            ds.drawRectangle(Position2D(pos_x, pos_y), Size2D(size_w, size_h),
                    LineStyle(Color(0)), Nullable!FillStyle());
            pos_x++;
            pos_y++;
            size_w -= 2;
            size_h -= 2;
        }

        drawBewel(ds, Position2D(pos_x, pos_y), Size2D(size_w, size_h), is_down);

        ds.drawRectangle(Position2D(pos_x + 2, pos_y + 2), Size2D(size_w - 4,
                size_h - 4), LineStyle(buttonColor), nullable(FillStyle(buttonColor)));

        if (is_focused)
        {
            ds.drawRectangle(Position2D(pos_x + 4, pos_y + 4), Size2D(size_w - 8,
                    size_h - 8), LineStyle(Color(0), [true, false]), Nullable!FillStyle());
        }
    }

    // TODO: Radio and Check Buttons have to be scalable, not fixed;
    void drawButtonRadio(ButtonCheck e, DrawingSurfaceI ds)
    {
        assert(ds !is null);

        const int pos_x = 0;
        const int pos_y = 0;
        int size_w = e.getWidth();
        int size_h = e.getHeight();

        const int indicatorSize = 12;
        const int indicatorSizeHalf = indicatorSize / 2;

        // TODO: this have to be more flexible
        auto step = 2 * PI / 32;

        auto p = Position2D(indicatorSizeHalf, indicatorSizeHalf);

        ds.drawRectangle(Position2D(pos_x, pos_y), Size2D(size_w + 1, size_h + 1),
                LineStyle(formBackground), nullable(FillStyle(formBackground)));

        ds.drawArc(p, indicatorSizeHalf, P_M45, P_135, step, elementLightedColor);
        ds.drawArc(p, indicatorSizeHalf, P_135, P_135M2, step, elementDarkedColor2);

        ds.drawArc(p, indicatorSizeHalf - 1, P_M45, P_135, step, elementLightedColor2);
        ds.drawArc(p, indicatorSizeHalf - 1, P_135, P_135M2, step, elementDarkedColor);

        ds.drawCircle(p, indicatorSizeHalf - 2, step, Color(0xffffff));

        auto fillColor = Color(0xffffff);
        if (e.getToggledOn())
        {
            fillColor = Color(0);
        }

        for (int i = indicatorSizeHalf - 3; i != 0; i--)
        {
            ds.drawCircle(p, i, step, fillColor);
        }

        {
            auto id = ImageDot();
            id.color = fillColor;
            id.enabled = true;
            id.intensivity = 1;
            ds.drawDot(Position2D(indicatorSizeHalf, indicatorSizeHalf), id);
        }

        if (e.getForm().getFocusedWidget() == e)
        {
            ds.drawRectangle(Position2D(pos_x, pos_y), Size2D(size_w, size_h),
                    LineStyle(Color(0), [true, false]), Nullable!FillStyle());
        }
    }

    // TODO: Radio and Check Buttons have to be scalable, not fixed;
    void drawButtonCheck(ButtonCheck e, DrawingSurfaceI ds)
    {
        const int pos_x = 0;
        const int pos_y = 0;
        int size_w = e.getWidth();
        int size_h = e.getHeight();

        const int indicatorSize = 12;

        ds.drawRectangle(Position2D(pos_x, pos_y), Size2D(size_w + 1, size_h + 1),
                LineStyle(formBackground), nullable(FillStyle(formBackground)));

        drawBewel(ds, Position2D(pos_x, pos_y), Size2D(indicatorSize, indicatorSize), true);

        ds.drawRectangle(Position2D(pos_x + 2, pos_y + 2), Size2D(indicatorSize - 4,
                indicatorSize - 4), LineStyle(Color(0xffffff)),
                nullable(FillStyle(Color(0xffffff))));

        if (e.getForm().getFocusedWidget() == e)
        {
            ds.drawRectangle(Position2D(pos_x, pos_y), Size2D(size_w, size_h),
                    LineStyle(Color(0), [true, false]), Nullable!FillStyle());
        }

        auto fillColor = Color(0xffffff);

        if (e.getToggledOn())
        {
            ds.drawRectangle(Position2D(pos_x + 3, pos_y + 3),
                    Size2D(indicatorSize - 6, indicatorSize - 6),
                    LineStyle(Color(0)), nullable(FillStyle(Color(0))));
        }

    }

    // void drawPicture(Widget e, DrawingSurfaceI ds)
    // {
    //
    // }

    // TODO: move this to some more appropriate place or delete
    // NOTE: have copy of this function in TextProcessor
    // private ubyte chanBlend(ubyte lower, ubyte higher, real part)
    // {
    // return cast(ubyte)(lower + ((higher - lower) * part));
    // }

    void drawLayout(Layout e, DrawingSurfaceI ds)
    {
        auto size_w = e.getWidth();
        auto size_h = e.getHeight();

        ds.drawRectangle(Position2D(0, 0), Size2D(size_w, size_h),
                LineStyle(formBackground), nullable(FillStyle(formBackground)));

        debug
        {
            if (e.drawRectangleAroundViewPort)
            {
                ds.drawRectangle(Position2D(e.getViewPortPosX(), e.getViewPortPosY()),
                        Size2D(e.getViewPortWidth(), e.getViewPortHeight()),
                        LineStyle(elementDarkedColor), Nullable!FillStyle());
            }
        }

    }

    void drawMenu(Menu e, DrawingSurfaceI ds)
    {
        int pos_x = 0;
        int pos_y = 0;
        auto size_w = e.getWidth();
        auto size_h = e.getHeight();

        ds.drawRectangle(Position2D(pos_x, pos_y), Size2D(size_w, size_h),
                LineStyle(formBackground), nullable(FillStyle(formBackground)));

    }

    void drawMenuItem(MenuItem e, DrawingSurfaceI ds)
    {
        int pos_x = 0;
        int pos_y = 0;
        auto size_w = e.getWidth();
        auto size_h = e.getHeight();

        ds.drawRectangle(Position2D(pos_x, pos_y), Size2D(size_w, size_h),
                LineStyle(formBackground), nullable(FillStyle(formBackground)));
    }

    void drawScrollBar(ScrollBar e, DrawingSurfaceI ds)
    {
        int pos_x = 0;
        int pos_y = 0;
        auto size_w = e.getWidth();
        auto size_h = e.getHeight();

        ds.drawRectangle(Position2D(pos_x, pos_y), Size2D(size_w, size_h),
                LineStyle(formBackground), nullable(FillStyle(formBackground)));

        bool flipper;
        if (e.getOrientation() == Orientation.horizontal)
        {
            for (auto i = 0; i != e.buttonSize; i++)
            {
                ds.drawLine(Position2D(e.buttonSize, i), Position2D(size_w - e.buttonSize,
                        i), LineStyle(elementLightedColor2, [flipper, !flipper]),);
                flipper = !flipper;
            }
        }
        else
        {
            for (auto i = 0; i != e.buttonSize; i++)
            {
                ds.drawLine(Position2D(i, e.buttonSize), Position2D(i, size_h - e.buttonSize),
                        LineStyle(elementLightedColor2, [flipper, !flipper]),);
                flipper = !flipper;
            }
        }

        ds.drawRectangle(Position2D(e.scopeBewelX, e.scopeBewelY),
                Size2D(e.scopeBewelW, e.scopeBewelH), LineStyle(formBackground),
                nullable(FillStyle(formBackground)));

        drawBewel(ds, Position2D(e.scopeBewelX, e.scopeBewelY),
                Size2D(e.scopeBewelW, e.scopeBewelH), false);
    }

    void drawTextEntry(TextEntry e, DrawingSurfaceI ds)
    {
        int pos_x = 0;
        int pos_y = 0;
        auto size_w = e.getWidth();
        auto size_h = e.getHeight();
        // auto draw_bewel = false;
        // auto bewel_bg_color = Color(cast(ubyte[])[255,255,255]);
        auto draw_bewel = e.getDrawBewelAndBackground();
        auto bewel_bg_color = e.getBewelBackgroundColor();

        auto tv_ds = ds;

        if (draw_bewel)
        {
            drawBewel(ds, Position2D(pos_x, pos_y), Size2D(size_w, size_h), true);
            // pos_x = cast(int) 0;
            // pos_y = cast(int) 0;
            // size_w = cast(int) size_w;
            // size_h = cast(int) size_h;
            pos_x = e.padding_left;
            pos_y = e.padding_top;
            size_w = e.tv_width;
            size_h = e.tv_height;
            ds.drawRectangle(Position2D(pos_x, pos_y), Size2D(size_w, size_h),
                    LineStyle(Color(0)), nullable(FillStyle(bewel_bg_color)));

            tv_ds = new DrawingSurfaceShift(ds, e.padding_left, e.padding_top);
        }

        if (e.text_view !is null)
        {
            e.text_view.completeRedrawToDS(tv_ds);
        }
    }
}
