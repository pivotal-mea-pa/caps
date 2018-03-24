# Infrastructure Automation Pipelines

## Overview

This repository contains deployment automation pipelines that can help launch scaled out production ready environments in the cloud. The automation tooling consist of [Terraform](https://www.terraform.io/) as the orchestrator and control plane for infrastructure services and [Concourse](http://concourse-ci.org/) for implementing operational workflows. Pipeline jobs may use a combination of configuration management tools to achieve their objective, but the primary configuration management tool used by the automation pipelines is [Bosh](http://bosh.io/).

For each environment at a minimum the following Day-1 and Day-2 Operations pipelines would be implemented.

* Bootstrap
* Install and Upgrade
* Backup and Restore
* Start and Stop
* Monitoring

## Bootstrap

Every environment needs to be bootstraped. The bootstrap step paves the IaaS with the necessary services required for secured access to a logical Virtual Data Center (VDC) created for the environment. Bootstrapping is achieved via Terraform templates. This initial template contains all the required parameters that setup the rest of the automation workflows.

Before you can bootstrap you need to build the bastion image which also acts as the engine that execute the initial environment setup automation workflows. These workflows may configure downstream automation infrastructure or for simpler non-production use cases may implement all the necessary automation for the environment.
