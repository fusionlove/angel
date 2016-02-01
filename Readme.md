### Angel

Angel makes deploying to Elastic Beanstalk very easy... if you want to perform a select few actions.

At the moment they are:
- Creating multi-environment applications (web and worker tiers supported)
- Updating environment variables
- Easily managing dev, staging and production versions of the same application
- Deploying to multiple environments in parallel

Angel uses the AWS SDK for Ruby, which is apparently threadsafe. Use at your own risk.

#### Commands

First define your infrastructure and env vars in YAML. You can then run

````
angel create staging
angel deploy staging
angel setenv staging
````


