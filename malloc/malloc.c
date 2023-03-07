#include <stdbool.h>
#include <stdlib.h>
#include <assert.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include "malloc.h"
#include "printfmt.h"
#include <string.h>
#include <sys/mman.h>

#define BEST_FIT "first"  // No se debería definir asi el modo

#define MIN_SIZE 4
#define ALIGN4(s) (((((s) -1) >> 2) << 2) + 4)
#define REGION2PTR(r) ((r) + 1)
#define PTR2REGION(ptr) ((struct region *) (ptr) -1)
extern int errno;

void print_blocks_in_use(void);
bool first_fit(void);
bool best_fit(void);
bool malloc_in_initial_state(void);
int get_chunks_in_use_of_block(int block_num);

struct region {
	bool free;
	size_t size;
	struct region *next;
	int block;
};

#define ARRAY_SIZE 10
struct region *global_array[ARRAY_SIZE];

struct mapped_block {
	void *start;
	size_t size;
	int chunks_in_use;
};

bool
first_fit()
{
#ifdef FIRST_FIT
	return true;
#endif
	return false;
}

bool
best_fit()
{
#ifdef BEST_FIT
	return true;
#endif
	return false;
}

struct mapped_block blocks_info[10];


// Stats
int amount_of_mallocs = 0;
int amount_of_frees = 0;
int requested_memory = 0;
int blocks_created = 0;
int blocks_in_use = 0;
int memory_space_given = 0;  // use to check how much space was mapped

static void
print_statistics(void)
{
	printfmt("mallocs:   %d\n", amount_of_mallocs);
	printfmt("frees:     %d\n", amount_of_frees);
	printfmt("requested: %d\n", requested_memory);
	printfmt("blocks of memory: %d\n", blocks_created);
}
// Used to check test
bool
malloc_in_initial_state()
{
	bool initial_state = true;
	for (int i = 0; i < blocks_in_use; i++) {
		if (blocks_info[i].chunks_in_use > 0) {
			initial_state = false;
		}
	}
	return initial_state;
}

int
get_chunks_in_use_of_block(int block_num)
{
	return blocks_info[block_num].chunks_in_use;
}

// Used to check some stats when testing
void
print_blocks_in_use()
{
	printfmt("Blocks in use:\n");
	for (int i = 0; i < blocks_in_use; i++) {
		if (blocks_info[i].chunks_in_use > 0) {
			printfmt("chunk number : %i	Size: "
			         "%u.	chunks in use: %i , dir: %d\n",
			         i,
			         blocks_info[i].size,
			         blocks_info[i].chunks_in_use,
			         blocks_info[i].start);
		}
	}
	printfmt("\n");
}

// Used to check stats when testing , it gives all the info of the current space used
/*
static void
printFreeList()
{
        for (int i = 0; i < ARRAY_SIZE; i++) {
                if (global_array[i] != NULL &&
                    blocks_info[i].chunks_in_use > 0) {
                        struct region *next = global_array[i];
                        printfmt("Free list:\n");
                        while (next != NULL) {
                                printfmt("-dir: %d, size: %i, next: %d "
                                         ",block: %d \n",
                                         next,
                                         next->size,
                                         next->next,
                                         next->block);
                                next = next->next;
                        }
                        printfmt("\n\n");
                }
        }
}
*/
const size_t MAX_VALUE = 16 * 1024;            // 16 Kib
const size_t MAX_VALUE2 = 8 * 16 * 1024;       // 1 Mib
const size_t MAX_VALUE3 = 32 * 8 * 16 * 1024;  // 32 Mib
const size_t MAX_MEMORY_ALLOWED = 4 * 32 * 8 * 16 * 1024;


static bool
enough_space(size_t value_to_check)
{
	if (blocks_in_use == ARRAY_SIZE || value_to_check > MAX_VALUE3 ||
	    requested_memory + value_to_check > MAX_MEMORY_ALLOWED) {
		return false;
	} else {
		return true;
	}
}


static struct region *
find_free_region_by_first_fit(size_t requestedSize)
{
	int i = 0;
	bool found = false;
	struct region *next = NULL;
	while (i < ARRAY_SIZE && !found) {
		if (global_array[i] != NULL &&
		    blocks_info[i].chunks_in_use > 0 && !found) {
			next = global_array[i];
			while (!found && next != NULL) {
				if (next->size <
				    requestedSize + sizeof(struct region)) {
					next = next->next;
				} else {
					blocks_info[i].chunks_in_use++;
					found = true;
				}
			}
		}
		i++;
	}
	return next;
}

static struct region *
find_free_region_by_best_fit(size_t requestedSize)
{
	struct region *best_fit = NULL;
	int best_chunk = -1;

	struct region *next = NULL;
	for (int i = 0; i < ARRAY_SIZE; i++) {
		if (global_array[i] != NULL && blocks_info[i].chunks_in_use > 0) {
			next = global_array[i];
			while (next != NULL) {
				if (next->size > requestedSize +
				                         sizeof(struct region) &&
				    (best_fit == NULL ||
				     best_fit->size > next->size)) {
					best_fit = next;
					best_chunk = i;
				}
				next = next->next;
			}
		}
	}
	if (best_fit != NULL) {
		blocks_info[best_chunk].chunks_in_use++;
	}
	return best_fit;
}

// finds the next free region
// that holds the requested size
//
static struct region *
find_free_region(size_t requestedSize)
{
#ifdef FIRST_FIT  // Your code here for "first fit"
	return find_free_region_by_first_fit(requestedSize);
#endif

#ifdef BEST_FIT  // Your code here for "best fit"
	return find_free_region_by_best_fit(requestedSize);
#endif
}

static void *
find_free_region_pointer_to(void *ptr, int block)
{
	struct region *next = global_array[block];
	while (next != NULL && next->next != ptr) {
		next = next->next;
	}
	return next;
}


static struct region *
split(struct region *next, int requestedSize)
{
	int bloque = next->block;
	if ((next->size - requestedSize - sizeof(struct region)) >
	    sizeof(struct region) + MIN_SIZE) {
		char *temp_ptr =
		        (char *) next + sizeof(struct region) + requestedSize;
		if (global_array[bloque] == NULL || next == global_array[bloque] ||
		    blocks_info[bloque].chunks_in_use == 1) {
			global_array[bloque] = (struct region *) temp_ptr;
			global_array[bloque]->free = true;
			global_array[bloque]->size = next->size - requestedSize -
			                             sizeof(struct region);
			global_array[bloque]->next = NULL;
			global_array[bloque]->block = bloque;
		} else {
			struct region *previous =
			        find_free_region_pointer_to(next, bloque);
			struct region *new = (struct region *) temp_ptr;
			new->next =
			        next->next;  // aca trae problemas si es con realloc
			previous->next = new;
			new->free = true;
			new->size = next->size - requestedSize -
			            sizeof(struct region);
			new->block = previous->block;
		}

	} else if (global_array[bloque] != NULL) {
		global_array[bloque] = global_array[bloque]->next;
	}
	next->size = requestedSize + sizeof(struct region);
	next->free = false;
	return next;
}


static int
get_free_block_number()
{
	int i = 0;
	while (blocks_info[i].chunks_in_use != 0) {
		i++;
	}
	return i;
}

void *
malloc(size_t requestedSize)
{
	requestedSize = ALIGN4(requestedSize);
	if (requestedSize < 1) {
		errno = ENOMEM;
		return NULL;
	}

	// Checking the size of space we need to allocate
	size_t MAX;
	if (requestedSize < (unsigned) MAX_VALUE - sizeof(struct region)) {
		MAX = MAX_VALUE;
	} else if (((unsigned) MAX_VALUE - sizeof(struct region) < requestedSize) &&
	           (requestedSize < (unsigned) MAX_VALUE2 - sizeof(struct region))) {
		MAX = MAX_VALUE2;
	} else if (((unsigned) MAX_VALUE2 - sizeof(struct region) < requestedSize) &&
	           (requestedSize < (unsigned) MAX_VALUE3 - sizeof(struct region))) {
		MAX = MAX_VALUE3;
	} else {
		errno = ENOMEM;
		return NULL;  // size they ask is bigger than we can give
	}

	struct region *next;

	// aligns to multiple of 4 bytes
	// updates statistics
	amount_of_mallocs++;
	requested_memory += requestedSize + sizeof(struct region);
	next = find_free_region(requestedSize);
	// First time using malloc or we didnt find an useful free space we create a new block of memory if we can
	if (blocks_in_use == 0 || next == NULL) {
		if (blocks_in_use == ARRAY_SIZE) {
			return NULL;  // we dont have enough space
		}

		next = mmap(0,
		            MAX,
		            PROT_READ | PROT_WRITE,
		            MAP_PRIVATE | MAP_ANONYMOUS,
		            -1,
		            0);
		struct region *curr = (struct region *) next;
		curr->size = MAX;
		curr->next = NULL;
		curr->free = false;
		int block_number = get_free_block_number();
		curr->block = block_number;
		blocks_info[block_number].chunks_in_use = 0;
		blocks_info[block_number].chunks_in_use++;
		blocks_info[block_number].size = MAX;
		blocks_info[block_number].start = next;
		blocks_created++;
		blocks_in_use++;
	}

	next = split(next, requestedSize);

	return REGION2PTR(next);
}


static void
coalesceRegions(struct region *firstRegion)
{
	while (firstRegion != NULL && (char *) firstRegion + firstRegion->size ==
	                                      (char *) firstRegion->next) {
		struct region *secondRegion = firstRegion->next;
		firstRegion->size = firstRegion->size + secondRegion->size;
		firstRegion->next = secondRegion->next;
	}
}

static void
unmap_free_block(int block_num)
{
	if (blocks_info[block_num].chunks_in_use == 0) {
		int result = munmap(blocks_info[block_num].start,
		                    blocks_info[block_num].size);
		blocks_in_use--;
		if (result < 0) {
			printfmt("Rompio munmap\n");
			exit(-1);
		}
	}
}

void
free(void *ptr)
{
	// updates statistics
	amount_of_frees++;
	struct region *curr = PTR2REGION(ptr);
	assert(curr->free == 0);


	// Your code here
	// curr
	// hint: maybe coalesce regions?
	curr->free = true;
	int bloque = curr->block;
	requested_memory = requested_memory - curr->size;
	struct region *iterable = global_array[bloque];
	if (iterable != NULL) {
		if (curr < iterable) {
			curr->next = global_array[bloque];
			global_array[bloque] = curr;
			coalesceRegions(curr);
		} else {
			bool found_position = false;
			while (!found_position) {
				if (iterable->next == NULL || curr < iterable->next) {  // I'm in the last free region or next reason position is greater
					found_position = true;
				} else {
					iterable = iterable->next;
				}
			}
			// Now that position has been found:
			curr->next = iterable->next;
			iterable->next = curr;
			coalesceRegions(curr);
		}
	} else {
		global_array[bloque] = curr;
	}
	blocks_info[bloque].chunks_in_use -= 1;
	unmap_free_block(bloque);
	// print_blocks_in_use();
	// printFreeList();
	// printfmt("---------------------memoria despues de ser liberada %d\n", requested_memory);
}

void *
calloc(size_t nmemb, size_t size)
{
	size_t Tam = (nmemb * size);

	if (!enough_space(Tam + sizeof(struct region))) {
		errno = ENOMEM;
		return NULL;
	}

	void *ptr = malloc(Tam);
	memset(ptr,
	       0,
	       Tam - 1);  // We are not sure why we need the -1 but without it the program doesnt work
	return ptr;
}

void *
realloc(void *ptr, size_t size)
{
	if (!ptr) {
		return malloc(size);
	} else if (size == 0) {
		free(ptr);
		return;
	}

	struct region *curr = PTR2REGION(ptr);

	if (curr->size >= size + sizeof(struct region)) {
		return ptr;
	}

	void *ptr2 = malloc(size);
	if (!ptr2) {
		errno = ENOMEM;
		return NULL;
	}
	memcpy(ptr2, ptr, curr->size);
	free(ptr);
	return ptr2;
}
