module dtk.platforms.sdl_desktop.DrawingSurface;

import std.stdio;

import bindbc.sdl;

import dtk.types.Point;
import dtk.types.Size;
import dtk.types.Color;
import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.Font;
import dtk.types.FontStyle;
import dtk.types.TextStyle;

import dtk.interfaces.DrawingSurfaceI;

import dtk.platforms.sdl_desktop.Window;

class DrawingSurface : DrawingSurfaceI
{

    private Window w;

    this(Window w)
    {
        this.w=w;
    }

    void DrawDot(Point pos, Color color)
    {

    }

    void DrawLine(Point pos, Point pos2, LineStyle style)
    {

    }

    void DrawRectangle(
            Point pos,
            Size size,
            LineStyle top_style,
            LineStyle left_style,
            LineStyle bottom_style,
            LineStyle right_style,
            FillStyle fill_style
            )
    {
        /* auto rndr = SDL_GetRenderer(w._sdl_window);
        assert(rndr !is null);
        auto r = SDL_Rect(pos.x, pos.y, size.width, size.height);
        SDL_RenderFillRect(rndr, &r); */

        auto surf = SDL_GetWindowSurface(w._sdl_window);
        assert(surf !is null);
        auto r = SDL_Rect(pos.x, pos.y, size.width, size.height);
        writeln("drawing rect ", r);
        SDL_FillRect( surf, &r, SDL_MapRGB( surf.format, 0xdd, 0xdd, 0xdd ) );
        SDL_UpdateWindowSurface(w._sdl_window);
    }

    void DrawText(string text, Point pos, Font font, FontStyle font_style, TextStyle text_style,)
    {

    }
}
