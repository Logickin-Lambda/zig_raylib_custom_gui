# There is Raygui, but Why?

This is definitely an odd choice why I decided to re-invent the wheel which consists of two reasons.

The first problem was the build system to emscripten. Since the 0.13.0 update, absolute path is forbidden, and I don't seem to find any working solution that works for emscripten for now. I do believe it is a problem from my lack of knowledge of the zig build system rather the problem of the binder, so I wanna put this away for awhile until the zig become stable and its build system become well documented.

In addition, even if I can load raygui into my project, some of the components are still missing for my planned applications; thus, I want to spend some time on learning how to properly build some custom components by reverse engineering the raygui library.

Thus, **PLEASE DON'T USE THIS LIBRARY** because it is solely for **education purpose** and you should use the original [raygui library](https://github.com/raysan5/raygui) or their bindings instead.