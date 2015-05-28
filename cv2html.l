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

<MATH>"\{"           { yylval.str = strdup("("); return TEXT; }
<MATH>"\}"           { yylval.str = strdup(")"); return TEXT; }

<MATH>\\sim          { yylval.str = strdup("~"); return TEXT; }
<MATH>\\times        { yylval.str = strdup("x"); return TEXT; }

<MATH>[^${}\\]+      { yylval.str = strdup(yytext); return TEXT; }

"\["                 { return LBRACKET; }
"\]"                 { return RBRACKET; }
"\{"                 { return LBRACE; }
"\}"                 { return RBRACE; }

"---"                { yylval.str = strdup("&#8212;"); return TEXT; }
"--"                 { yylval.str = strdup("&#8211;"); return TEXT; }
"-"                  { yylval.str = strdup(yytext); return TEXT; }

"\\ "                { yylval.str = strdup(" "); return TEXT; }
"\\@"                ; /* intersentence spacing */
"\\#"                { yylval.str = strdup("#"); return TEXT; }
"\\&"                { yylval.str = strdup("&amp;"); return TEXT; }
"\\\\"               ; /* newline (this version is ignored) */
"\\LaTeX"            { yylval.str = strdup("LaTeX"); return TEXT; }

\\begin\{itemize\}   { return LLIST; }
\\end\{itemize\}     { return RLIST; }
\\item               { return ITEM; }

\\makelettertitle    { return CVLETTEROPEN; }
\\makeletterclosing  { return CVLETTERCLOSE; }

\\section            { return SECTION; }
\\cvitem             { return CVITEM; }
\\cvlistdoubleitem   { return CVLIST; }
\\cventry            { return CVENTRY; }

\\(firstname|familyname|address|phone|email|opening|closing) { yylval.str = strdup(yytext); return CVDATA; }

\\newline            { yylval.str = strdup("<br>\n"); return TEXT; }
\\url                { return URL; }
\\\"\{\\i\}          { yylval.str = strdup("&iuml;"); return TEXT; }

<*>\\[a-z]+          { return MACRO; }

[^\[\]{}%$\\\-]+     { yylval.str = strdup(yytext); return TEXT; }

%%

