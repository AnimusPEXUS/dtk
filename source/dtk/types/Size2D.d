module dtk.types.Size2D;

struct Size2D
{
    int width;
    int height;
    /* int depth; */

    invariant {
        assert(width >= 0);
        assert(height >= 0);
    }
}
