
char* section(char* arg);

char* cvitem(char* header, char* contents);

char* cvlist(char* contents);

char* cventry(char* date, char* title, char* group, char* place, char* note,
      char* contents);

char* cvletteropen(char* message);

char* cvletterclose(char* message, char* first, char* last);
