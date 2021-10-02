module dtk.types.fontinfo;

import dtk.types.Image;
import dtk.types.Size2D;
import dtk.types.Position2D;

struct FaceInfo
{
    bool on_fs;
    string on_fs_filename;

    ulong num_faces;
    ulong face_index;

    ulong num_glyphs;

    string family_name;
    string style_name;

    ulong num_charmaps;

    BoundingBox bounding_box;

    int ascender;
    int descender;
    int height;

    int max_advance_width;
    int max_advance_height;
}

/* struct FontStyle // NOTE: this probably will be needed in future
{
    Color fg_color;
    Color bg_color;
    ushort size;
    ushort dpi;
} */

struct GlyphMetrics
{
    Size2D size;
    Position2D horiBearing;
    Position2D vertBearing;
    Size2D advance;
}

enum GlyphFormat
{
    none,
    composite,
    bitmap,
    outline,
    plotter,
}

struct GlyphInfo
{
    FaceInfo* face_info;

    ulong glyph_index;

    GlyphMetrics metrics;

    long linear_horizontal_advance;
    long linear_vertical_advance;
    Position2D advance; // TODO: value type is questionable

    GlyphFormat glyph_format;

    long lsb_delta;
    long rsb_delta;
}

struct GlyphRenderResult
{
    GlyphInfo* glyph_info;

    Image bitmap;
    int bitmap_top;
    int bitmap_left;
}

struct BoundingBox
{
    Position2D min;
    Position2D max;
}
