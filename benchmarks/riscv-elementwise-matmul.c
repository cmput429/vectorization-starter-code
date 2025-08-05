#include <time.h> // time
#include <stdlib.h> // srand, rand
#include <stdio.h> // printf

// #include "gem5/m5ops.h" // m5_reset_stats

#define NUM_ELEMENTS 1000000

void elementwise_mul(int * restrict a, int * restrict b, int * restrict c) {
  for (int i = 0; i < NUM_ELEMENTS; i++) {
    c[i] = a[i] * b[i];
  }
}

void random_init(int *a) {
  for (int i = 0; i < NUM_ELEMENTS; i++) {
    a[i] = rand();
  }
}

int main() {
  int *a = (int *)malloc(NUM_ELEMENTS * sizeof(int));
  int *b = (int *)malloc(NUM_ELEMENTS * sizeof(int));
  int *c = (int *)malloc(NUM_ELEMENTS * sizeof(int));

  random_init(a);
  random_init(b);

  // m5_reset_stats(0, 0);
  elementwise_mul(a, b, c); // gather stats only for this
  // m5_dump_stats(0, 0);
  
  // check the result
  for (int i = 0; i < NUM_ELEMENTS; i++) {
    if (a[i] * b[i] != c[i]) {
      printf("Operation produced incorrect result at index %d!\n", i);
    }
  }

  printf("Elementwise multiplication complete.\n");
  free(a);
  free(b);
  free(c);
  return 0;
}
