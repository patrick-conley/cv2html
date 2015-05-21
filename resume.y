%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <regex.h>

extern int yylineno;

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

%token TEXT
%token SECTION CVITEM CVLIST CVENTRY URL MACRO
%token DELIM
%token LLIST RLIST ITEM
%token LBRACE RBRACE LBRACKET RBRACKET

%type<str> TEXT strings string list items math arg opt stringseq url
%type<str> mathstrings cvlistitems

%%

contents : %empty
         | contents section
         | contents cvitem
         | contents cventry
         | contents cvlist
         | contents macro
         | contents string { printf("%s", $2); free($2); }
         ;

section  : SECTION arg     {
                              printf("<p><p><strong><em>%s</em></strong>\n", $2);
                              free($2);
                           }
         ;

cvitem   : CVITEM arg arg  {
                              printf("<p><strong>%s</strong><br>\n", $2);
                              printf("%s\n", $3);
                              free($2);
                              free($3);
                           }

cvlist   : cvlistitems     {
                              printf("<ul>%s</ul>", $1);
                              free($1);
                           }
         ;

cvlistitems : CVLIST arg arg
               /* Obvious shift/reduce conflict, but as cvlist types aren't at
                * all delimited, I don't think that's avoidable. */
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
         | cvlistitems CVLIST arg arg
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
                              printf("<p>%s<br>\n", $2);
                              printf("<strong>%s</strong>\n", $3);
                              printf("<em>%s</em>", $4);
                              if (strlen($5) || strlen($6) || strlen($7))
                                 printf(",");
                              printf("\n%s\n%s\n</br>\n%s\n", $5, $6, $7);
                              free($2);
                              free($3);
                              free($4);
                              free($5);
                              free($6);
                              free($7);
                           }

/* discarded */
macro    : MACRO opts args
         ;

/* discarded */
args     : %empty
         | args arg        { free($2); }
         ;

arg      : LBRACE strings RBRACE { $$ = $2; }
         ;

/* discarded */
opts     : %empty
         | opts opt        { free($2); }
         ;

/* discarded */
opt      : LBRACKET strings RBRACKET { $$ = $2; }
         ;

strings   : %empty         {
                              $$ = malloc(1000);
                              $$[0] = 0;
                           }
         | strings string  {
                              strcat($1, $2);
                              free($2);
                              $$ = $1;
                           }
         | strings list    {
                              strcat($1, $2);
                              $$ = $1;
                           }
         ;

list     : LLIST items RLIST
                           {
                              $$ = malloc(strlen($2)+10);
                              strcpy($$, "<ul>");
                              strcat($$, $2);
                              strcat($$, "</ul>");
                              free($2);
                           }
         ;

items    : %empty          {
                              $$ = malloc(1000);
                              $$[0] = 0;
                           }
         | items list      {
                              strcat($1, $2);
                              free($2);
                              $$ = $1;
                           }
         | items ITEM stringseq
                           {
                              strcat($1, "<li>");
                              strcat($1, $3);
                              strcat($1, "\n");
                              free($3);
                              $$ = $1;
                           }
         ;

stringseq : %empty         {
                              $$ = malloc(1000);
                              $$[0] = 0;
                           }
         | stringseq string
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

math     : DELIM mathstrings DELIM
                           {
                              $$ = malloc(strlen($2)+10);
                              strcpy($$, "<em>");
                              strcat($$, $2);
                              free($2);
                              strcat($$, "</em>");
                           }

mathstrings : %empty       {
                              $$ = malloc(1000);
                              $$[0] = 0;
                           }
         | mathstrings TEXT
                           {
                              strcat($1, $2);
                              $$ = $1;
                           }
         ;

url      : URL LBRACE stringseq RBRACE
                           { $$ = $3; }
         ;
