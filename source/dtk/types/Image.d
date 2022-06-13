module dtk.types.Image;

import std.format;
import std.stdio;
import std.typecons;
import std.math;

import dtk.interfaces.DrawingSurfaceI;

import dtk.types.Color;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.LineStyle;
import dtk.types.FillStyle;

struct ImageDot
{
    bool enabled;
    real intensivity;
    Color color;

    invariant
    {
        assert(intensivity >= 0 && intensivity <= 1);
    }
}

class Image : DrawingSurfaceI // TODO: enable DrawingSurfaceI
{
    int width;
    int height;
    ImageDot[] data;

    bool baseColorEnabled;
    Color baseColor;

    this(int width, int height)
    {
        assert(width >= 0);
        assert(height >= 0);
        assert(width < 10000, "image width suspitiously big");
        this.width = width;
        this.height = height;
        this.data = new ImageDot[](width * height);
    }

    private int calcIndex(int x, int y)
    {
        assert(x >= 0);
        assert(y >= 0);
        return y * width + x;
    }

    bool isOutOfIndex(int x, int y)
    {
        auto z = calcIndex(x, y);
        auto dl = data.length;
        if (dl == 0)
        {
            return true;
        }
        return !((z >= 0) && (z < dl));
    }

    typeof(this) setEach(ImageDot new_value)
    {
        for (uint i = 0; i != data.length; i++)
        {
            data[i] = new_value;
        }
        return this;
    }

    typeof(this) setDot(int x, int y, ImageDot new_value)
    {
        assert(x >= 0, "invalid x value: %s".format(x));
        assert(y >= 0, "invalid y value: %s".format(y));
        if (x > width) /* throw new Exception("invalid x"); */
            return this;
        if (y > height) /* throw new Exception("invalid y"); */
            return this;
        auto z = calcIndex(x, y);
        if (z < 0 || z >= this.data.length)
            return this;
        this.data[z] = new_value;
        return this;
    }

    ImageDot getDot(int x, int y)
    {
        assert(x >= 0);
        assert(y >= 0);
        ImageDot ret;
        auto i = calcIndex(x, y);
        if (i >= this.data.length)
        {
            debug writefln("getDot: i == %s, x == %s, y == %s", i, x, y);
            debug writefln("width: %s, height: %s", width, height);
        }
        return this.data[i];
    }

    ref ImageDot getDotRef(int x, int y)
    {
        return this.data[calcIndex(x, y)];
    }

    void resize(int width, int height)
    {
        assert(width >= 0);
        assert(height >= 0);
        auto new_data = new ImageDot[](width * height);

        auto this_width = this.width;
        auto this_height = this.height;

        int copy_width = (this_width > width ? width : this_width);
        int copy_height = (this_height > height ? height : this_height);

        for (int y = 0; y != copy_height; y++)
        {
            for (int x = 0; x != copy_width; x++)
            {
                new_data[calcIndex(x, y)] = this.data[y * this_width + x];
            }
        }

        this.data = new_data;
        this.width = width;
        this.height = height;
    }

    void putImage(int x, int y, Image new_image)
    {
        // assert(x >= 0);
        // assert(y >= 0);

        // this allows passing negative x, y
        if (x < 0 || y < 0)
        {
            auto new_x = (x < 0 ? x * -1 : 0);
            auto new_y = (y < 0 ? y * -1 : 0);
            new_image = new_image.getImage(new_x, new_y,
                    new_image.width - new_x, new_image.height - new_y);

            if (x < 0)
                x = 0;

            if (y < 0)
                y = 0;
        }

        if (x > width)
            return;
        if (y > height)
            return;

        int horizontal_copy_count = new_image.width;
        int vertical_copy_count = new_image.height;

        if ((x + horizontal_copy_count) > width)
            horizontal_copy_count -= width - x;

        if ((y + vertical_copy_count) > height)
            vertical_copy_count -= height - y;

        for (int y2 = 0; y2 != vertical_copy_count; y2++)
        {
            for (int x2 = 0; x2 != horizontal_copy_count; x2++)
            {
                auto dot = new_image.getDot(x2, y2);
                if (dot.enabled)
                    setDot(x + x2, y + y2, dot);
            }
        }
    }

    Image getImage(int x, int y, int width, int height)
    {
        assert(x >= 0);
        assert(y >= 0);
        assert(width >= 0);
        assert(height >= 0);

        Image ret = new Image(width, height);

        if (x > this.width || y > this.height)
            return ret;

        int actual_width = (x + width > this.width ? this.width - x : width);
        int actual_height = (y + height > this.height ? this.height - y : height);

        for (int x2 = 0; x2 != actual_width; x2++)
        {
            for (int y2 = 0; y2 != actual_height; y2++)
            {
                auto dot = getDot(x + x2, y + y2);
                ret.setDot(x2, y2, dot);
            }
        }

        return ret;
    }

    void printImage()
    {
        for (int y = 0; y != height; y++)
        {
            for (int x = 0; x != width; x++)
            {
                if (getDot(x, y).intensivity == 0)
                {
                    write(" ");
                }
                else
                {
                    write("*");
                }
            }
            writeln();
        }
        writeln();
    }

    // ------------------ DrawingSurface

    void drawDot(Position2D pos, ImageDot dot)
    {
        assert(pos.x >= 0);
        assert(pos.y >= 0);
        if (dot.enabled)
            setDot(pos.x, pos.y, dot);
    }

    bool canGetDot()
    {
        return true;
    }

    ImageDot getDot(Position2D pos)
    {
        assert(pos.x >= 0);
        assert(pos.y >= 0);
        return getDot(pos.x, pos.y);
    }

    void drawLine(Position2D pos, Position2D pos2, LineStyle style)
    {
        assert(pos.x >= 0);
        assert(pos.y >= 0);

        assert(pos2.x >= 0);
        assert(pos2.y >= 0);

        auto dots = calculateDotsInLine(pos, pos2);

        if (style.style == null)
        {
            foreach (v; dots)
            {
                auto id = ImageDot();
                id.color = style.color;
                id.enabled = true;
                id.intensivity = 1;
                drawDot(v, id);
            }
        }
        else
        {
            auto style_dup = style.style.dup();
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

    void drawRectangle(
        Position2D pos,
        Size2D size,
        LineStyle top_style,
        LineStyle left_style,
        LineStyle bottom_style,
        LineStyle right_style,
        Nullable!(FillStyle) fill_style
        )
    {
        debug writefln("drawing %s rectangle: %s %s", fill_style, pos, size);

        assert(pos.x >= 0);
        assert(pos.y >= 0);

        if (size.width <= 0 || size.height <= 0)
        {
            return;
        }

        // top+left
        auto p1_x = pos.x;
        auto p1_y = pos.y;
        // top+right
        auto p2_x = (p1_x + size.width) - 1;
        auto p2_y = p1_y;
        // bottom+right
        auto p3_x = p2_x;
        auto p3_y = (p2_y + size.height) - 1;
        // bottom+left
        auto p4_x = p1_x;
        auto p4_y = p3_y;

        drawLine(Position2D(p1_x, p1_y), Position2D(p2_x, p2_y), top_style);
        drawLine(Position2D(p1_x, p1_y), Position2D(p4_x, p4_y), left_style);
        drawLine(Position2D(p4_x, p4_y), Position2D(p3_x, p3_y), bottom_style);
        drawLine(Position2D(p2_x, p2_y), Position2D(p3_x, p3_y), right_style);

        if (size.width > 2 && size.height > 2)
        {
            if (!fill_style.isNull())
            {
                auto p1_x_p_1 = p1_x + 1;
                auto p2_x_m_1 = p2_x - 1;
                for (auto y = p1_y + 1; y < p4_y; y++)
                {
                    drawLine(Position2D(p1_x_p_1, y), Position2D(p2_x_m_1, y),
                            LineStyle(fill_style.get().color));
                }
            }
        }
    }

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

    void drawImage(Position2D pos, Image image)
    {
        putImage(pos.x, pos.y, image);
    }

    bool canGetImage()
    {
        return true;
    }

    Image getImage(Position2D pos, Size2D size)
    {
        return getImage(pos.x, pos.y, size.width, size.height);
    }

    bool canPresent()
    {
        return false;
    }

    void present()
    {
        throw new Exception("present() not supported");
    }

}

Position2D[] calculateDotsInLine(Position2D pos, Position2D pos2)
{

    int calc_y(int x_high, int x_low, int y_high, int y_low, int x)
    {
        auto x_razn = x_high - x_high;
        auto a = x_high - x;
        auto b = x_razn - a;
        auto c = (b != 0 ? x_razn / b : 0);
        auto d = y_high - y_low;
        auto e = (c != 0 ? d / c : 0);
        auto f = d - e;
        auto y = cast(int) lround(y_high - f);
        return y;
    }

    Position2D[] ret;
    bool is_x = ((pos2.x - pos.x) > (pos2.y - pos.y));
    // TODO: some unwize code - rework needed
    if (is_x)
    {
        for (int x = pos.x; x != pos2.x + 1; x++)
        {
            auto y = calc_y(pos2.x, pos.x, pos2.y, pos.y, x);
            ret ~= Position2D(x, y);
        }
    }
    else
    {
        for (int y = pos.y; y != pos2.y + 1; y++)
        {
            auto x = calc_y(pos2.y, pos.y, pos2.x, pos.x, y);
            ret ~= Position2D(x, y);
        }
    }
    return ret;
}
