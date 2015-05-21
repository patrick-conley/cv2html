cv2html
=======

Translate a resume/CV written in LaTeX+moderncv into basic HTML.

It's a bit ugly; it's a bit brittle; it doesn't support many macros (right
now), but it does the trick.

Usage
-----

    cat cv.tex | cv2html > cv.html

Compiling
---------

    make all

Bison emits a warning about one shift/reduce conflict. The conflict is
unavoidable from from how moderncv treats `\cvlistitem` and
`\cvlistdoubleitem.` I'll try to avoid breeding more.

Supported TeX macros
--------------------

- `\cvitem`
- `\cvlistdoubleitem`
- `\cventry`
- `\section`
- `\url`
- `\newline`
- `\item` (in an itemize only)
- various character replacements

In `$`-delimited inline math:

- `\sim`
- `\times`

Deeply nested lists¹, or text with lots of paragraphs² do not work
properly. Unsupported macros, and their arguments, are simply ignored.

¹ Requires a stack of previous states  
² Requires reallocating memory

Dependencies
------------

gcc, flex, bison

lex/yacc support: untested  
version support: untested
