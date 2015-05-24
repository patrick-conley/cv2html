#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "macros.h"

char* section(char* arg) {
   char* open = "<p><p><strong><em>";
   char* close = "</em></strong>";

   char* out = malloc(strlen(open) + strlen(arg) + strlen(close) + 1);

   strcpy(out, open);
   strcat(out, arg);
   strcat(out, close);

   return out;
}

char* cvitem(char* header, char* contents) {
   char* open = "<p><strong>";
   char* closeHeader = "</strong><br>\n";

   char* out =
      malloc(strlen(open) + strlen(header) + strlen(closeHeader) +
            strlen(contents) + 1);

   strcpy(out, open);
   strcat(out, header);
   strcat(out, closeHeader);
   strcat(out, contents);

   return out;
}

char* cvlist(char* contents) {
   char* open = "<ul>";
   char* close = "</ul>";

   char* out = malloc(strlen(open) + strlen(contents) + strlen(close) + 1);

   strcpy(out, open);
   strcat(out, contents);
   strcat(out, close);

   return out;
}

char* cventry(char* date, char* title, char* group, char* place, char* note,
      char* contents) {
   char* format = "<p>%s<br>\n<strong>%s</strong>\n<em>%s</em>";

   char* out = malloc(strlen(date) + strlen(title) + strlen(group) +
         strlen(place) + strlen(note) + strlen(contents) + 46);

   sprintf(out, format, date, title, group);

   if (strlen(place)) {
      strcat(out, ",\n");
      strcat(out, place);
   }

   if (strlen(note)) {
      strcat(out, ",\n");
      strcat(out, note);
   }

   strcat(out, ".<br>\n");
   strcat(out, contents);

   return out;
}

char* cvletteropen(char* message) {
   char* out;

   if (message != NULL) {
      out = malloc(strlen(opening) + 5);
      sprintf(out, "<p>%s\n", opening);
   } else {
      out = malloc(1);
      out[0] = 0;
   }

   return out;
}

char* cvletterclose(char* message, char* first, char* last) {
   char* out;

   if (closing == NULL) {
      out = malloc(1);
      out[0] = 0;
   } else if (first != NULL && last != NULL) {
      out = malloc(strlen(closing) + strlen(first) + strlen(last) + 11);
      sprintf(out, "<p>%s<br>\n%s %s\n", closing, first, last);
   } else {
      out = malloc(strlen(closing) + 5);
      sprintf(out, "<p>%s\n", closing);
   }

   return out;
}
