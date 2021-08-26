module dtk.interfaces.DrawingSurfaceI;

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.Color;
import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.Font;
import dtk.types.FontStyle;
import dtk.types.TextStyle;

interface DrawingSurfaceI
{
    void DrawDot(Position2D pos, Color color);
    void DrawLine(Position2D pos, Position2D pos2, LineStyle style);
    void DrawRectangle(
        Position2D pos,
        Size2D size,
        LineStyle top_style,
        LineStyle left_style,
        LineStyle bottom_style,
        LineStyle right_style,
        FillStyle fill_style
        );
    void DrawText(string text, Position2D pos, Font font, FontStyle font_style, TextStyle text_style);
}
