#include "color_print.h"

#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>

/*
\e
\033
\x1B
*/


int vfprintfC(FILE * stream, const int color, const char * format, va_list ap)
{
	char * buffer;
	int retCode;
	buffer = malloc(sizeof(char) * (strlen(format) + 4*7)); // \e[106m
	buffer[0] = 0;
	
	int code_format = (color & 0xF0000) >> 16;
	int code_text = (color & 0x0FF00) >> 8;
	int code_background = (color & 0x000FF);

	if (code_format != 0)
		sprintf(buffer, "\e[%dm%s", code_format, buffer);
	if (code_text != 0)
		sprintf(buffer, "\e[%dm%s", code_text, buffer);
	if (code_background != 0)
		sprintf(buffer, "\e[%dm%s", code_background, buffer);
	
	//sprintf(buffer, "\e[%dm\e[%dm\e[%dm%s\e[0m", code_format, code_text, code_background, format);
	sprintf(buffer, "%s%s\e[0m", buffer, format);

	retCode = vfprintf(stream, buffer, ap);
	free(buffer);
	return retCode;
}

int fprintfC(FILE * stream, const int color, const char * format, ...)
{
	int ret_code;
	va_list ap;
	va_start(ap, format);
	ret_code = vfprintfC(stream, color, format, ap);
	va_end(ap);
	return ret_code;
}

int printfC(const int color, const char * format, ...)
{
	int ret_code;
	va_list ap;
	va_start(ap, format);
	ret_code = vfprintfC(stdout, color, format, ap);
	va_end(ap);
	return ret_code;
}