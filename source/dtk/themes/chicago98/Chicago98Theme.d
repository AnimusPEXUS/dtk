module dtk.themes.chicago98.Chicago98Theme;

import std.stdio;

import dtk.types.Color;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.LineStyle;
import dtk.types.FillStyle;

import dtk.interfaces.ThemeI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.widgets;


class Chicago98Theme : ThemeI
{
    Color formBackground = Color(0xdddddd);
    void drawForm(Form widget) {

        writeln("drawForm called");

        auto ds = widget.getDrawingSurface();

        auto pos = widget.getPosition();
        auto size = widget.getSize();
        ds.DrawRectangle(
            pos,
            size,
            LineStyle(),
            LineStyle(),
            LineStyle(),
            LineStyle(),
            FillStyle()
            );
    }

    void drawButton(Button widget)
    {
        writeln("drawButton called");
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
}
