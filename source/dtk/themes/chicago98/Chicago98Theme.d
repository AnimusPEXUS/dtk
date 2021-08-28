module dtk.themes.chicago98.Chicago98Theme;

import std.stdio;
import std.typecons;

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
    Color formBackground = Color(0xc0c0c0);
    Color buttonBorderColor = Color(cast(ubyte[3])[0,0,0]);
    Color buttonColor = Color(0xc0c0c0);

    Color elementLightedColor = Color(0xffffff);
    Color elementLightedColor2 = Color(0xdfdfdf);

    Color elementDarkedColor = Color(0x000000);
    Color elementDarkedColor2 = Color(0x808080);

    void drawBewel(
        bool top,
        bool right,
        bool left,
        bool bottom,
        )
        {
            
        }

    void drawForm(Form widget) {

        writeln("drawForm called");

        auto ds = widget.getDrawingSurface();

        auto pos = widget.getPosition();
        auto size = widget.getSize();
        ds.DrawRectangle(
            pos,
            size,
            LineStyle(formBackground),
            LineStyle(formBackground),
            LineStyle(formBackground),
            LineStyle(formBackground),
            nullable(FillStyle(formBackground))
            );
    }

    void drawButton(Button widget)
    {
        writeln("drawButton called");

        auto ds = widget.getDrawingSurface();

        /* auto pos = widget.getPosition(); */
        auto size = widget.getSize();

        ds.DrawRectangle(
            Position2D(0,0),
            size,
            LineStyle(elementLightedColor),
            LineStyle(elementDarkedColor),
            Nullable!FillStyle()
            );

        ds.DrawRectangle(
            Position2D(1,1),
            Size2D(size.width-2, size.height-2),
            LineStyle(elementLightedColor2),
            LineStyle(elementDarkedColor2),
            Nullable!FillStyle()
            );

        ds.DrawRectangle(
            Position2D(3,3),
            Size2D(size.width-4, size.height-4),
            LineStyle(buttonColor),
            nullable(FillStyle(buttonColor))
            );
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
