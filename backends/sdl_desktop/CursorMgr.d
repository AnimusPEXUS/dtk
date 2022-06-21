module dtk.backends.sdl_desktop.CursorMgr;

import std.stdio;
import std.format;

import bindbc.sdl;

import dtk.interfaces.MouseCursorMgrI;

import dtk.types.EnumMouseCursor;

// import dtk.platforms.sdl_desktop.Window;
import dtk.backends.sdl_desktop.Platform;

class CursorMgr : MouseCursorMgrI
{
    private SDL_Cursor*[SDL_SystemCursor] csrStorage;
    private Platform platform;

    this(Platform p)
    {
        platform = p;
    }

    SDL_SystemCursor EnumMouseCursor2SDL_SystemCursor(EnumMouseCursor type)
    {
        SDL_SystemCursor sdl_csr_id = SDL_SYSTEM_CURSOR_ARROW;
        with (EnumMouseCursor)
        switch (type)
        {
            default:
                // TODO: indicate error to program
                debug writeln("cursor not supported: %s".format(type));
                break;
            case crDefault:
                sdl_csr_id = SDL_SYSTEM_CURSOR_ARROW;
                break;
            /* case crText:
                break; */
            case crWait:
                sdl_csr_id = SDL_SYSTEM_CURSOR_WAIT;
                break;

            case crWResize:
            case crEResize:
                sdl_csr_id = SDL_SYSTEM_CURSOR_SIZEWE;
                break;

            case crNWResize:
            case crSEResize:
                sdl_csr_id = SDL_SYSTEM_CURSOR_SIZENWSE;
                break;

            case crNEResize:
            case crSWResize:
                sdl_csr_id = SDL_SYSTEM_CURSOR_SIZENESW;
                break;

            case crNResize:
            case crSResize:
                sdl_csr_id = SDL_SYSTEM_CURSOR_SIZENS;
                break;
        }
        return sdl_csr_id;
    }

    private SDL_Cursor* createIfNotYetSystemCursorByType(EnumMouseCursor type)
    {
        SDL_Cursor* ret;
        auto res = EnumMouseCursor2SDL_SystemCursor(type);
        if (res !in csrStorage)
        {
            auto sc = SDL_CreateSystemCursor(res);
            if (!sc)
            {
                platform.printSDLError();
                return null;
            }
            csrStorage[res] = sc;
        }
        debug writeln("createIfNotYetSystemCursorByType: cursor: %s".format(res));
        ret = csrStorage[res];
        return ret;
    }

    void setCursorByType(EnumMouseCursor type)
    {
        auto res = createIfNotYetSystemCursorByType(type);
        if (!res)
        {
            debug writeln("couldn't create system cursor for %s".format(type));
        }
        else
        {
            SDL_SetCursor(res);
        }
    }
}
