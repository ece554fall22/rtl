// Copyright (c) 2020 University of Florida
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// Greg Stitt
// University of Florida
//
// Description: This application demonstrates a DMA AFU where the FPGA transfers
// data from an input array into an output array.
// 
// The example demonstrates an extension of the AFU wrapper class that uses
// AFU::malloc() to dynamically allocate virtually contiguous memory that can
// be accessed by both software and the AFU.

// INSTRUCTIONS: Change the configuration settings in config.h to test 
// different types of data.

#include <cstdlib>
#include <iostream>
#include <cmath>
#include <cstdio>

#include <opae/utils.h>

#include "AFU.h"
// Contains application-specific information
#include "config.h"
// Auto-generated by OPAE's afu_json_mgr script
#include "afu_json_info.h"

#define CACHE_LINE_BYTES 64
#define NUM_CACHE_LINES 9

using namespace std;


void printUsage(char *name);
bool checkUsage(int argc, char *argv[], unsigned long &num_tests);

int main(int argc, char *argv[]) {

  unsigned long num_tests;
  if (!checkUsage(argc, argv, num_tests)) {
    printUsage(argv[0]);
    return EXIT_FAILURE;
  }
//  unsigned long size = CACHE_LINE_BYTES * NUM_CACHE_LINES;
  unsigned long size  = NUM_CACHE_LINES * CACHE_LINE_BYTES;
  try {
    // Create an AFU object to provide basic services for the FPGA. The 
    // constructor searchers available FPGAs for one with an AFU with the
    // the specified ID
    AFU afu(AFU_ACCEL_UUID); 
    bool failed = false;

    for (unsigned test=0; test < num_tests; test++) {

      // Allocate memory for the FPGA. Any memory used by the FPGA must be 
      // allocated with AFU::malloc(), or AFU::mallocNonvolatile() if you
      // want to pass the pointer to a function that does not have the volatile
      // qualifier. Use of non-volatile pointers is not guaranteed to work 
      // depending on the compiler.   
      auto input  = afu.malloc<dma_data_t>(size);
      auto output  = input + size/2;
      auto offset = size/2;
      char* prev_output = (char*) malloc(sizeof(char) * NUM_CACHE_LINES * (CACHE_LINE_BYTES / 2));
      
      
      
      cout << "Starting Test " << test << "...";
  
      // Initialize the input and output memory.
      for (unsigned i=0; i < size; i++) {
	      input[i] = (dma_data_t) rand();
        if(i>=size/2) {
          input[i] = 0;
          prev_output[i-size/2] = (char) input[i];
        }
//	output[i] = 0;
      }
      input[0] = 0x00;
      input[1] = 0x00;
      input[2] = 0x00;
      input[3] = 0x10;
      input[4] = 0x00;
      input[5] = 0x00;
      input[6] = 0x00;
      input[7] = 0x12;
      input[8] = 0x00;
      input[9] = 0x00;
      input[10] = 0x10;
      input[11] = 0x14;
      input[12] = 0x40;
      input[13] = 0x00;
      input[14] = 0x10;
      input[15] = 0x16;
      input[16] = 0x00;
      input[17] = 0x00;
      input[18] = 0x00;
      input[19] = 0x00;
    
      // Inform the FPGA of the starting read and write address of the arrays.
      afu.write(MMIO_RD_ADDR, (uint64_t) input);
//      afu.write(MMIO_OFFSET_ADDR, (uint64_t) offset);
      afu.write(MMIO_OFFSET_ADDR, (uint64_t) offset);
   

      cout << "input[0]: " <<  input[0] << endl;
      cout << "output: " <<  output << endl;
      cout << " (uint_64_t) &input[0]: " << (uint64_t) &input[0] << endl;
      cout << "input: " << input << endl;
      cout << "offset: " << offset << endl;
      printf("-- input: %p output: %p\n", input, output);

      // The FPGA DMA only handles cache-line transfers, so we need to convert
      // the array size to cache lines.
     // unsigned total_bytes = size*sizeof(dma_data_t);
      //unsigned num_cls = ceil((float) total_bytes / (float) AFU::CL_BYTES);
      // afu.write(MMIO_SIZE, NUM_CACHE_LINES); Allison: size should always be 1, specified in afu

      // Start the FPGA DMA transfer.
      afu.write(MMIO_GO, 1);  

      // Wait until the FPGA is done.
      while (afu.read(MMIO_DONE) == 0) {
#ifdef SLEEP_WHILE_WAITING
	this_thread::sleep_for(chrono::milliseconds(SLEEP_MS));
#endif
      }
        
      // Verify correct output.
      // NOTE: This could be replaced with memcp, but that is only possible
      // when not using volatile data (i.e. AFU::mallocNonvolatile()). 
    unsigned errors = 0;
      if(input[64] !=0x10) {
         errors = 1;
         printf("you had but one task, but you have failed :(");
      }
    
/*      int count = 0;
      unsigned errors = 0;
      for (unsigned i=0; i < size/2; i++) {
        if (i < size/4) {
          if (count < 4) {
            if (output[i] != input[i]) {
              errors++;
              printf("size: %lu", size);
              printf("index: %d", i);
              printf("expected output 32bitW: %d output: %d", input[i], output[i]);
              printf("previous output 32bitW: %d\n", prev_output[i]);
            }
          } else if(output[i] != 0) {
              errors++;
              printf("size: %lu", size);
              printf("index: %d", i);
              printf("expected output 32bitW: %d output: %d", input[i], output[i]);
              printf("previous output 32bitW: %d\n", prev_output[i]);
          }
        } else if (i < 3*size/8) {
          if (count < 4) {
            if (output[i] != input[i]) {
              errors++;
              printf("size: %lu", size);
              printf("index: %d", i);
              printf("expected output 36bitW(data): %d output: %d\n", input[i], output[i]);
            }
          } else if (count == 4) {
            if (output[i]!=(input[i] & 0x0f)) {
              errors++;
              printf("size: %lu", size);
              printf("index: %d", i);
              printf("expected output 36bitW(mix): %d output: %d\n", (input[i] & 0xf0), output[i]);
            }
          } else if(output[i] != 0){
              errors++;
              printf("size: %lu", size);
              printf("index: %d", i);
              printf("expected output 36bitW(mix): %d output: %d\n", (input[i] & 0xf0), output[i]);
          }
        }
        else {
          if (output[i] != input[i]) {
            errors++;
            printf("size: %lu", size);
            printf("index: %d", i);
            printf("expected output 128bitW: %d output: %d\n", (input[i] & 0xf0), output[i]);
          }
        }
        if (count == 15) {
          count = 0;
        }
        else {
          count++;
        }
      }
 */
      if (errors > 0) {
	cout << "Failed with " << errors << " errors." << endl;
	failed = true;
      }
      else {
	cout << "Succeeded." << endl;
      }
    
      // Free the allocated memory.
      afu.free(input);
      afu.free(output);
    } 

    if (failed) {
      cout << "DMA tests failed." << endl;
      return EXIT_FAILURE;
    }

    cout << "All DMA Tests Successful!!!" << endl;
    return EXIT_SUCCESS;
  }
  // Exception handling for all the runtime errors that can occur within 
  // the AFU wrapper class.
  catch (const fpga_result& e) {    
    
    // Provide more meaningful error messages for each exception.
    if (e == FPGA_BUSY) {
      cerr << "ERROR: All FPGAs busy." << endl;
    }
    else if (e == FPGA_NOT_FOUND) { 
      cerr << "ERROR: FPGA with accelerator " << AFU_ACCEL_UUID 
	   << " not found." << endl;
    }
    else {
      // Print the default error string for the remaining fpga_result types.
      cerr << "ERROR: " << fpgaErrStr(e) << endl;    
    }
  }
  catch (const runtime_error& e) {    
    cerr << e.what() << endl;
  }
  catch (const opae::fpga::types::no_driver& e) {
    cerr << "ERROR: No FPGA driver found." << endl;
  }

  return EXIT_FAILURE;
}


void printUsage(char *name) {

  cout << "Usage: " << name << " size num_tests\n"     
       << "num_tests (positive integer amount of \"size\" DMA tests to run)" 
       << endl;
}

// Returns unsigned long representation of string str.
// Throws an exception if str is not a positive integer.
unsigned long stringToPositiveInt(char *str) {

  char *p;
  long num = strtol(str, &p, 10);  
  if (p != 0 && *p == '\0' && num > 0) {
    return num;
  }

  throw runtime_error("String is not a positive integer.");
  return 0;  
}


bool checkUsage(int argc, char *argv[], 
		 unsigned long &num_tests) {
  
  if (argc == 2) {
    try {
      num_tests = stringToPositiveInt(argv[1]);
    }
    catch (const runtime_error& e) {    
      return false;
    }
  }
  else {
    return false;
  }

  return true;
}
