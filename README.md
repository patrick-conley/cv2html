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

Very long strings (macro arguments, lists, equations, text with many
paragraphs) doesn't work properly (it requires I reallocate memory).

Dependencies
------------

gcc, flex, bison

lex/yacc support: untested  
version support: untested
