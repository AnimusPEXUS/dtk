module dtk.interfaces.DrawingSurfaceI;

import std.typecons;

import dtk.interfaces.FaceI;

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.Color;
import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.fontinfo;
import dtk.types.TextStyle;
import dtk.types.Image;

interface DrawingSurfaceI
{

    void drawDot(Position2D pos, Color color);
    /* Color getDot(Position2D pos); // TODO: enable this */

    void drawLine(Position2D pos, Position2D pos2, LineStyle style);

    void drawRectangle(Position2D pos, Size2D size, LineStyle top_style, LineStyle left_style,
            LineStyle bottom_style, LineStyle right_style, Nullable!FillStyle fill_style);

    final void drawRectangle(Position2D pos, Size2D size, LineStyle all_style,
            Nullable!FillStyle fill_style)
    {
        drawRectangle(pos, size, all_style, all_style, all_style, all_style, fill_style);
    }

    final void drawRectangle(Position2D pos, Size2D size, LineStyle top_left,
            LineStyle bottom_right, Nullable!FillStyle fill_style)
    {
        drawRectangle(pos, size, top_left, top_left, bottom_right, bottom_right, fill_style);
    }

    /* void drawText(string text, Position2D pos, FontI font,
            FontStyle font_style); // , TextStyle text_style
 */
    void drawArc(Position2D pos, uint radius, real start_angle, real stop_angle,
            real turn_step, Color color);

    void drawCircle(Position2D pos, uint radius, real turn_step, Color color);

    void drawImage(Position2D pos, Image image);
    /* Image getImage(Position2D pos, Size2D size); // TODO: enable this */

    void present();
}
