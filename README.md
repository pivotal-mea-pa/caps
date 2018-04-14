# Cloud Automation Pipelines (CAPs)

## Overview

This repository contains deployment automation pipelines that can help launch scaled out production ready environments in the cloud. The automation tooling consist of [Terraform](https://www.terraform.io/) as the orchestrator and control plane for infrastructure services and [Concourse](http://concourse-ci.org/) for implementing operational workflows. Pipeline jobs may use a combination of configuration management tools to achieve their objective, but the primary configuration management tool used by the automation pipelines is [Bosh](http://bosh.io/).

A collection of utility scripts is provided in the `bin` folder to help manage multiple environments. Along with these scripts this repository is organized as follows.

```
.
├── bin           # Utility scripts for managing environments
├── deployments   # Deployments used to bootstrap environments
├── docs          # Additional documentation
├── lib           # Operations pipelines, scripts and templates
├── LICENSE      
└── README.md
```

Each environment is bootstrapped by an inception Virtual Private Cloud (VPC), which sets up optional infrastructure that will secure access to internal resources built via automation pipelines. 

## Usage

### Quick Start

To use this framework effectively a collection of shell scripts are provided. It is recommended to use a tool like [direnv](https://direnv.net/) to manage your local settings. 

### Advance Users

Advance users can extend the framework to override the default reference network as well as service configurations to create production ready environments.

## Bootstrap

Every environment needs to be bootstraped. The bootstrap step paves the IaaS with the necessary services required for secured access to a logical Virtual Data Center (VDC) created for the environment. Bootstrapping is achieved via Terraform templates. This initial template contains all the required parameters that setup the rest of the automation workflows. Bootstrapping is done by applying a  Terraform template that launches an inception Virtual Private Cloud which also acts as the DMZ layer for the rest of the deployed infrastructure.

Before you can bootstrap you need to build the bastion image which also acts as the engine that execute the initial environment setup automation workflows. These workflows may configure downstream automation infrastructure or for simpler non-production use cases may implement all the necessary automation for the environment.
