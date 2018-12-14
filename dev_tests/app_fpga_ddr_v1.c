 /*
 *  date:       01.08.2018 16:52:25
 *  authors:    Victor Golovachenko
 */
#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <fcntl.h>
#include <errno.h>
#include <linux/spi/spidev.h>
#include "linux_spi.h"
#include "fpga_mem.h"


/************************** Constant Definitions *****************************/
static const struct option long_opt_arr[] =
{   {   "help"       , no_argument      ,      0,      'h'     }
,   {   "device"     , required_argument,      0,      'd'     }
,   {   "addr"       , required_argument,      0,      '0'     }
,   {   "wdata"      , required_argument,      0,      '1'     }
,   {   0, 0, 0, 0 }
};
//,   {   "verbose"    , no_argument      ,      0,      'v'     }

#define MODE_WRITE   1
#define MODE_READ    2
#define MODE_OFFSET  4


/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Variable Definitions *****************************/
char spi_name[64];
char app_name[128];
int verbose;

uint8_t  setup;
uint32_t ddr_adr;
uint32_t ddr_wdata;
uint32_t ddr_rdata;


/************************** Function Prototypes ******************************/


/******************************** main ***************************************/
int main (int argc, char *argv[])
{
    int fd;

    memset(spi_name, 0, sizeof(spi_name));
    memset(app_name, 0, sizeof(app_name));

    verbose = 0;
    ddr_adr = 0;
    ddr_wdata = 0;
    ddr_rdata = 0;
    setup = MODE_READ;

    int next = 0;
    do {
            switch (next = getopt_long(argc, argv, "hd:0:1:", long_opt_arr, 0)) {
            case 'd':
                    strcpy(spi_name, optarg);
                    break;
            case '0':
                    setup |= MODE_OFFSET;
                    ddr_adr = (uint32_t) strtol(optarg, NULL, 16);
                    break;
            case '1':
                    ddr_wdata = (uint32_t) strtol(optarg, NULL, 16);
                    setup &= ~MODE_READ;
                    setup |= MODE_WRITE;
                    break;
//            case 'v':
//                    verbose = 1;
//                    break;
            case -1:// no more options
                    break;
            case 'h':
                    strncpy(app_name, __FILE__, (strlen(__FILE__)-2));
                    printf("Usage: ./%s [option]\n", app_name);
                    printf("Mandatory option: \n");
                    printf("    -h  --help              help\n");
                    printf("    -d  --device   <path>   linux device (juno /dev/spidev2.0)\n");
                    printf("        --addr     <value>  set register address [hex]\n");
                    printf("        --wdata    <value>  set register value[hex], if not set - get register value[hex]\n");
//                    printf("        --verbose       \n");
                    exit(EXIT_SUCCESS);
            default:
                    exit(EINVAL);
        };
    } while (next != -1);

    if (!( (setup & (MODE_WRITE | MODE_READ))
        && (setup & MODE_OFFSET)) ) {
        printf("error: set all need argument. (try -h)\n");
        exit(EXIT_FAILURE);
    }

    //initialization dev
    fd = open(spi_name, O_RDWR);
    if (fd < 0) {
        printf("error: open %s", spi_name);
        exit(EXIT_FAILURE);
    }

    if (linux_spi_init(fd, SPI_MODE_3) != 0) {
        printf("error: %s init\n", spi_name);
        exit(EXIT_FAILURE);
    }

    if (fpga_mem_init(fd) != 0) {
        printf("error: fpga_mem_init\n");
        exit(EXIT_FAILURE);
    }

//    if (verbose) {
//    printf("memctrl burst: chwr0 = %d, chwr1 = %d, chrd0 = %d\n", chwr0_burst, chwr1_burst, chrd0_burst);
//    }

    printf("%s; ", spi_name);
    printf("ddr addr = 0x%08X; ", ddr_adr);

    if (setup & MODE_WRITE) {
        if (fpga_mem_usr_wr(fd, ddr_adr, &ddr_wdata, 1) != 0) {
            printf("\nerror: fpga_mem_usr_wr\n");
            exit(EXIT_FAILURE);
        }
        printf("wdate = 0x%08X ", ddr_wdata);
    }

    if (setup & MODE_READ) {
        if (fpga_mem_usr_rd(fd, ddr_adr, &ddr_rdata, 1) != 0) {
            printf("\nerror: fpga_mem_usr_rd\n");
            exit(EXIT_FAILURE);
        }
        printf("rdate = 0x%08X ", ddr_rdata);
    }

    printf("\n");

    close(fd);
    exit(EXIT_SUCCESS);
}

