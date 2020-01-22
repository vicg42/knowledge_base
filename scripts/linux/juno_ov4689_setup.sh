#!/bin/bash
#
# authors:    Victor Golovachenko
#

SCRIPT_NAME=`basename "$0"`

BINNING=0
GAIN=0x003FFF
EXP=0x00BFF0
IRFILTER_ON=0
WB_GAIN_ON=0
TEST_PATTERN_ON=0
LED_LUMA=0

#---- Parser input arguments: begin
OPTIND=1

# Initialize our own variables:
while getopts "hb:g:e:i:w:t:L:" opt; do
    case "$opt" in
    b)  BINNING=$OPTARG
        ;;
    g)  GAIN=$OPTARG
        ;;
    e)  EXP=$OPTARG
        ;;
    i)  IRFILTER_ON=$OPTARG
        ;;
    w)  WB_GAIN_ON=$OPTARG
        ;;
    t)  TEST_PATTERN_ON=$OPTARG
        ;;
    L)  LED_LUMA=$OPTARG
        ;;
    *|h)
        echo "Usage: ./$SCRIPT_NAME [option]";
        echo "Mandatory option:";
        echo "    -h              help";
        echo "    -f  <value>     fps valid data 15/30. default=$BINNING";
        echo "    -g  <value>     gain value [hex]. default=$GAIN";
        echo "    -e  <value>     exposuren value [hex]. default=$EXP";
        echo "    -i  <value>     ir filter on/off. 1/0 - on/off. default=$IRFILTER_ON";
        echo "    -w  <value>     wb gain on/off. 1/0 - on/off. default=$WB_GAIN_ON";
        echo "    -t  <value>     test pattern on/off. 1/0 - on/off. default=$TEST_PATTERN_ON";
        echo "    -L  <value>     led luma value [dec]. default=$LED_LUMA";
        echo ""
        echo "Example: $SCRIPT_NAME -b 0";
        exit 0
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift
#----Parser input arguments: end


#if [ $WB_GAIN_ON -et 1 ]; then
#    echo "error: WB_GAIN_ON=$WB_GAIN_ON"
#    exit 1
#fi
#
#if [ $IRFILTER_ON -et 1 ]; then
#    echo "error: IRFILTER_ON=$IRFILTER_ON"
#    exit 1
#fi
#
#if [ $TEST_PATTERN_ON -et 1 ]; then
#    echo "error: IRFILTER_ON=$TEST_PATTERN_ON"
#    exit 1
#fi
#
#if [ $BINNING -et 2 ]; then
#    echo "error: BINNING=$BINNING"
#    exit 1
#fi

./ov4689_fr_size_ctrl -d /dev/i2c-2 -b $BINNING || exit 1
./ov4689_gain_set -d /dev/i2c-2 $GAIN || exit 1
./ov4689_exp_set -d /dev/i2c-2 $EXP || exit 1
./ov4689_wb_gain_on_off -d /dev/i2c-2 -m $WB_GAIN_ON || exit 1
./ov4689_test_pattern_on_off -d /dev/i2c-2 -m $TEST_PATTERN_ON || exit 1
./irfilter_ctrl -d /dev/spidev2.0 $IRFILTER_ON || exit 1
./irled_ctrl --luma $LED_LUMA || exit 1


echo " BINNING=$BINNING"
echo " GAIN=$GAIN"
echo " EXP=$EXP"
echo " WB_GAIN_ON=$WB_GAIN_ON"
echo " TEST_PATTERN_ON=$TEST_PATTERN_ON"
echo " IRFILTER_ON=$IRFILTER_ON"
echo " LED_LUMA=$LED_LUMA"

