#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <regex.h>

#include "macros.h"

char* write_section(char* arg) {
   char* open = "<p><p><strong><em>";
   char* close = "</em></strong>";

   char* out = malloc(strlen(open) + strlen(arg) + strlen(close) + 1);

   strcpy(out, open);
   strcat(out, arg);
   strcat(out, close);

   free(arg);

   return out;
}

char* write_cvitem(char* header, char* contents) {
   char* open = "<p><strong>";
   char* closeHeader = "</strong><br>\n";

   char* out =
      malloc(strlen(open) + strlen(header) + strlen(closeHeader) +
            strlen(contents) + 1);

   strcpy(out, open);
   strcat(out, header);
   strcat(out, closeHeader);
   strcat(out, contents);

   free(header);
   free(contents);

   return out;
}

char* write_list(char* contents) {
   char* open = "<ul>";
   char* close = "</ul>\n";

   char* out = malloc(strlen(open) + strlen(contents) + strlen(close) + 1);

   strcpy(out, open);
   strcat(out, contents);
   strcat(out, close);

   free(contents);

   return out;
}

char* write_cventry(char* date, char* title, char* group, char* place, char*
      note, char* contents) {
   char* format = "<p>%s<br>\n<strong>%s</strong>\n<em>%s</em>";

   char* out = malloc(strlen(date) + strlen(title) + strlen(group) +
         strlen(place) + strlen(note) + strlen(contents) + 46);

   sprintf(out, format, date, title, group);

   free(date);
   free(title);
   free(group);

   if (strlen(place)) {
      strcat(out, ",\n");
      strcat(out, place);
   }

   free(place);

   if (strlen(note)) {
      strcat(out, ",\n");
      strcat(out, note);
   }

   free(note);

   strcat(out, ".<br>\n");
   strcat(out, contents);

   free(contents);

   return out;
}

char* write_cvlettertitle(char* message) {
   char* out;

   if (message != NULL) {
      out = malloc(strlen(message) + 5);
      sprintf(out, "<p>%s\n", message);

      free(message);
   } else {
      out = malloc(1);
      out[0] = 0;
   }

   return out;
}

char* write_cvletterclose(char* message, struct contact info) {
   char* out;

   char* linebreak = "<br>\n";

   if (message == NULL) {
      out = strdup("<p>");
   } else {
      out = malloc(strlen(message) + strlen(linebreak) + 4);
      strcpy(out, "<p>");
      strcat(out, message);
      strcat(out, linebreak);
      free(message);
   }

   if (info.firstname != NULL && info.lastname != NULL) {
      out = realloc(out, strlen(out) + strlen(info.firstname) +
            strlen(info.lastname) + strlen(linebreak)*2 + 2);
      strcat(out, info.firstname);
      strcat(out, " ");
      strcat(out, info.lastname);
      strcat(out, linebreak);
      strcat(out, linebreak);
   }

   if (info.address1 != NULL) { /* implies addr2 != NULL) */
      out = realloc(out, strlen(out) + strlen(info.address1) +
            strlen(info.address2) + strlen(linebreak) + 1);
      strcat(out, info.address1);
      strcat(out, linebreak);
      strcat(out, info.address2);
      strcat(out, linebreak);
   }

   if (info.phone != NULL) {
      out = realloc(out, strlen(out) + strlen(info.phone) + strlen(linebreak)
            + 1);
      strcat(out, info.phone);
      strcat(out, linebreak);
   }

   if (info.email != NULL) {
      out = realloc(out, strlen(out) + strlen(info.email) + strlen(linebreak)
            + 1);
      strcat(out, info.email);
      strcat(out, linebreak);
   }

   return out;
}

char* write_equation(char* eqn) {
   char* open = "<em>";
   char* close = "</em>";

   char* out = malloc(strlen(eqn) + strlen(open) + strlen(close) + 1);

   strcpy(out, open);
   strcat(out, eqn);
   strcat(out, close);

   free(eqn);

   return out;
}

char* write_url(char* url) {
   char* open = "<em>";
   char* close = "</em>";

   char* out = malloc(strlen(url) + strlen(open) + strlen(close) + 1);

   strcpy(out, open);
   strcat(out, url);
   strcat(out, close);

   free(url);

   return out;
}

char* add_listitem(char* list, char* item) {
   int size = strlen(item) + 6;

   if (list == NULL) {
      list = malloc(size);
      list[0] = 0;
   } else {
      list = realloc(list, strlen(list) + size);
   }

   strcat(list, "<li>");
   strcat(list, item);
   strcat(list, "\n");

   free(item);

   return list;
}

char* concatenate(char* a, char* b) {
   a = realloc(a, strlen(a) + strlen(b) + 1);

   strcat(a, b);
   free(b);

   return a;
}

char* split_paragraphs(char* string) {
   char* p = "\n<p>";

   char* out = calloc(1,1);

   regex_t regex;
   regcomp(&regex, "\n\\s*\n", 0);

   // Find a blank line, print up to it, and replace it
   // with a paragraph break
   regmatch_t matches[1];
   int start = 0;
   while (!regexec(&regex, string+start, 1, matches, 0)) {
      // Prev paragraph ends at the start of a blank line
      string[start+matches[0].rm_so] = 0;

      out = realloc(out, strlen(out) + strlen(string+start) + strlen(p));
      strcat(out, string+start);
      strcat(out, p);

      // Next paragraph starts after the end of a blank line
      start += matches[0].rm_eo;
   }

   // Print trailing text
   if (strlen(string+start) > 0) {
      out = realloc(out, strlen(out) + strlen(string+start) + 1);
      strcat(out, string+start);
   }

   regfree(&regex);
   free(string);

   return out;
}
