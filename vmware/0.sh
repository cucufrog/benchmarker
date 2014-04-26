ssh root@esx "vsish -e set /config/Cpu/intOpts/CoschedCostopThreshold 0"
ssh root@esx "vsish -e set /config/Cpu/intOpts/CoschedCostartThreshold 0"
ssh root@esx "vsish -e get /config/Cpu/intOpts/CoschedCostopThreshold"
ssh root@esx "vsish -e get /config/Cpu/intOpts/CoschedCostartThreshold"
