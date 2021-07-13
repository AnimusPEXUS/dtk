module dtk.interfaces.DrawingSurfaceI;

import dtk.types.Point;
import dtk.types.Size;
import dtk.types.Color;
import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.Font;
import dtk.types.FontStyle;
import dtk.types.TextStyle;

interface DrawingSurfaceI
{
    void DrawDot(Point pos, Color color);
    void DrawLine(Point pos, Point pos2, LineStyle style);
    void DrawRectangle(
        Point pos,
        Size size,
        LineStyle top_style,
        LineStyle left_style,
        LineStyle bottom_style,
        LineStyle right_style,
        FillStyle fill_style
        );
    void DrawText(string text, Point pos, Font font, FontStyle font_style, TextStyle text_style,);
}
