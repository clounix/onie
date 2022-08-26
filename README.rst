********************************
Open Network Install Environment
********************************

ONIE is a small operating system, pre-installed on bare
metal network switches, that provides an environment for automated
provisioning.

Read the `ONIE Documentation <https://opencomputeproject.github.io/onie>`_ for more info.

******************************
Mailing List and Collaboration
******************************

Join the conversation -- send questions, comments and ideas to OCP-ONIE@OCP-All.groups.io.

Subscribe to the list: `https://ocp-all.groups.io/g/OCP-ONIE <https://ocp-all.groups.io/g/OCP-ONIE>`_.

Browse the archives: `https://ocp-all.groups.io/g/OCP-ONIE/topics <https://ocp-all.groups.io/g/OCP-ONIE/topics>`_.

******************************
Steps to build ONIE
******************************

    $ ./build_env
    
    $ make -j40 MACHINEROOT=../machine/clounix/ MACHINE=clounix_clx8000_48c8d all
