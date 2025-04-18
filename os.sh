#!/bin/bash -e
################################################################################
##  File:  install-helpers.sh
##  Desc:  Helper functions for installing tools
################################################################################

function isUbuntu18
{
    lsb_release -d | grep -q 'Ubuntu 18'
}

function isUbuntu20
{
    lsb_release -d | grep -q 'Ubuntu 20'
}

function isUbuntu22
{
    lsb_release -d | grep -q 'Ubuntu 22'
}

function isUbuntu24
{
    lsb_release -d | grep -q 'Ubuntu 24'
}

function getOSVersionLabel
{
    lsb_release -cs
}