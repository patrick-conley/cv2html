cv2html
=======

Translate a resume/CV written in LaTeX+moderncv into basic HTML.

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

Output contains the following tags:

- &lt;em&gt;
- &lt;strong&gt;
- &lt;span&gt;
- &lt;ul&gt;
- &lt;li&gt;
- &lt;p&gt;
- &lt;br&gt;

Dependencies
------------

gcc, flex, bison

lex/yacc support: untested  
version support: untested
