%{
#include "cv2html.tab.h"
%}

%option yylineno
%option warn

%x MATH

%%

[ \t\n]+             ;
%.*                  ;

<INITIAL>"$"         { BEGIN(MATH); return DELIM; }
<MATH>"$"            { BEGIN(INITIAL); return DELIM; }

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

\\begin\{itemize\}   { return LLIST; }
\\end\{itemize\}     { return RLIST; }
\\item               { return ITEM; }

\\makelettertitle    { return CVLETTEROPEN; }
\\makeletterclosing  { return CVLETTERCLOSE; }

\\section            { return SECTION; }
\\cvitem             { return CVITEM; }
\\cvlistdoubleitem   { return CVLIST; }
\\cventry            { return CVENTRY; }

\\firstname          { yylval.str = strdup(yytext); return CVDATA; }
\\familyname         { yylval.str = strdup(yytext); return CVDATA; }
\\opening            { yylval.str = strdup(yytext); return CVDATA; }
\\closing            { yylval.str = strdup(yytext); return CVDATA; }

\\newline            { yylval.str = "</br>\n"; return TEXT; }
\\url                { return URL; }
\\\"\{\\i\}          { yylval.str = "&iuml;"; return TEXT; }

<*>\\[a-z]+          { return MACRO; }

[^\[\]{}%$\\\-]+     { yylval.str = strdup(yytext); return TEXT; }

%%

