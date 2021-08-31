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

    /* void drawBewel(
        bool top,
        bool right,
        bool left,
        bool bottom,
        )
        {

        } */

    void drawForm(Form widget) {

        writeln("drawForm called");

        auto ds = widget.getDrawingSurface();

        auto pos = widget.getPosition();
        auto size = widget.getSize();
        ds.drawRectangle(
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

        bool is_default = true;
        bool is_focused = true;

        auto ds = widget.getDrawingSurface();

        auto pos = Position2D(0,0);
        auto size = widget.getSize();

        if (is_default)
        {
            ds.drawRectangle(
                Position2D(0,0),
                size,
                LineStyle(Color(0)),
                Nullable!FillStyle()
                );
            pos.x++;
            pos.y++;
            size.width -= 2;
            size.height -= 2;
        }


        ds.drawRectangle(
            pos,
            size,
            LineStyle(elementLightedColor),
            LineStyle(elementDarkedColor),
            Nullable!FillStyle()
            );

        ds.drawRectangle(
            Position2D(pos.x+1,pos.y+1),
            Size2D(size.width-2, size.height-2),
            LineStyle(elementLightedColor2),
            LineStyle(elementDarkedColor2),
            Nullable!FillStyle()
            );

        ds.drawRectangle(
            Position2D(pos.x+2,pos.y+2),
            Size2D(size.width-4, size.height-4),
            LineStyle(buttonColor),
            nullable(FillStyle(buttonColor))
            );

        if (is_focused)
        {
            ds.drawRectangle(
                Position2D(pos.x+4,pos.y+4),
                Size2D(size.width-8, size.height-8),
                LineStyle(Color(0),[true,false]),
                Nullable!FillStyle()
                );
        }
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
