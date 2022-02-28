D graphical ToolKit
===================

About
-----

This is DTK (D graphical ToolKit).

Currently under heavy and deep development. It's far even to alpha.

DTK is thought to be highly portable, but currently it actually supports only SDL
backend.


Establishing Development Environment
------------------------------------

Basically, you'll have to 'git clone' repo somewhere and config local dub
to be able to find dtk.

Let's suppose you cloned dtk repo under directory /home/user/projects/dtk
(so /home/user/projects/dtk/README.md is file you are currently reading).

Now

1. go to ~/.dub/packages
2. and create file with name 'local-packages.json'
3. put text like this into 'local-packages.json' file:
```json
[
        {
                "name": "*",
                "path": "/home/user/dpath_work"
        }
]
```
4. create this '/home/user/dpath_work' directory and cd into it
5. now create symlink (with name 'dtk') to /home/user/projects/dtk

after succeeding steps above, the example project inside of examples/hello
should become buildable with 'dub build'.

NOTE: usually, I comment with 'compilable' commits which succeed in 'dub build'.
   currently not all commits to 'master' branch are compilable.

Dependencies
------------

Currently DTK depends at least on following things and their development files:

* SDL
* font-config
* freetype

The Project Structure
---------------------

DTK consists of three parts:
- backends
- portable part: dtk widgets and utilities
- lafs ([Look and Feel]s) - the visual themes

Backends - are all supposed to be places into src/dtk/platforms dir.

backends provide dtk with Platform and Window realizations. User supposed to
use Platform for some basic interactions with the system and for windows creation.

Window is Platform's specific decision to create and handle windows, dialogs
and pop-ups.

The portable part, is src/dtk/widgets and all the supplementary code for it's work.
