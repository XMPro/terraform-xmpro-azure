#!/bin/bash

# Script to get the public IP address of the machine running Terraform
# This is used to create a firewall rule to allow access to the SQL server

# Use ipify.org API to get the public IP
PUBLIC_IP=$(curl -s https://api.ipify.org)

# Output the result in JSON format for Terraform external data source
echo "{\"public_ip\":\"$PUBLIC_IP\"}"
