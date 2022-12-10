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

#include <opae/utils.h>

#include "AFU.h"
// Contains application-specific information
#include "config.h"
// Auto-generated by OPAE's afu_json_mgr script
#include "afu_json_info.h"

#define CACHE_LINE_BYTES 64
#define NUM_CACHE_LINES 4096

using namespace std;


void printUsage(char *name);
bool checkUsage(int argc, char *argv[], unsigned long &num_tests);

int main(int argc, char *argv[]) {

  unsigned long num_tests;
  if (!checkUsage(argc, argv, num_tests)) {
    printUsage(argv[0]);
    return EXIT_FAILURE;
  }
  unsigned long size = CACHE_LINE_BYTES * NUM_CACHE_LINES;

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
      auto input  = afu.malloc<dma_data_t>(size*2);
      auto output  = &(input[size]);
      auto offset = output - input;

      cout << "Starting Test " << test << "...";

      // Initialize the input and output memory.
      for (unsigned i=0; i < size; i++) {
	input[i] = (dma_data_t) rand();
	output[i] = 0;
      }
    
      // Inform the FPGA of the starting read and write address of the arrays.
      afu.write(MMIO_RD_ADDR, (uint64_t) input);
      afu.write(MMIO_OFFSET_ADDR, (uint64_t) offset);

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
      int count = 0;
      unsigned errors = 0;
      for (unsigned i=0; i < size; i++) {
        if (i < size/2) {
          if (count < 4) {
            if (output[i] != input[i]) {
              errors++;
            }
          } else {
            if (output[i] != 0) {
              errors++;
            }
          }
        }
        else if (i < 3*size/4) {
          if (count < 4) {
            if (output[i] != input[i]) {
              errors++;
            }
          } else if (count == 4) {
            if (output[i]!=(input[i] & 0xf0)) {
              errors++;
            }
          } else {
            if (output[i] != 0) {
              errors++;
            }
          }
        }
        else {
          if (output[i] != input[i]) {
            errors++;
          }
        }
        if (count == 15) {
          count = 0;
        }
        else {
          count++;
        }
      }

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
		unsigned long &size, unsigned long &num_tests) {
  
  if (argc == 3) {
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
