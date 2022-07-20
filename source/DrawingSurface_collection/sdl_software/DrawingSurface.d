module dtk.DrawingSurface_collection.sdl_software.DrawingSurface;

import std.stdio;
import std.typecons;
import std.math;
import std.conv;

import bindbc.sdl;

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.Color;
import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.fontinfo;
import dtk.types.TextStyle;
import dtk.types.Image;

import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.FaceI;

/* import dtk.miscs.DrawingSurfaceShift; */

import dtk.backends.sdl_desktop.Window;

class DrawingSurface : DrawingSurfaceI
{

    private Window w;

    this(Window w)
    {
        this.w = w;
    }

    void drawDot(Position2D pos, ImageDot dot)
    {
        if (!dot.enabled)
            return;
        auto rndr = SDL_GetRenderer(w.sdl_window);
        SDL_SetRenderDrawColor(rndr, dot.color.r, dot.color.g, dot.color.b, dot.color.a);
        SDL_RenderDrawPoint(rndr, pos.x, pos.y);
    }

    bool canGetDot()
    {
        return false;
    }

    ImageDot getDot(Position2D pos)
    {
        throw new Exception("getDot() not supported");
    }

    void drawLine(Position2D pos, Position2D pos2, LineStyle style)
    {
        if (style.style == null)
        {
            auto rndr = SDL_GetRenderer(w.sdl_window);
            SDL_SetRenderDrawColor(rndr, style.color.r, style.color.g,
                    style.color.b, style.color.a);
            SDL_RenderDrawLine(rndr, pos.x, pos.y, pos2.x, pos2.y);
        }
        else
        {
            auto style_dup = style.style.dup();

            auto dots = calculateDotsInLine(pos, pos2);

            foreach (v; dots)
            {
                if (style_dup[0])
                {
                    {
                        auto id = ImageDot();
                        id.color = style.color;
                        id.enabled = true;
                        id.intensivity = 1;
                        drawDot(v, id);
                    }
                }
                style_dup = style_dup[1 .. $] ~ style_dup[0];
            }
        }
    }

    void drawRectangle(Position2D pos, Size2D size, LineStyle top_style, LineStyle left_style,
            LineStyle bottom_style, LineStyle right_style, Nullable!FillStyle fill_style)
    {
        auto rndr = SDL_GetRenderer(w.sdl_window);
        assert(rndr !is null);

        if (top_style == left_style && top_style == bottom_style
                && top_style == right_style && top_style.style == null)
        {
            SDL_SetRenderDrawColor(rndr, top_style.color.r, top_style.color.g,
                    top_style.color.b, top_style.color.a);
            auto r = new SDL_Rect(pos.x, pos.y, size.width, size.height);
            SDL_RenderDrawRect(rndr, r);
        }
        else
        {

            // top+left
            auto p1_x = pos.x;
            auto p1_y = pos.y;
            // top+right
            auto p2_x = p1_x + size.width;
            auto p2_y = p1_y;
            // bottom+right
            auto p3_x = p2_x;
            auto p3_y = p2_y + size.height;
            // bottom+left
            auto p4_x = p1_x;
            auto p4_y = p3_y;

            drawLine(Position2D(p1_x, p1_y), Position2D(p2_x, p2_y), top_style);
            drawLine(Position2D(p1_x, p1_y), Position2D(p4_x, p4_y), left_style);
            drawLine(Position2D(p4_x, p4_y), Position2D(p3_x, p3_y), bottom_style);
            drawLine(Position2D(p2_x, p2_y), Position2D(p3_x, p3_y), right_style);
        }

        if (!fill_style.isNull())
        {
            auto x_c = fill_style.get().color;
            SDL_SetRenderDrawColor(rndr, x_c.r, x_c.g, x_c.b, x_c.a);
            auto r = new SDL_Rect(pos.x, pos.y, size.width, size.height);
            SDL_RenderFillRect(rndr, r);
        }

    }

    // TODO: performance check required. probably functions which use it, have
    //       to use catching
    void drawArc(Position2D pos, uint radius, real start_angle, real stop_angle,
            real turn_step, Color color)
    {
        import std.math;

        if (turn_step < 0)
        {
            turn_step = -turn_step;
        }

        if (stop_angle < start_angle)
        {
            turn_step = -turn_step;
        }

        Position2D pcalc(real current_step)
        {
            real x = cos(current_step) * radius;
            real y = sin(current_step) * radius;
            return Position2D(cast(int)(lround(x)) + pos.x, cast(int)(lround(y)) + pos.y);
        }

        Position2D prev_point = pcalc(start_angle);

        for (real current_step = start_angle; (current_step >= start_angle)
                && (current_step <= stop_angle); current_step += turn_step)
        {
            auto point = pcalc(current_step);
            drawLine(prev_point, point, LineStyle(color));
            prev_point = point;
        }

    }

    void drawCircle(Position2D pos, uint radius, real turn_step, Color color)
    {
        if (turn_step < 0)
        {
            turn_step = -turn_step;
        }
        drawArc(pos, radius, 0, 2 * PI, turn_step, color);
    }

    void drawImage(Position2D pos, Image image) // add support for various image modes
    {
        for (uint y = 0; y != image.height; y++)
        {
            for (uint x = 0; x != image.width; x++)
            {
                auto xx = image.getDot(x, y);
                // xx.color.a = 255;
                drawDot(Position2D(pos.x + x, pos.y + y), xx);
            }
        }
    }

    bool canGetImage()
    {
        return false;
    }

    Image getImage(Position2D pos, Size2D size)
    {
        throw new Exception("getImage() not supported");
    }

    bool canPresent()
    {
        return true;
    }

    void present()
    {
        auto rndr = SDL_GetRenderer(w.sdl_window);
        SDL_RenderPresent(rndr);
    }

}
