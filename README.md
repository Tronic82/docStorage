
## Architecture

In its simpelest form, the application is a Python flask web application hosted on Google CLoud Platform. The repository contains the ccode necessary to create a copy of this app in whichever project.
The basic Architecture Diagram can be found here [Computing resources with Load Balancer](https://lucid.app/documents/view/e2c2bd70-b4e4-43d6-a8ae-7b604640cf8b)

<div style="width: 640px; height: 480px; margin: 10px; position: relative;"><iframe allowfullscreen frameborder="0" style="width:640px; height:480px" src="https://lucid.app/documents/embedded/e2c2bd70-b4e4-43d6-a8ae-7b604640cf8b" id="KwZC9StwjJoi"></iframe></div>

### Components
The application consits of the following infratructure components:
* A global HTTP load Balancer. This load balancer uses a target HTTP proxy configured with a url that essentiall routes all traffic to the backend
* A global backend service. This backend currently only has one instance group as a backend
* A global HTTP health check. The same health check is used for both the backend instances as well as the backend service
* A regional instance group. This instance group builds instances in a single region and uses the health check to rebuild instances when they are not healthy. This group also has an autoscaler attached that autoscales the group to based on HTTP traffic
* A firestore database. This is used to store the metadata of the files being uploaded. Firestore was chosen as the metadata would arrive in a json format, which can be easily translated into a firestore instance. Firestore is also very quick when it comes to web and mobile components and querying the database via code is simple.
* A Google cloud storage bucket is used to store the uploaded documents. Cloud storage was chosen as the files uploaded can be any object, making cloud storage a good candidate for the application
* The application uses a docker image stored in Artifact Registry. Artifact Registry was chosen as it is the recommended tool for storing container images. It also has fine grained IAM permissioning, unlike container Registry

### Initial Set Up 
The project relies on a few manual set up to enable the project to work correctly. These are one time steps and once complete, the rest of the infrastructure is managed in code
1. Create a deployment service account that will run the deployment. This needs to be created by someone with the appropriate roles
2. Create a GCS bucket. It can be named anything but has to be unique. Make note of the bucket name
3. Assign the project editor role to the service account. This allows full access to all resources. This is overly permissive, but we can use the Google recommendation engine to assign only the roles it needs
4. Create a service account key. This will be used to authorize terraform to use this account to create the resources. NOTE: do not check in this key into source control. Doing so will expose the key to potentially malicious actors
5. Create the firestore instance, by enabling the api and selecting a region. Ensure to select firestore in native mode. NOTE: you wont be able to change this later
6. The first components can be created using terraform. Navigate to the terraform folder and add the bucket name to the backend.<environment> file. Then run

  ```
  ./runtf.sh development N
  ```

   This will initialise terraform using the development backend and tfvars files. The second arguement is whether to deploy or just plan. In this case we want to plan so input N (no)

7. if there is no errors and you are satisfied with the plan, run
```
./runtf.sh development Y
```
This will deploy the terraform infrastructure. This will create and set up:

  1. The VPC network
  2. The Storage bucket used for the application
  3. The application service account
  4. enable required APIs
  5. Create the firewall rules to enable traffic for the components as well as explicitly disable ingress and egress for any other communcation
  6. Create the KMS keys and assign the roles to the product service agents
  7. Assigns project level roles for the application service account.

Once above is complete, the last step wopuld be to configure private google access. This can be achieved by following [private google access](https://cloud.google.com/vpc/docs/configure-private-google-access#config)

