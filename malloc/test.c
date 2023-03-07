#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include "malloc.h"
#include "printfmt.h"
#include <assert.h>


#define HELLO "hello from test"
#define TEST_STRING "FISOP malloc is working!"

const int SIZE_OF_STRUCT_REGION = 32;

void test_00(void);
void test_01(void);
void test_02(void);
void test_03(void);
void test_04(void);
void test_05(void);
void test_06(void);
void test_07(void);
void test_08(void);
void test_09(void);
void test_10(void);
void test_11(void);
void test_12(void);
void test_13(void);
void test_14(void);
void test_15(void);
void test_16(void);
void test_17(void);
void test_18(void);
void test_19(void);
void test_20(void);
void test_21(void);

void print_blocks_in_use(void);
_Bool first_fit();
_Bool best_fit();
_Bool malloc_in_initial_state(void);
int get_chunks_in_use_of_block(int block_num);

static void
check_malloc_is_in_initial_state()
{
	if (!malloc_in_initial_state()) {
		printfmt("Hubo un error en la liberacion de recursos del test "
		         "anterior");
		exit(1);
	}
}

// simple malloc and free test
void
test_00()
{
	printfmt("Running test 0:\n");
	char *var = malloc(100);
	if (var != NULL) {
		printfmt("Test 0 correct\n");
	} else {
		printfmt("Test 0 INCORRECT\n");
	}

	free(var);
}


// second_malloc_starts_inmediatly_after_first_malloc_end
void
test_01()
{
	printfmt("Running test 1:\n");
	int malloc_size = 100;
	char *var = malloc(malloc_size);
	char *var_2 = malloc(malloc_size);
	// If we dont do all this, this test doesnt work on some computers
	char str_malloc1[10];
	char str_size_expected[10];
	sprintf(str_malloc1, "%ld", var_2 - var);
	sprintf(str_size_expected, "%d", malloc_size + SIZE_OF_STRUCT_REGION);

	if (strcmp(str_size_expected, str_malloc1) == 0) {
		printfmt("First test correct\n");
		free(var);
		free(var_2);
	} else {
		printfmt("First test INCORRECT\n");
		printfmt("Expected: %s, Obtained: %s\n",
		         str_size_expected,
		         str_malloc1);
		free(var);
		free(var_2);
	}
}

// multiple_mallocs_start_inmediatly_after_previous_malloc_ends
void
test_02()
{
	printfmt("Running test 2:\n");
	int malloc_size = 100;
	char *var = malloc(malloc_size);
	char *var_2 = malloc(malloc_size);
	char *var_3 = malloc(malloc_size);
	char *var_4 = malloc(malloc_size);
	char *var_5 = malloc(malloc_size);
	char *var_6 = malloc(malloc_size);
	char *var_7 = malloc(malloc_size);
	char *var_8 = malloc(malloc_size);
	char *var_9 = malloc(malloc_size);
	char *var_10 = malloc(malloc_size);

	// If we dont do all this, this test doesnt work on some computers
	char str_size_expected[10];
	char str_comp1[10];
	char str_comp2[10];
	char str_comp3[10];
	char str_comp4[10];
	char str_comp5[10];
	char str_comp6[10];
	char str_comp7[10];
	char str_comp8[10];
	char str_comp9[10];

	sprintf(str_comp1, "%ld", var_2 - var);
	sprintf(str_comp2, "%ld", var_3 - var_2);
	sprintf(str_comp3, "%ld", var_4 - var_3);
	sprintf(str_comp4, "%ld", var_5 - var_4);
	sprintf(str_comp5, "%ld", var_6 - var_5);
	sprintf(str_comp6, "%ld", var_7 - var_6);
	sprintf(str_comp7, "%ld", var_8 - var_7);
	sprintf(str_comp8, "%ld", var_9 - var_8);
	sprintf(str_comp9, "%ld", var_10 - var_9);
	sprintf(str_size_expected, "%d", malloc_size + SIZE_OF_STRUCT_REGION);


	if (strcmp(str_size_expected, str_comp1) == 0 &&
	    (strcmp(str_size_expected, str_comp2) == 0) &&
	    (strcmp(str_size_expected, str_comp3) == 0) &&
	    (strcmp(str_size_expected, str_comp4) == 0) &&
	    (strcmp(str_size_expected, str_comp5) == 0) &&
	    (strcmp(str_size_expected, str_comp6) == 0) &&
	    (strcmp(str_size_expected, str_comp7) == 0) &&
	    (strcmp(str_size_expected, str_comp8) == 0) &&
	    (strcmp(str_size_expected, str_comp9) == 0)) {
		printfmt("Second test correct\n");

	} else {
		printfmt("Second test INCORRECT\n");
		printfmt("1)Obtained: %d, Expected: %d\n",
		         str_comp1,
		         str_size_expected);
		printfmt("2)Obtained: %d, Expected: %d\n",
		         str_comp2,
		         str_size_expected);
		printfmt("3)Obtained: %d, Expected: %d\n",
		         str_comp3,
		         str_size_expected);
		printfmt("4)Obtained: %d, Expected: %d\n",
		         str_comp4,
		         str_size_expected);
		printfmt("5)Obtained: %d, Expected: %d\n",
		         str_comp5,
		         str_size_expected);
		printfmt("6)Obtained: %d, Expected: %d\n",
		         str_comp6,
		         str_size_expected);
		printfmt("7)Obtained: %d, Expected: %d\n",
		         str_comp7,
		         str_size_expected);
		printfmt("8)Obtained: %d, Expected: %d\n",
		         str_comp8,
		         str_size_expected);
		printfmt("9)Obtained: %d, Expected: %d\n",
		         str_comp9,
		         str_size_expected);
	}
	free(var);
	free(var_2);
	free(var_3);
	free(var_4);
	free(var_5);
	free(var_6);
	free(var_7);
	free(var_8);
	free(var_9);
	free(var_10);
}

// second_malloc_uses_same_direction_than_first_if_first_is_freed_and_same_size
void
test_03()
{
	printfmt("Running test 3:\n");
	int malloc_size = 100;
	char *var = malloc(malloc_size);

	char *dir_Var = var;
	free(var);

	char *var_2 = malloc(malloc_size);
	char *dir_Var_2 = var_2;

	if (dir_Var == dir_Var_2) {
		printfmt("Third test correct\n");
		free(var_2);
	} else {
		printfmt("Third test INCORRECT\n");
		exit(1);
	}
}


// second_malloc_uses_same_direction_than_first_if_first_is_freed_despite_second_size_being_bigger
void
test_04()
{
	printfmt("Running test 4:\n");
	int first_malloc_size = 100;
	int second_malloc_size = 150;
	char *var = malloc(first_malloc_size);

	char *dir_Var = var;
	free(var);

	char *var_2 = malloc(second_malloc_size);
	char *dir_Var_2 = var_2;

	if (dir_Var == dir_Var_2) {
		printfmt("Fourth test correct\n");
		free(var_2);
	} else {
		printfmt("Fourth test INCORRECT\n");
		exit(1);
	}
}

// free in diferent order that malloc was made still coalesce correctly (i have
// no other way to test this other than checking the prints in malloc)
void
test_05()
{
	printfmt("Running test 5:");
	char *var_1 = malloc(100);
	strcpy(var_1, " ");
	char *var_2 = malloc(100);
	strcpy(var_2, " ");
	char *var_3 = malloc(100);
	strcpy(var_3, " ");
	printfmt("%s %s %s\n", var_1, var_2, var_3);
	free(var_1);
	free(var_3);
	free(var_2);
	printfmt("Fifth test correct (ponele, requiere hace print de "
	         "printFreeList) \n");
}

// Sending negative value to malloc returns in NULL
void
test_06()
{
	printfmt("Running test 6:\n");
	char *var = malloc(-1);
	if (var == NULL) {
		printfmt("Sixth test correct\n");
	} else {
		printfmt("Sixth test INCORRECT\n");
	}
}
// Creating asking for more than we can give return null (more than 32 Mbi
void
test_07()
{
	printfmt("Running test 7:\n");
	char *var = malloc(4194308);
	if (var == NULL) {
		printfmt("Seventh test correct\n");
	} else {
		printfmt("Seventh test INCORRECT\n");
	}
}

// Creating a new memory block
void
test_08()
{
	printfmt("Running test 8:\n");
	char *var_1 = malloc(16000);
	char *var_2 = malloc(160000);

	if (var_1 != NULL && var_2 != NULL) {
		printfmt("Eighth test correct\n");

	} else {
		printfmt("Eighth test INCORRECT\n");
	}
	free(var_1);
	free(var_2);
}

// Creating 3 memory blocks
void
test_09()
{
	printfmt("Running test 9:\n");
	char *var_1 = malloc(1600);
	char *var_2 = malloc(160000);
	char *var_3 = malloc(4100000);

	if (var_1 != NULL && var_2 != NULL && var_3 != NULL &&
	    get_chunks_in_use_of_block(0) == 1 &&
	    get_chunks_in_use_of_block(1) == 1 &&
	    get_chunks_in_use_of_block(2) == 1) {
		printfmt("Ninth test correct\n");

	} else {
		printfmt("Ninth test INCORRECT\n");
	}

	free(var_1);
	free(var_2);
	free(var_3);
}

void
test_10()
{
	printfmt("Running test 10:");
	char *var = malloc(100);  // Creo el primer bloque
	strcpy(var, ".");
	printfmt("%s", var);
	assert(get_chunks_in_use_of_block(0) == 1);

	char *var_2 = malloc(100);  // Creo otro chunk dentro del primer bloque
	strcpy(var_2, ".");
	printfmt("%s", var_2);
	assert(get_chunks_in_use_of_block(0) == 2);

	char *var_3 = malloc(16 * 1024 + 5);  // Creo el Segundo bloque
	strcpy(var_3, ".");
	printfmt("%s", var_3);
	assert(get_chunks_in_use_of_block(1) == 1);

	free(var);  // Libero primer chunk del primer bloque
	free(var_2);  // Libero segundo chunk del primer bloque, borrando el bloque directamente
	assert(get_chunks_in_use_of_block(0) == 0);

	char *var_4 = malloc(
	        100);  // Pido otro cacho de memoria, que pasa a estar en el segundo bloque que habia pedido
	strcpy(var_4, ".");
	printfmt("%s\n", var_4);
	assert(get_chunks_in_use_of_block(1) == 2);
	free(var_3);
	free(var_4);
	printfmt("Tenth test correct\n");
}

// simple calloc test
void
test_11()
{
	printfmt("Running test 11:\n");
	int *var = (int *) calloc(10, sizeof(int));
	if (var == NULL) {
		printfmt("Eleventh test INCORRECT\n");
	} else {
		printfmt("Eleventh test correct\n");
		free(var);
	}
}

// calloc can be created after a malloc
void
test_12()
{
	printfmt("Running test 12:\n");

	int *var_1 = malloc(100);
	int *var = (int *) calloc(3, sizeof(int));
	if (var == NULL || var_1 == NULL) {
		printfmt("Twelfth test INCORRECT\n");
		free(var_1);
	} else {
		printfmt("Twelfth test correct\n");
		free(var_1);
		free(var);
	}
}
//
// Check when calloc is created and then we create a malloc
void
test_13()
{
	printfmt("Running test 13:\n");

	int *var = (int *) calloc(10, sizeof(int));
	int *var_1 = malloc(100);
	if (var == NULL || var_1 == NULL) {
		printfmt("Thirteenth test INCORRECT\n");
	} else {
		printfmt("Thirteenth test correct\n");
		free(var_1);
		free(var);
	}
}

// Checking if we use the memory of the other blocks instead of creating new blocks
void
test_14()
{
	printfmt("Running test 14:\n");
	char *var_1 = malloc(1600);  // creates first block of memory
	assert(get_chunks_in_use_of_block(0) == 1);
	char *var_2 = malloc(17000);  // creates second block of memory
	assert(get_chunks_in_use_of_block(1) == 1);
	char *var_3 = malloc(150000);  // creates third block of memory
	assert(get_chunks_in_use_of_block(2) == 1);
	char *var_4 = malloc(160000);  // new chunk to the third block of memory
	assert(get_chunks_in_use_of_block(2) == 2);
	free(var_1);
	free(var_2);
	free(var_3);
	free(var_4);
	printfmt("Fourteenth test correct\n");
}

// Cheking if when given NULL Pointer it acts like malloc (it should create a block of memory, check stats)
void
test_15()
{
	printfmt("Running test 15:\n");
	char *var_1 = realloc(NULL, 100);
	if (var_1 == NULL) {
		printfmt("Fifteenth test INCORRECT\n");
	} else {
		printfmt("Fifteenth test correct\n");
		free(var_1);
	}
}
// Cheking if realloc of <= size takes the memory space of the original
void
test_16()
{
	printfmt("Running test 16:\n");
	char *var = malloc(200);
	char *dir1 = var;
	char *var_1 = realloc(var, 100);
	if (dir1 == var_1) {
		printfmt("Sixteenth test correct\n");
	} else {
		printfmt("Sixteenth test INCORRECT\n");
		printfmt("Realloc dir should be:%d\n", dir1);
		printfmt("Realloc dir is :%d\n", var_1);
	}
	free(var_1);
}

// realloc to a size bigger than the original
void
test_17()
{
	printfmt("Running test 17:\n");
	char *var = malloc(100);
	char *dir1 = var;

	char *var_1 = realloc(var, 200);
	if (dir1 == var_1) {
		printfmt("Seventeenth test INCORRECT\n");
	} else {
		printfmt("Seventeenth test correct\n");
	}
	free(var_1);
}
// realloc keeps the info from the original pointer
void
test_18()
{
	printfmt("Running test 18:\n");
	char *var = malloc(100);
	char *car = ".";
	strcpy(var, ".");
	char *var_1 = realloc(var, 200);
	if (*var_1 != *car) {
		printfmt("Eighteenths test INCORRECT\n");

	} else {
		printfmt("Eighteenths test correct\n");
	}
	free(var_1);
}

static void
test_first_fit()
{
	printfmt("Testing first fit\n");
	char *var_1 = malloc(100);
	char *var_2 = malloc(100);
	char *var_3 = malloc(80);
	char *var_4 = malloc(100);
	free(var_1);
	free(var_3);
	char *var_5 = malloc(70);
	if (var_1 == var_5) {
		printfmt("Nineteenth test (with first fit option) correct \n");
	} else {
		printfmt(
		        "Nineteenth test (with first fit option) INCORRECT \n");
	}
	free(var_2);
	free(var_4);
	free(var_5);
}

static void
test_best_fit()
{
	printfmt("Testing best fit\n");
	char *var_1 = malloc(100);
	char *var_2 = malloc(100);
	char *var_3 = malloc(80);
	char *var_4 = malloc(100);
	free(var_1);
	free(var_3);
	char *var_5 = malloc(70);
	if (var_3 == var_5) {
		printfmt("Nineteenth test (with best fit option) correct \n");
	} else {
		printfmt("Nineteenth test (with best fit option) INCORRECT \n");
	}
	free(var_2);
	free(var_4);
	free(var_5);
}

// Test chosen strategy (best fit or first fit)
void
test_19()
{
	printfmt("Running test 19:\n");
	if (first_fit()) {
		test_first_fit();
	} else if (best_fit()) {
		test_best_fit();
	}
}

// Reallocate to a smaller size
void
test_20()
{
	printfmt("Running test 20:\n");
	char *var_1 = malloc(100);
	char *var_2 = malloc(200);
	char *var_3 = malloc(100);
	char *var_4 = realloc(var_2, 100);
	char *dir1 = var_2;
	if (dir1 != var_4) {
		printfmt("Fail the reallocation\n");
		printfmt("dir del malloc original %s", dir1);
		printfmt("dir del realloc %s", var_4);
	} else {
		printfmt("Twentieth test correct\n");
	}
	free(var_1);
	free(var_3);
	free(var_4);
}

void
test_21()
{
	printfmt("Running test 21:\n");
	char *var_1 = malloc(100);
	char *var_2 = malloc(200);
	realloc(var_1, 0);
	free(var_2);
	check_malloc_is_in_initial_state();  // if realloc doesnt free var_1 then this should break
	printfmt("Twenty-first test correct\n");
}


int
main(void)
{
	printfmt("%s\n", HELLO);
	test_00();
	check_malloc_is_in_initial_state();
	test_01();
	check_malloc_is_in_initial_state();
	test_02();
	check_malloc_is_in_initial_state();
	test_03();
	check_malloc_is_in_initial_state();
	test_04();
	check_malloc_is_in_initial_state();
	test_05();
	check_malloc_is_in_initial_state();
	test_06();
	check_malloc_is_in_initial_state();
	test_07();
	check_malloc_is_in_initial_state();
	test_08();
	check_malloc_is_in_initial_state();
	test_09();
	check_malloc_is_in_initial_state();
	test_10();
	check_malloc_is_in_initial_state();
	test_11();
	check_malloc_is_in_initial_state();
	test_12();
	check_malloc_is_in_initial_state();
	test_13();
	check_malloc_is_in_initial_state();
	test_14();
	check_malloc_is_in_initial_state();
	test_15();
	check_malloc_is_in_initial_state();
	test_16();
	check_malloc_is_in_initial_state();
	test_17();
	check_malloc_is_in_initial_state();
	test_18();
	check_malloc_is_in_initial_state();
	test_19();
	check_malloc_is_in_initial_state();
	test_20();
	check_malloc_is_in_initial_state();
	test_21();
	return 0;
}
