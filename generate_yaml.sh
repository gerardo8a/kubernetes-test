#!/bin/bash
set -e

#Number of pods we want to run, default memory of each will be 4G (max so far is 25Mb per pod)
PODS=$1

#name of the VM to use for the pods
VM=$2

# This is the VM TOTAL size
VM_CPU=22
VM_MEMORY=256

if [ -z $VM ]; then
   echo "Need to pass VM name as second parameter"
   exit 1
fi

# Gets the VM number
regex="kubenode-vm([0-9]+).prod.*"
if [[ $VM =~ $regex ]]
  then
    VM_NUM=${BASH_REMATCH[1]}
  else
    echo "VM name does not contain number ie. kubenode-vm1.prod."
    exit 1
fi


CPU=$( printf "%.0f" $(echo $((VM_CPU/PODS))) )
MEMORY=$( printf "%.0f" $(echo $((VM_MEMORY/PODS))) )

echo "Number of pods: $PODS"
echo "CPU per pod: $CPU"
echo "Memory per pod: $MEMORY"
echo "VM Number: $VM_NUM"
echo

if [ ! -d "$VM" ]; then
   mkdir "$VM"
fi

BASE_PORT_NUM=8$VM_NUM
for num in $(eval echo {1..$PODS})
do
  PORT_NUMBER=$(printf "%d%02d" $BASE_PORT_NUM $num)
  ./podTemplate.sh $PORT_NUMBER $CPU $MEMORY $VM > $VM/fortio_${PORT_NUMBER}.yaml
done
