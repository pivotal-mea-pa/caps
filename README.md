# Infrastructure Automation Pipelines

This repository contains deployment automation pipelines that can help launch scaled out production ready environments in the cloud. The automation tooling consist of [Terraform](https://www.terraform.io/) as the orchestrator and control plane for infrastructure services and [Concourse](http://concourse-ci.org/) for implementing operational workflows. Pipeline jobs may use a combination of configuration management tools to achieve their objective, but the primary configuration management tool used by the automation pipelines is [Bosh](http://bosh.io/).

For each product at a minimum the following Day-1 and Day-2 Operations pipelines should be implemented.

* Installations
* Upgrades
* Backup and Restore
* Start and Stop
