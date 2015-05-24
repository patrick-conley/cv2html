%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <regex.h>

#include "macros.h"

extern int yylineno;

char* opening = NULL;
char* closing = NULL;
char* firstname = NULL;
char* lastname = NULL;

void yyerror(const char *str)
{
   fprintf(stderr,"error: %d %s\n", yylineno, str);
}

int yywrap()
{
   return 1;
}

main()
{
   yyparse();
}

%}

%union {
   char* str;
}

%define parse.error verbose

%token SECTION CVLIST CVITEM CVENTRY CVLETTEROPEN CVLETTERCLOSE MACRO
%token LBRACE RBRACE LBRACKET RBRACKET
%token DELIM
%token LLIST RLIST ITEM
%token TEXT CVDATA URL

%type<str> section cvitem cventry cvdata cvletteropen cvletterclose
%type<str> arg opt arg_contents
%type<str> math math_contents
%type<str> list listitems
%type<str> cvlist cvlistdoubleitems
%type<str> strings string url
%type<str> TEXT CVDATA

%%

contents : %empty
         | contents section   { printf("%s\n", $2); free($2); }
         | contents cvitem    { printf("%s\n", $2); free($2); }
         | contents cvlist    { printf("%s\n", $2); free($2); }
         | contents cventry   { printf("%s\n", $2); free($2); }
         | contents cvletteropen    { printf("%s\n", $2); free($2); }
         | contents cvletterclose   { printf("%s\n", $2); free($2); }
         | contents list      { printf("%s\n", $2); free($2); }
         | contents string    { printf("%s", $2); free($2); }
         | contents cvdata
         | contents macro
         ;

section  : SECTION arg     { $$ = section($2); free($2); }

cvitem   : CVITEM arg arg  { $$ = cvitem($2, $3); free($2); free($3); }

cvlist   : cvlistdoubleitems  { $$ = cvlist($1); free($1); }

cvlistdoubleitems : CVLIST arg arg
               /* Obvious shift/reduce conflict, but as cvlist types aren't at
                * all delimited, I don't think that's avoidable. An %empty
                * rule just makes it worse.
                */
                           {
                              $$ = malloc(1000);
                              strcpy($$, "<li>");
                              strcat($$, $2);
                              strcat($$, "\n<li>");
                              strcat($$, $3);
                              strcat($$, "\n");
                              free($2);
                              free($3);
                           }
         | cvlistdoubleitems CVLIST arg arg
                           {
                              strcat($1, "<li>");
                              strcat($1, $3);
                              strcat($1, "\n<li>");
                              strcat($1, $4);
                              strcat($1, "\n");
                              free($3);
                              free($4);
                           }
         ;

cventry  : CVENTRY arg arg arg arg arg arg
                           {
                              $$ = cventry($2, $3, $4, $5, $6, $7);
                              free($2);
                              free($3);
                              free($4);
                              free($5);
                              free($6);
                              free($7);
                           }

cvletteropen : CVLETTEROPEN arg
                           {
                              $$ = cvletteropen(opening);
                              free($2);
                           }

cvletterclose : CVLETTERCLOSE arg
                           {
                              $$ = cvletterclose(closing, firstname, lastname);
                              free($2);
                           }

cvdata   : CVDATA arg      {
                              if (!strcmp($1, "\\opening")) {
                                 opening = $2;
                              } else if (!strcmp($1, "\\closing")) {
                                 closing = $2;
                              } else if (!strcmp($1, "\\firstname")) {
                                 firstname = $2;
                              } else if (!strcmp($1, "\\familyname")) {
                                 lastname = $2;
                              }
                           }

/* discarded */
macro    : MACRO opts args

/* discarded */
args     : %empty
         | args arg        { free($2); }
         ;

arg      : LBRACE arg_contents RBRACE { $$ = $2; }

/* discarded */
opts     : %empty
         | opts opt        { free($2); }
         ;

/* discarded */
opt      : LBRACKET arg_contents RBRACKET { $$ = $2; }
         ;

arg_contents   : %empty         {
                              $$ = malloc(1000);
                              $$[0] = 0;
                           }
         | arg_contents string  {
                              strcat($1, $2);
                              free($2);
                              $$ = $1;
                           }
         | arg_contents list    {
                              strcat($1, $2);
                              $$ = $1;
                           }
         ;

list     : LLIST listitems RLIST
                           {
                              $$ = malloc(strlen($2)+10);
                              strcpy($$, "<ul>");
                              strcat($$, $2);
                              strcat($$, "</ul>");
                              free($2);
                           }
         ;

listitems    : %empty          {
                              $$ = malloc(1000);
                              $$[0] = 0;
                           }
         | listitems list      {
                              strcat($1, $2);
                              free($2);
                              $$ = $1;
                           }
         | listitems ITEM strings
                           {
                              strcat($1, "<li>");
                              strcat($1, $3);
                              strcat($1, "\n");
                              free($3);
                              $$ = $1;
                           }
         ;

strings : %empty         {
                              $$ = malloc(1000);
                              $$[0] = 0;
                           }
         | strings string
                           {
                              strcat($1, $2);
                              free($2);
                              $$ = $1;
                           }
         ;

string   : TEXT      {
                        $$ = malloc(strlen($1)+21);
                        $$[0] = 0;
                        char* input = strdup($1);

                        regex_t regex;
                        regcomp(&regex, "\n\\s*\n", 0);

                        // Find a match, print up to it, and replace it
                        // with a paragraph break
                        regmatch_t matches[1];
                        int start = 0;
                        while (!regexec(&regex, input+start, 1, matches, 0)) {
                           input[start+matches[0].rm_so] = 0;
                           strcat($$, input+start);
                           strcat($$, "\n<p>");
                           start += matches[0].rm_eo;
                        }

                        // Print trailing text
                        if (strlen(input+start) > 0) {
                           strcat($$, input+start);
                        }

                        regfree(&regex);
                        free(input);
                     }
         | math            { $$ = $1; }
         | url             { $$ = $1; }
         ;

math     : DELIM math_contents DELIM
                           {
                              $$ = malloc(strlen($2)+10);
                              strcpy($$, "<em>");
                              strcat($$, $2);
                              free($2);
                              strcat($$, "</em>");
                           }

math_contents : %empty       {
                              $$ = malloc(1000);
                              $$[0] = 0;
                           }
         | math_contents TEXT
                           {
                              strcat($1, $2);
                              $$ = $1;
                           }
         ;

url      : URL LBRACE string RBRACE
                           {
                              $$ = malloc(strlen($3)+10);
                              strcpy($$, "<em>");
                              strcat($$, $3);
                              strcat($$, "</em>");
                              free($3);
                           }
         ;
