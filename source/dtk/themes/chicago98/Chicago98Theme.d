module dtk.themes.chicago98.Chicago98Theme;

import std.stdio;

import dtk.types.Color;
import dtk.types.Point;
import dtk.types.Size;
import dtk.types.LineStyle;
import dtk.types.FillStyle;

import dtk.interfaces.ThemeI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.widgets;


class Chicago98Theme : ThemeI
{
    Color formBackground = Color(0xdddddd);
    void drawForm(DrawingSurfaceI ds, Form widget) {

        auto size = widget.locator.getCalculatedSize();
        ds.DrawRectangle(
            Point(0,0),
            size,
            LineStyle(),
            LineStyle(),
            LineStyle(),
            LineStyle(),
            FillStyle()
            );
    }

    void drawButton(DrawingSurfaceI ds, Button widget)
    {
        writeln("drawButton called");
    }

    void drawImage(DrawingSurfaceI ds, Image widget)
    {
        writeln("drawImage called");
    }

    void drawLabel(DrawingSurfaceI ds, Label widget)
    {
        writeln("drawLabel called");
    }

    void drawLayout(DrawingSurfaceI ds, Layout widget)
    {
        writeln("drawLayout called");
    }

    void drawMenu(DrawingSurfaceI ds, Menu widget)
    {
        writeln("drawMenu called");
    }

    void drawMenuItem(DrawingSurfaceI ds, MenuItem widget)
    {
        writeln("drawMenuItem called");
    }

    void drawBar(DrawingSurfaceI ds, Bar widget)
    {
        writeln("drawBar called");
    }

    void drawScrollBar(DrawingSurfaceI ds, ScrollBar widget)
    {
        writeln("drawScrollBar called");
    }

    void drawTextEntry(DrawingSurfaceI ds, TextEntry widget)
    {
        writeln("drawTextEntry called");
    }

    void drawTextArea(DrawingSurfaceI ds, TextArea widget)
    {
        writeln("drawTextArea called");
    }
}
