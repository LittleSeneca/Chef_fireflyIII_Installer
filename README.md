# firefly_iii

## Introduction
This Chef cookbook will automagically provision a FireFly III server on your
chef joined Ubuntu 20.04 Server. This tool was tested on Ubuntu 20.04, but should
work on other versions as well with a few modifications.

## Comments
This is a proof of concept, and was directly taken from the manual installation instructions
for FireFlyIII, found [here](https://docs.firefly-iii.org/firefly-iii/installation/self_hosted/).

There are multiple items which you will want to address prior to using this tool in your own environment. 
First, You will really want to change the default database password, found in default.rb, line 70. 
Second, You will also want to change the database password to match, located in env.erv, line 66. 

If I polish up this code, I will 100000% randomize that database password. But I'm too lazy right now. 

## Installation
If you are not familiar with how to use Chef, this tool may not be for you. But if you would like to 
learn how to use Chef, [I have a teaching tutorial series I made](https://blog.littleseneca.com/2020/11/16/operational-tutorial-chef-infra-part-1/), which will help. 

