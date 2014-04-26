ssh root@esx "vsish -e set /config/Cpu/intOpts/CoschedCostopThreshold 3000"
ssh root@esx "vsish -e set /config/Cpu/intOpts/CoschedCostartThreshold 2000"
ssh root@esx "vsish -e get /config/Cpu/intOpts/CoschedCostopThreshold"
ssh root@esx "vsish -e get /config/Cpu/intOpts/CoschedCostartThreshold"
