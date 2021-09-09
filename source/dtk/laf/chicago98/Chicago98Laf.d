module dtk.themes.chicago98.Chicago98Laf;

import std.stdio;
import std.typecons;
import std.math;

import dtk.types.Color;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.LineStyle;
import dtk.types.FillStyle;

import dtk.interfaces.LafI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.WindowEventMgrI;

import dtk.widgets;

const
{
    auto P_45 = PI / 4;
    auto P_M45 = -P_45;
    auto P_135 = PI / 2 + P_45;
    auto P_135M2 = PI * 2 - P_45;
}

class Chicago98Laf : LafI
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

        ds.drawRectangle(Position2D(pos.x + 1, pos.y + 1), Size2D(size.width - 2,
                size.height - 2), LineStyle(c3), LineStyle(c4), Nullable!FillStyle());
    }

    void drawForm(Form widget)
    {

        writeln("drawForm called");

        auto ds = widget.getDrawingSurface();

        auto pos = widget.getPosition();
        auto size = widget.getSize();
        ds.drawRectangle(pos, size, LineStyle(formBackground), LineStyle(formBackground),
                LineStyle(formBackground), LineStyle(formBackground),
                nullable(FillStyle(formBackground)));
    }

    void drawButton(Button widget)
    {
        writeln("drawButton called");

        bool is_default = true;
        bool is_focused = true;

        auto ds = widget.getDrawingSurface();

        auto pos = Position2D(0, 0);
        auto size = widget.getSize();

        if (is_default)
        {
            ds.drawRectangle(Position2D(0, 0), size, LineStyle(Color(0)), Nullable!FillStyle());
            pos.x++;
            pos.y++;
            size.width -= 2;
            size.height -= 2;
        }

        drawBewel(ds, pos, size, false);

        ds.drawRectangle(Position2D(pos.x + 2, pos.y + 2), Size2D(size.width - 4,
                size.height - 4), LineStyle(buttonColor), nullable(FillStyle(buttonColor)));

        if (is_focused)
        {
            ds.drawRectangle(Position2D(pos.x + 4, pos.y + 4),
                    Size2D(size.width - 8, size.height - 8), LineStyle(Color(0),
                        [true, false]), Nullable!FillStyle());
        }
    }

    // TODO: Radio and Check Buttons have to be scalable, not fixed;
    void drawButtonRadio(ButtonRadio widget)
    {
        auto ds = widget.getDrawingSurface();
        auto pos = Position2D(0, 0);
        auto size = widget.getSize();

        // TODO: this have to be more flexible
        auto step = 2 * PI / 16;

        auto p = Position2D(6, 6);

        ds.drawArc(p, 6, P_M45, P_135, step, elementLightedColor);
        ds.drawArc(p, 6, P_135, P_135M2, step, elementDarkedColor2);

        ds.drawArc(p, 5, P_M45, P_135, step, elementLightedColor2);
        ds.drawArc(p, 5, P_135, P_135M2, step, elementDarkedColor);
    }

    // TODO: Radio and Check Buttons have to be scalable, not fixed;
    void drawButtonCheck(ButtonCheck widget)
    {
        auto ds = widget.getDrawingSurface();
        auto pos = Position2D(0, 0);
        auto size = widget.getSize();
        drawBewel(ds, pos, size, true);
    }

    void drawImage(Image widget)
    {
        writeln("drawImage called");
    }

    void drawLabel(Label widget)
    {
        writeln("drawLabel called");
    }

    void drawLayout(Layout widget)
    {
        writeln("drawLayout called");
    }

    void drawMenu(Menu widget)
    {
        writeln("drawMenu called");
    }

    void drawMenuItem(MenuItem widget)
    {
        writeln("drawMenuItem called");
    }

    void drawBar(Bar widget)
    {
        writeln("drawBar called");
    }

    void drawScrollBar(ScrollBar widget)
    {
        writeln("drawScrollBar called");
    }

    void drawTextEntry(TextEntry widget)
    {
        writeln("drawTextEntry called");
    }

    void drawTextArea(TextArea widget)
    {
        writeln("drawTextArea called");
    }

    void addEventHandling(WindowEventMgrI mgr)
    {

    }
}
