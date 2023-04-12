Demonstrates using Palette from Spectrocloud to: 
- Create an EKS cluster
  - Jenkins will be installed on the cluster
After some configuration of Jenkins:
- Make a change to the Dockerfile in example-app
  - Jenkins will notice the change and:
    - Create it's own virtual cluster
    - Spin up the app

To use this lab: 
- Fork the repository
- In the 'host-cluster' directory, copy terraform.tfvars.example to terraform.tfvars
- Edit terraform.tfvars, set cloud account and palette api key
- Load the required terraform modules with 'terraform init'
- Create the first cluster with 'terraform apply'
  - This will take 20-40 minutes depending on how the cloud is feeling at the moment
- Modify the Dockerfile in sample-app. Commit and push your changes to the repo
- Load the Jenkins UI to watch the Dockerfile change build, deploy and test. 
- Load the sample-app URL to see it, including your change, for yourself
