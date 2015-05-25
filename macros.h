/*
 * All functions return the string result of their work. The return value is
 * allocated with malloc.
 *
 * Arguments are freed, except as noted. All arguments are required, except as
 * noted
 */

char* write_section(char* arg);

char* write_cvitem(char* header, char* contents);

char* write_list(char* contents);

char* write_cventry(char* date, char* title, char* group, char* place, char*
      note, char* contents);

char* write_cvlettertitle(char* message);

/*
 * firstname and familyname should be set first with \firstname and
 * \familyname, respectively. If either is null, then neither is printed.
 */
char* write_cvletterclose(char* message, char* firstname, char* familyname);

char* write_equation(char* eqn);

char* write_url(char* url);

/*
 * A list item, whether from \item, \cvlistitem, or \cvlistdoubleitem
 *
 * list: Partly-complete contents of the list. May be null. This pointer will
 *       become invalid only if the list was moved during a realloc().
 * item: Item to add
 */
char* add_listitem(char* list, char* item);

/*
 * Concatenate two strings, taking care of memory. *a will become invalid only
 * if the string was moved during a realloc().
 */
char* concatenate(char* a, char* b);

/*
 * Split a single string into multiple paragraphs on blank lines (those
 * matching /^\s*$/)
 *
 * In principle, this should be performed by the lexer, but LaTeX has the
 * annoying property that a newline means either nothing, or a paragraph
 * break, depending on its context. The grammar is least affected if I do it
 * here.
 */
char* split_paragraphs(char* string);
