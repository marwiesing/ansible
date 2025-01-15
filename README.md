# ansible Lab:

https://github.com/spurin/diveintoansible-lab


# ansible Course Code Repository:
https://github.com/spurin/diveintoansible

# Google Cloud Shell:
https://diveinto.com/p/playground

#### Read me:

Dive Into Ansible Lab - GCP Cloudshell - Tutorial
DiveInto

This tutorial provides you with a fully working Ansible lab, accessible in your browser 🚀

Firstly, we'll clone the Dive Into Ansible lab. This is using a customised branch off the diveintoansible-lab repository that is A) preconfigured for use with Google cloudshell and B) has docker-compose preloaded in the bin directory (the default docker-compose on gcp cloudshell is too old). For convenience you can send this to the terminal using the convenient 'Copy to Cloud Shell' icon on the top right of the text box

git clone -b cloudshell-gcp \
    https://github.com/spurin/diveintoansible-lab.git \
    ${HOME}/diveintoansible-lab &> \
    /dev/null
cd ${HOME}/diveintoansible-lab && \
    git reset --hard &>/dev/null \
    && git pull --no-rebase &> \
    /dev/null
Launch the lab with the following commands -

cd ${HOME}/diveintoansible-lab; \
    bin/docker-compose up \
    --quiet-pull
When this completes, you'll see text similar to the following -

Attaching to centos2, ubuntu3, centos1, docker, ubuntu1, centos3, ubuntu2, ubuntu-c, portal
To access the Portal, click the Web Preview Icon, if you cant find it, click -> 
 for a walkthrough on where to find it.

Select 'Preview on Port 8080' and you're good to go!

When accessing terminals, the default credentials are ansible/password