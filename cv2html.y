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

struct contact info;

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

%type<str> section cvitem cventry cvdata cvlettertitle cvletterclose
%type<str> arg opt arg_contents
%type<str> math math_contents
%type<str> list listitems
%type<str> cvlist cvlistdoubleitems
%type<str> strings stringseq string url
%type<str> TEXT CVDATA

%%

contents : %empty
         | contents section         { printf("%s\n", $2); free($2); }
         | contents cvitem          { printf("%s\n", $2); free($2); }
         | contents cvlist          { printf("%s\n", $2); free($2); }
         | contents cventry         { printf("%s\n", $2); free($2); }
         | contents cvlettertitle   { printf("%s\n", $2); free($2); }
         | contents cvletterclose   { printf("%s\n", $2); free($2); }
         | contents list            { printf("%s\n", $2); free($2); }
         | contents string          { printf("%s", $2); free($2); }
         | contents cvdata
         | contents macro
         ;

section  : SECTION arg              { $$ = write_section($2); }

cvitem   : CVITEM opts arg arg           { $$ = write_cvitem($3, $4); }

cvlist   : cvlistdoubleitems        { $$ = write_list($1); }

cvlistdoubleitems : CVLIST opts arg arg
               /* Obvious shift/reduce conflict, but as cvlist types aren't at
                * all delimited, I don't think that's avoidable. An %empty
                * rule just makes it worse.
                */
                                    {
                                       $$ = add_listitem(NULL, $3);
                                       $$ = add_listitem($$, $4);
                                    }
         | cvlistdoubleitems CVLIST opts arg arg
                                    {
                                       $$ = add_listitem($1, $4);
                                       $$ = add_listitem($$, $5);
                                    }
         ;

cventry  : CVENTRY opts arg arg arg arg arg arg
                           {
                              $$ = write_cventry($3, $4, $5, $6, $7, $8);
                           }

cvlettertitle : CVLETTEROPEN arg
                           {
                              $$ = write_cvlettertitle(opening);
                              free($2);
                           }

cvletterclose : CVLETTERCLOSE arg
                           {
                              $$ = write_cvletterclose(closing, info);
                              free($2);
                           }

cvdata   : CVDATA arg      {
                              if (!strcmp($1, "\\opening")) {
                                 opening = $2;
                              } else if (!strcmp($1, "\\closing")) {
                                 closing = $2;
                              } else if (!strcmp($1, "\\firstname")) {
                                 info.firstname = $2;
                              } else if (!strcmp($1, "\\familyname")) {
                                 info.lastname = $2;
                              } else if (!strcmp($1, "\\phone")) {
                                 info.phone = $2;
                              } else if (!strcmp($1, "\\email")) {
                                 info.email = $2;
                              }
                           }
         | CVDATA arg arg  {
                              if (!strcmp($1, "\\address")) {
                                 info.address1 = $2;
                                 info.address2 = $3;
                              }
                           }
         ;

/* discarded */
macro    : MACRO opts args

/* discarded */
args     : %empty
         | args arg                    { free($2); }
         ;

arg      : LBRACE arg_contents RBRACE  { $$ = $2; }

/* discarded */
opts     : %empty
         | opts opt                    { free($2); }
         ;

opt      : LBRACKET arg_contents RBRACKET { $$ = $2; }

arg_contents   : %empty                { $$ = calloc(1,1); }
         | arg_contents string         { $$ = concatenate($1, $2); }
         | arg_contents list           { $$ = concatenate($1, $2); }
         ;

list     : LLIST listitems RLIST       { $$ = write_list($2); }

listitems    : %empty                  { $$ = calloc(1,1); }
         | listitems list              { $$ = concatenate($1, $2); }
         | listitems ITEM strings      { $$ = add_listitem($1, $3); }
         ;

strings  : %empty                      { $$ = calloc(1,1); }
         | strings string              { $$ = concatenate($1, $2); }
         ;

stringseq : %empty                     { $$ = calloc(1,1); }
         | stringseq TEXT              { $$ = concatenate($1, $2); }
         ;

string   : TEXT                        { $$ = split_paragraphs($1); }
         | math                        { $$ = $1; }
         | url                         { $$ = $1; }
         ;

math     : DELIM math_contents DELIM   { $$ = write_equation($2); }

math_contents : %empty                 { $$ = calloc(1,1); }
         | math_contents TEXT          { $$ = concatenate($1, $2); }
         ;

url      : URL LBRACE stringseq RBRACE { $$ = write_url($3); }
