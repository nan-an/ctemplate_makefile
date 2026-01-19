/**
 * Copied from some sources on internet. This is a clean ans simple header
 * for writing simple tests for your project.
 * This accompanied by ../src/tests.c give you a simple tool set to write
 * clear well defined test cases.
 * Cmake tests recognizes it clearly.
 */
#ifndef LITMUS_TESTS_H
#define LITMUS_TESTS_H
#include <stdarg.h>
#include <stdio.h>

#define KNRM "\x1B[0m"
#define KRED "\x1B[31m"
#define KGRN "\x1B[32m"
#define KYEL "\x1B[33m"
#define KBLU "\x1B[34m"
#define KMAG "\x1B[35m"
#define KCYN "\x1B[36m"
#define KWHT "\x1B[37m"

typedef enum FAILURE_OR_SUCCESS { FAILURE, SUCCESS } FOS;

typedef FOS (*TEST_FN)(void);
#define NUMARGS(...) (sizeof((TEST_FN[]){__VA_ARGS__}) / sizeof(TEST_FN))
/**
 * ASSERT macro
 */
#define ASSERT(X, MSG)                                                         \
  if (!(X)) {                                                                  \
    printf("%s[FAILURE] %s%s\n", KRED, MSG, KNRM);                             \
    goto FAIL;                                                                 \
  } else {                                                                     \
    printf("%s[SUCCESS] %s%s\n", KGRN, MSG, KNRM);                             \
  }
/**
 * a macro which takes in function name, and registers it as a test.
 * and starts the section for writing test definition.
 */
#define TEST_BEGIN(NAME)                                                       \
  FOS NAME(void) {                                                             \
    printf("******Running %s********************\n", #NAME);

/**
 * macro which closes the test definition
 */
#define TEST_END                                                               \
  printf("%sSUCCESS !!!!%s\n", KGRN, KNRM);                                    \
  return SUCCESS;                                                              \
  FAIL:                                                                        \
  printf("%sFAILURE !!!!\n%s", KRED, KNRM);                                    \
  return FAILURE;                                                              \
  }

/**
 * macro which needs to be called to actually run all the tests.
 */
#define RUN_TESTS(...)                                                         \
  int main(void) {                                                             \
    unsigned int count = NUMARGS(__VA_ARGS__);                                 \
    return run_tests(count, __VA_ARGS__);                                      \
  }

/**
 * Given a count and a list of test functions as a variadic argument, iterates
 * and runs those test functions.
 * @param count
 * @param ... list of function pointers of type TEST_FN.
 */
int run_tests(unsigned int count, ...) {
  va_list args;
  va_start(args, count);
  unsigned int success = 0;
  for (unsigned int i = 0; i < count; i++) {
    TEST_FN fn = va_arg(args, TEST_FN);
    if (fn()) {
      success++;
    }
  }
  printf("%s%d/%d OK%s\n", KGRN, success, count, KNRM);
  if (count - success) {
    printf("%s%d/%d Not OK%s\n", KRED, (count - success), count, KNRM);
    return 1;
  }
  return 0;
}

#endif
