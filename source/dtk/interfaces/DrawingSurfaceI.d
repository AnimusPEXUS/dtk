module dtk.interfaces.DrawingSurfaceI;

import std.typecons;

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
        Nullable!FillStyle fill_style
        );

    final void DrawRectangle(
        Position2D pos,
        Size2D size,
        LineStyle all_style,
        Nullable!FillStyle fill_style
        )
    {
        DrawRectangle(pos, size, all_style,all_style,all_style,all_style, fill_style);
    }

    final void DrawRectangle(
        Position2D pos,
        Size2D size,
        LineStyle top_left,
        LineStyle bottom_right,
        Nullable!FillStyle fill_style
        )
    {
        DrawRectangle(pos, size, top_left,top_left,bottom_right,bottom_right, fill_style);
    }

    void DrawText(string text, Position2D pos, Font font, FontStyle font_style, TextStyle text_style);
}
