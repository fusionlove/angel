### Angel

Angel makes deploying to Elastic Beanstalk very easy... if you want to perform a select few actions.

At the moment they are:
- Creating multi-environment applications (web and worker tiers supported)
- Updating environment variables
- Easily managing dev, staging and production versions of the same application
- Deploying to multiple environments in parallel

Angel uses the AWS SDK for Ruby, which is apparently threadsafe. Use at your own risk.

You do not need to have a folder set up with `eb init`. This allows several applications (such as staging and production versions) to be managed without rerunning `eb init` every time.


### Setup

Copy `angel` and `angel_support` into your `bin` folder or somewhere on your path.

Define `infra.yml` in the `infra` folder in your project root. This file defines the infrastructure. There is an example in `angel_support`.

To set complex options (like SQS URLs) with a custom name in `infra.yml`, define these mappings in `infra/mapping.yml` (see example in `angel_support`.

To set environment variables, put them in `env/staging.yml` for example, and make sure `./env/` is in `gitignore`.

#### Commands

First define your infrastructure and env vars in YAML. You can then run

````
angel create staging : creates environment
angel deploy staging : deploys environment
angel setenv staging : sets environment variables
angel setconfig staging
````


