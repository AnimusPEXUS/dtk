module dtk.platforms.sdl_desktop.DrawingSurface;

import std.stdio;
import std.typecons;

import bindbc.sdl;

import dtk.types.Position2D;
import dtk.types.Size2D;
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

    void DrawDot(Position2D pos, Color color)
    {

    }

    void DrawLine(Position2D pos, Position2D pos2, LineStyle style)
    {

    }

    void DrawRectangle(
            Position2D pos,
            Size2D size,
            LineStyle top_style,
            LineStyle left_style,
            LineStyle bottom_style,
            LineStyle right_style,
            Nullable!FillStyle fill_style
            )
    {
        auto rndr = SDL_GetRenderer(w._sdl_window);
        assert(rndr !is null);

        if (top_style == left_style && top_style == bottom_style && top_style == right_style)
        {
            SDL_SetRenderDrawColor(rndr, top_style.color.r, top_style.color.g, top_style.color.b, top_style.color.a);
            auto r = new SDL_Rect(pos.x, pos.y, size.width, size.height);
            SDL_RenderDrawRect(rndr, r);
        }
        else {

            void ttt1(LineStyle name) {
                SDL_SetRenderDrawColor(rndr, name.color.r, name.color.g, name.color.b, name.color.a);
            }

            // top+left
            auto p1_x = pos.x;
            auto p1_y = pos.y;
            // top+right
            auto p2_x = p1_x+size.width;
            auto p2_y = p1_y;
            // bottom+right
            auto p3_x = p2_x;
            auto p3_y = p2_y + size.height;
            // bottom+left
            auto p4_x = p1_x;
            auto p4_y = p3_y;

            ttt1(top_style);
            SDL_RenderDrawLine(rndr, p1_x, p1_y, p2_x, p2_y);

            ttt1(left_style);
            SDL_RenderDrawLine(rndr, p1_x, p1_y, p4_x, p4_y);

            ttt1(bottom_style);
            SDL_RenderDrawLine(rndr, p4_x, p4_y, p3_x, p3_y);

            ttt1(right_style);
            SDL_RenderDrawLine(rndr, p2_x, p2_y, p3_x, p3_y);

        }

        if (!fill_style.isNull())
        {
            auto x_c = fill_style.get().color;
            SDL_SetRenderDrawColor(rndr, x_c.r, x_c.g, x_c.b, x_c.a);
            auto r = new SDL_Rect(pos.x, pos.y, size.width, size.height);
            SDL_RenderFillRect(rndr,r);
        }

        SDL_RenderPresent(rndr);

        /* auto surf = SDL_GetWindowSurface(w._sdl_window);
        assert(surf !is null);
        auto r = SDL_Rect(pos.x, pos.y, size.width, size.height);
        writeln("drawing rect ", r);
        SDL_FillRect( surf, &r, SDL_MapRGB( surf.format, 0xdd, 0xdd, 0xdd ) );
        SDL_UpdateWindowSurface(w._sdl_window); */
    }

    void DrawText(string text, Position2D pos, Font font, FontStyle font_style, TextStyle text_style,)
    {

    }
}
