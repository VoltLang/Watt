module core.stdc.string;
extern (C):

void* memcpy(void* dest, scope const(void)* src, size_t n);
void* memmove(void* dest, scope const(void)* src, size_t n);
char* strcpy(char* dest, scope const(char)* src);
char* strncpy(char* dest, scope const(char)* src, size_t n);

char* strcat(char* dest, scope const(char)* src);
char* strncat(char* dest, scope const(char)* src, size_t n);

int memcmp(scope const(void)* ptr1, scope const(void)* ptr2, size_t n);
int strcmp(scope const(char)* str1, scope const(char)* str2);
int strcoll(scope const(char)* str1, scope const(char)* str2);
int strncmp(scope const(char)* str1, scope const(char)* str2, size_t n);

void* memchr(scope const(void)* ptr, int val, size_t n);
char* strchr(scope const(char)* str, int c);
size_t strcspn(scope const(char)* str1, scope const(char)* str2);
char* strpbrk(scope const(char)* str1, scope const(char)* str2);
char* strrchr(scope const(char)* str, int c);
size_t strspn(scope const(char)* str1, scope const(char)* str2);
char* strstr(scope const(char)* str1, scope const(char)* str2);
char* strtok(char* str, scope const(char)* delim);

void* memset(void* ptr, int v, size_t n);
char* strerror(int errnum);
size_t strlen(scope const(char)* str);
