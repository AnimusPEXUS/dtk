module dtk.main;

import std.stdio;

import dtk.interfaces.PlatformI;

PlatformI instantiatePlatform()
{
    version (DTK_PLATFORM_SDL_DESKTOP)
    {
        import dtk.platforms.sdl_desktop.Platform;
        auto ret = new Platform();
        return ret;
    }
    else version (DTK_PLATFORM_GLFW_DESKTOP)
    {
        import dtk.platforms.glfw_desktop.Platform;
        auto ret = new Platform();
        return ret;
    }
    else version (DTK_PLATFORM_MOZILLA_WEB_EXTENSION)
    {
        import dtk.platforms.mozilla_web_extension.MozillaWebExtensionPlatform;
        auto ret = new MozillaWebExtensionPlatform();
        return ret;
    }
    else version (DTK_PLATFORM_MOZILLA_WEB_APPLICATION)
    {
        import dtk.platforms.mozilla_web_application.MozillaWebApplicationPlatform;
        auto ret = new MozillaWebApplicationPlatform();
        return ret;
    }
    else
    {
        static assert(false, "platform not supported");
    }
}
