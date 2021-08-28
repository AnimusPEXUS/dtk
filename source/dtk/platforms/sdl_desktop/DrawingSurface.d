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

    void drawDot(Position2D pos, Color color)
    {
        auto rndr = SDL_GetRenderer(w._sdl_window);
        SDL_SetRenderDrawColor(rndr, color.r, color.g, color.b, color.a);
        SDL_RenderDrawPoint(rndr, pos.x, pos.y);
    }

    void drawLine(Position2D pos, Position2D pos2, LineStyle style)
    {
        if (style.style == null)
        {
            auto rndr = SDL_GetRenderer(w._sdl_window);
            SDL_SetRenderDrawColor(rndr, style.color.r, style.color.g, style.color.b, style.color.a);
            SDL_RenderDrawLine(rndr, pos.x, pos.y, pos2.x, pos2.y);
        }
        else
        {
            auto style_dup = style.style.dup();

            for (int x = pos.x; x != pos2.x; x++)
            {
                if (style_dup[0])
                {
                    drawDot(Position2D(x, pos.y), style.color);
                }
                style_dup = style_dup[1 .. $] ~ style_dup[0];
            }
        }
    }

    void drawRectangle(
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

        if (top_style == left_style && top_style == bottom_style && top_style == right_style && top_style.style==null)
        {
            SDL_SetRenderDrawColor(rndr, top_style.color.r, top_style.color.g, top_style.color.b, top_style.color.a);
            auto r = new SDL_Rect(pos.x, pos.y, size.width, size.height);
            SDL_RenderDrawRect(rndr, r);
        }
        else {

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

            drawLine(Position2D(p1_x, p1_y), Position2D(p2_x, p2_y),top_style);
            drawLine(Position2D(p1_x, p1_y), Position2D(p4_x, p4_y),left_style);
            drawLine(Position2D(p4_x, p4_y), Position2D(p3_x, p3_y),bottom_style);
            drawLine(Position2D(p2_x, p2_y), Position2D(p3_x, p3_y),right_style);

        }

        if (!fill_style.isNull())
        {
            auto x_c = fill_style.get().color;
            SDL_SetRenderDrawColor(rndr, x_c.r, x_c.g, x_c.b, x_c.a);
            auto r = new SDL_Rect(pos.x, pos.y, size.width, size.height);
            SDL_RenderFillRect(rndr,r);
        }


        /* auto surf = SDL_GetWindowSurface(w._sdl_window);
        assert(surf !is null);
        auto r = SDL_Rect(pos.x, pos.y, size.width, size.height);
        writeln("drawing rect ", r);
        SDL_FillRect( surf, &r, SDL_MapRGB( surf.format, 0xdd, 0xdd, 0xdd ) );
        SDL_UpdateWindowSurface(w._sdl_window); */
    }

    void drawText(string text, Position2D pos, Font font, FontStyle font_style, TextStyle text_style,)
    {

    }

    void present() {
        auto rndr = SDL_GetRenderer(w._sdl_window);
        SDL_RenderPresent(rndr);
    }

}
