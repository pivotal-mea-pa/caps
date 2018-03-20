# Infrastructure Automation Pipelines

## Overview

This repository contains deployment automation pipelines that can help launch scaled out production ready environments in the cloud. The automation tooling consist of [Terraform](https://www.terraform.io/) as the orchestrator and control plane for infrastructure services and [Concourse](http://concourse-ci.org/) for implementing operational workflows. Pipeline jobs may use a combination of configuration management tools to achieve their objective, but the primary configuration management tool used by the automation pipelines is [Bosh](http://bosh.io/).

For each environment at a minimum the following Day-1 and Day-2 Operations pipelines should be implemented.

* Bootstrap
* Install and Upgrade
* Backup and Restore
* Start and Stop

## Bootstrap

Every environment needs to be bootstraped. The bootstrap step paves the IaaS with the necessary pre-liminary services required for secured access to a logical Virtual Data Center (VDC) created for the environment. Bootstrapping is achieved via Terraform templates. This initial template contains all the required parameters that setup the rest of the automation workflows.

* [Pivotal Cloud Foundry 2.x](pcf/bootstrap)

## Install and Upgrade

* [Pivotal Cloud Foundry 2.x](pcf/install-and-upgrade)

## Backup and Restore

* [Pivotal Cloud Foundry 2.x](pcf/backup-and-restore)

## Start and Stop

* [Pivotal Cloud Foundry 2.x](pcf/start-and-stop)
