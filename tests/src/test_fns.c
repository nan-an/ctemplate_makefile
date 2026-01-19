
#include <ctemplate/fns.h>
#include <litmus/tests.h>
#include <stdio.h>

TEST_BEGIN(sum_test)
ASSERT(sum(2, 3) == 5, "basic sum check.");
TEST_END

RUN_TESTS(sum_test)
