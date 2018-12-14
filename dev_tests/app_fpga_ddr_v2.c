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
,   {   "rdata"      , required_argument,      0,      '2'     }
,   {   "verbose"    , required_argument,      0,      'v'     }
,   {   0, 0, 0, 0 }
};

#define MODE_WRITE   1
#define MODE_READ    2
#define MODE_OFFSET  4

#define WR_CHUNK    64 //max 64

/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/


/************************** Variable Definitions *****************************/
char spi_name[64];
char app_name[128];
int verbose;

uint8_t  setup;
uint32_t ddr_adr;
uint32_t data_count;
uint32_t data[WR_CHUNK];
uint32_t verbose_count;

struct {
    char name[256];
    FILE *fd;
    uint32_t size;
} testfile;


/************************** Function Prototypes ******************************/
static inline void loadBar(int x, int n, int r, int w);


/******************************** main ***************************************/
int main (int argc, char *argv[])
{
    int fd;

    memset(spi_name, 0, sizeof(spi_name));
    memset(app_name, 0, sizeof(app_name));
    memset(testfile.name, 0, sizeof(testfile.name));
    memset(data, 0, sizeof(data));

    verbose = 0;
    ddr_adr = 0;
    data_count = 0;
    setup = MODE_READ;
    verbose_count = 0;

    int next = 0;
    do {
            switch (next = getopt_long(argc, argv, "hv:d:0:1:", long_opt_arr, 0)) {
            case 'd':
                    strcpy(spi_name, optarg);
                    break;
            case '0':
                    setup |= MODE_OFFSET;
                    ddr_adr = (uint32_t) strtol(optarg, NULL, 16);
                    break;
            case '1':
                    data_count = (uint32_t) strtol(optarg, NULL, 16);
                    setup &= ~MODE_READ;
                    setup |= MODE_WRITE;
                    break;
            case '2':
                    data_count = (uint32_t) strtol(optarg, NULL, 16);
                    break;
            case 'v':
                    verbose_count = (uint32_t) strtol(optarg, NULL, 10);
                    verbose = 1;
                    break;
            case -1:// no more options
                    break;
            case 'h':
                    strncpy(app_name, __FILE__, (strlen(__FILE__)-2));
                    printf("Usage: ./%s [option] <file>\n", app_name);
                    printf("Mandatory option: \n");
                    printf("    -h  --help              help\n");
                    printf("    -d  --device   <path>   linux device (juno /dev/spidev2.0)\n");
                    printf("        --addr     <value>  set register address [hex]\n");
                    printf("        --wdata    <value>  size write data[hex], if '0' - write full file\n");
                    printf("        --rdata    <value>  size read data[hex]\n");
                    printf("    -v  --verbose  <value>  value for view. ddr_adr % verbose_count\n");
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

    // process other arguments
    if (optind != argc) {
        strcpy(testfile.name, argv[optind]);

        if ((optind + 1) != argc) {
            printf("too many arguments\n");
            exit(EXIT_FAILURE);
        }
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

    size_t fd_read_remain;
    uint32_t readed;
    size_t progress_cur = 0;

    if (setup & MODE_WRITE) {

        testfile.fd = fopen(testfile.name, "rb");
        if (testfile.fd == NULL) {
            printf("error: can't open %s (try -h)\n",testfile.name);
            exit(EXIT_FAILURE);
        }

        //get file size
        fseek (testfile.fd, 0, SEEK_END);
        testfile.size = (uint32_t) ftell(testfile.fd);
        fseek (testfile.fd, 0, SEEK_SET);
        if (testfile.size % (WR_CHUNK * sizeof(data[0]))) {
            printf("\nerror: testfile.size\n");
            exit(EXIT_FAILURE);
        }

        if (data_count == 0) {
            fd_read_remain = testfile.size;
        } else {
            fd_read_remain = (size_t)data_count;
        }

        while (fd_read_remain != 0) {

            memset(data, 0, sizeof(data));

            readed = fread(data, sizeof(data[0]), WR_CHUNK, testfile.fd);
            if (WR_CHUNK != readed) {
                printf("\nerror: fread: WR_CHUNK=%d; readed=%d\n", WR_CHUNK, readed);
                exit(EXIT_FAILURE);
            }

            if (fpga_mem_usr_wr(fd, ddr_adr, data, WR_CHUNK) != 0) {
                printf("\nerror: fpga_mem_usr_wr\n");
                exit(EXIT_FAILURE);
            }

            if (verbose_count > 0) {
                if (!(ddr_adr % verbose_count)) {
                    printf("%s; ddr addr = 0x%08X; wdate = 0x%08X\n", spi_name, ddr_adr, data[0]);
                }
            }

            fd_read_remain -= (readed * sizeof(data[0]));
            ddr_adr += (readed * sizeof(data[0]));

        }

        printf("%s (size) : x%X (%d)byte; %6.3fMB\n", testfile.name, (int) testfile.size, (int) testfile.size, (float) ((float)testfile.size/1049576));
    }

    if (setup & MODE_READ) {
        testfile.fd = fopen(testfile.name, "wr+");
        if (testfile.fd == NULL) {
            printf("error: can't open %s (try -h)\n", testfile.name);
            exit(EXIT_FAILURE);
        }

        testfile.size = (size_t) data_count;

        fd_read_remain = testfile.size;
        while (fd_read_remain != 0) {

            memset(data, 0, sizeof(data));

            if (fpga_mem_usr_rd(fd, ddr_adr, data, WR_CHUNK) != 0) {
                printf("\nerror: fpga_mem_usr_rd\n");
                exit(EXIT_FAILURE);
            }

            if (verbose_count > 0) {
                if (!(ddr_adr % verbose_count)) {
                    printf("%s; ddr addr = 0x%08X; rdate = 0x%08X\n", spi_name, ddr_adr, data[0]);
                }
            }

            readed = fwrite(data, sizeof(data[0]), WR_CHUNK, testfile.fd);
            if (WR_CHUNK != readed) {
                printf("\nerror: fwrite: WR_CHUNK=%d; readed=%d\n", WR_CHUNK, readed);
                exit(EXIT_FAILURE);
            }

            fd_read_remain -= (readed * sizeof(data[0]));
            ddr_adr += (readed * sizeof(data[0]));
        }

        printf("%s (size) : x%X (%d)byte; %6.3fMB\n", testfile.name, (int) testfile.size, (int) testfile.size, (float) ((float)testfile.size/1049576));
    }


    fclose(testfile.fd);
    close(fd);
    exit(EXIT_SUCCESS);
}

