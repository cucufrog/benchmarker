rm log/*
fab -H vm1,vm2,vm3,vm4 cmd:"rm -rf ~/bench/parsec-3.0/log/*"
ssh root@esx "rm /vmfs/volumes/datastore1/log/*"
