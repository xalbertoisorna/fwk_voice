// Copyright 2017-2021 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include <xscope.h>
#include <stdlib.h>

#include "xscope_io_device.h"

//**** Multi tile pipeline structure ***//
// file_read -> stage1 (tile0_to_tile1) -> stage2 -> stage3 -> stage4 (tile1_to_tile0) -> file_write

extern "C" {
    extern void main_tile0(chanend c_t0_t1, chanend c_t1_t0, const char *input_file_name, const char* output_file_name);
    extern void main_tile1(chanend c_t0_t1, chanend c_t1_t0);
}

int main(){
    chan xscope_chan;
    chan c_tile0_to_tile1;
    chan c_tile1_to_tile0;

    par {
        xscope_host_data(xscope_chan);
        on tile[0]: 
        {
          xscope_io_init(xscope_chan);
          main_tile0(c_tile0_to_tile1, c_tile1_to_tile0, "input.wav", "output.wav");
          _Exit(0);
        }
        on tile[1]:
        {
            main_tile1(c_tile0_to_tile1, c_tile1_to_tile0);
        }
    }
    return 0;
}
