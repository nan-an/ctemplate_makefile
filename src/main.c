#include <ctemplate/fns.h>
#include <stdio.h>

int main(void) {
  printf("%f + %f = %f", 1.0, 3.2, sum(1.0, 3.2));
  return 0;
}
