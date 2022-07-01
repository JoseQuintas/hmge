GuiDes README file
------------------

First time visitors please read the whole document.

-------------------
GuiDes installation
-------------------

First of all, unpack GUIDES.ZIP in any folder you like.

To build GuiDes you will need the following software to be
installed on your system:

   * Harbour 
   * MiniGUI
   * A C compiler and linker (BCC is preferred)

You must check if you have the MiniGui release that matches this GuiDes
release. If you have a source distribution, check GUIDES.CH to know which
GuiDes release you have and what MiniGUI release it is adapted to. If you
have a binary distribution, see main GUIDES window title.

If MiniGUI and GuiDes release numbers don't match you may still be able
to compile and run GuiDes. However, you may get unpredictable errors.

After that, if you are using Borland's C Compiler, you can build GuiDes by
typing at your prompt:

   MAKEBC

which should call Borland's MAKE utility with GUIDES.BC makefile.

I am sorry I can't provide makefiles for other compilers. If you write a
makefile for a different compiler, feel free to send it to me and I will
include it along with GuiDes.

If you experience problems during the build process, please check if
Harbour can find 'minigui.ch' and your C linker can find 'minigui.lib'.
You can detect any building errors by inspecting GUIDES.LOG.

If you get to build Guides, you can execute it by calling:

    GUIDES.EXE


------------
GuiDes usage
------------

You will find some usage instructions in the Help menu inside GuiDes.
I cannot provide longer and better explanations now.

