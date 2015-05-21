%{
#include "stdio.h"
#include "cv2html.tab.h"

int parent;
%}

%option yylineno

%x MATH
%s LIST

%%

[ \t\n]+             ;
%.*                  ;

<INITIAL>"$"         { BEGIN(MATH); parent = INITIAL; return DELIM; }
<LIST>"$"            { BEGIN(MATH); parent = LIST; return DELIM; }
<MATH>"$"            { BEGIN(parent); return DELIM; }

<MATH>"\{"           { yylval.str = "("; return TEXT; }
<MATH>"\}"           { yylval.str = ")"; return TEXT; }

<MATH>\\sim          { yylval.str = "~"; return TEXT; }
<MATH>\\times        { yylval.str = "x"; return TEXT; }

<MATH>[^${}\\]+      { yylval.str = strdup(yytext); return TEXT; }

"\["                 { return LBRACKET; }
"\]"                 { return RBRACKET; }
"\{"                 { return LBRACE; }
"\}"                 { return RBRACE; }

"---"                { yylval.str = "&#8212;"; return TEXT; }
"--"                 { yylval.str = "&#8211;"; return TEXT; }
"-"                  { yylval.str = strdup(yytext); return TEXT; }

"\\ "                { yylval.str = " "; return TEXT; }
"\\@"                ; /* intersentence spacing */
"\\#"                { yylval.str = "#"; return TEXT; }
"\\&"                { yylval.str = "&amp;"; return TEXT; }
"\\\\"               ; /* newline (this version is ignored) */

<INITIAL>\\begin\{itemize\}   { BEGIN(LIST); parent = INITIAL; return LLIST; }
<LIST>\\begin\{itemize\}      { BEGIN(LIST); parent = LIST; return LLIST; }
<LIST>\\end\{itemize\}        { BEGIN(parent); return RLIST; }
<LIST>\\item                  { return ITEM; }

\\section            { return SECTION; }
\\cvitem             { return CVITEM; }
\\cvlistdoubleitem   { return CVLIST; }
\\cventry            { return CVENTRY; }

\\newline            { yylval.str = "</br>\n"; return TEXT; }
\\url                { return URL; }
\\\"\{\\i\}          { yylval.str = "&iuml;"; return TEXT; }

<*>\\[a-z]+          { return MACRO; }

<INITIAL>[^\[\]{}%$\\\-]+  { yylval.str = strdup(yytext); return TEXT; }
<LIST>[^\[\]{}%\$\\\-]+    { yylval.str = strdup(yytext); return TEXT; }

%%

