module dtk.miscs.DrawingSurfaceShift;

// TODO: dtk.miscs.DrawingSurfaceShifted and dtk.widgets.WidgetDrawingSurface
//       have many similaritys and have to be merged somehow;

import std.stdio;
import std.typecons;

import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.FaceI;

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.Color;
import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.fontinfo;
import dtk.types.TextStyle;
import dtk.types.Image;

class DrawingSurfaceShift : DrawingSurfaceI
{
    int x_shift;
    int y_shift;
    DrawingSurfaceI ds;

    this(DrawingSurfaceI ds, int x_shift, int y_shift)
    {
        this.x_shift = x_shift;
        this.y_shift = y_shift;
        this.ds = ds;
    }

    void drawDot(Position2D pos, ImageDot dot)
    {
        Position2D npos;
        npos.x = pos.x + x_shift;
        npos.y = pos.y + y_shift;
        ds.drawDot(npos, dot);
    }

    bool canGetDot()
    {
        return ds.canGetDot();
    }

    ImageDot getDot(Position2D pos)
    {
        Position2D npos;
        npos.x = pos.x + x_shift;
        npos.y = pos.y + y_shift;
        return ds.getDot(npos);
    }


    void drawLine(Position2D pos, Position2D pos2, LineStyle style)
    {
        Position2D npos;
        Position2D npos2;
        npos.x = pos.x + x_shift;
        npos.y = pos.y + y_shift;
        npos2.x = pos2.x + x_shift;
        npos2.y = pos2.y + y_shift;
        ds.drawLine(npos, npos2, style);
    }

    void drawRectangle(Position2D pos, Size2D size, LineStyle top_style, LineStyle left_style,
            LineStyle bottom_style, LineStyle right_style, Nullable!FillStyle fill_style)
    {
        Position2D npos;
        npos.x = pos.x + x_shift;
        npos.y = pos.y + y_shift;
        ds.drawRectangle(npos, size, top_style, left_style, bottom_style, right_style, fill_style);
    }

    /* void drawText(string text, Position2D pos, FontI font,
            FontStyle font_style) // , TextStyle text_style
    {
        Position2D npos;
        npos.x = pos.x + x_shift;
        npos.y = pos.y + y_shift;
        ds.drawText(text, npos, font, font_style); // , text_style
    } */

    void drawArc(Position2D pos, uint radius, real start_angle, real stop_angle,
            real turn_step, Color color)
    {
        Position2D npos;
        npos.x = pos.x + x_shift;
        npos.y = pos.y + y_shift;
        ds.drawArc(npos, radius, start_angle, stop_angle, turn_step, color);
    }

    void drawCircle(Position2D pos, uint radius, real turn_step, Color color)
    {
        Position2D npos;
        npos.x = pos.x + x_shift;
        npos.y = pos.y + y_shift;
        ds.drawCircle(npos, radius, turn_step, color);
    }

    void drawImage(Position2D pos, Image image)
    {
        Position2D npos;
        npos.x = pos.x + x_shift;
        npos.y = pos.y + y_shift;
        ds.drawImage(npos, image);
    }

    bool canGetImage()
    {
        return ds.canGetImage();
    }

    Image getImage(Position2D pos, Size2D size)
    {
        Position2D npos;
        npos.x = pos.x + x_shift;
        npos.y = pos.y + y_shift;
        return ds.getImage(npos, size);
    }

    bool canPresent()
    {
        return ds.canPresent();
    }

    void present()
    {
        ds.present();
    }

}
