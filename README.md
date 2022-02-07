<img alt="Rook" src="media/iperf-logo.png" width="20%" height="20%">

# iperfcon
iperfcon is for OpenShift/Kubernetes bandwidth testing the SDN network.
the iperf-client is working with the iperf-server container and outputs 
the iperf3 results summary after we run a GET command to the iperf-client 
route with the right values.

We can use it with different use cases:

- network bandwidth within the worker
- network bandwidth between 2 workers
- network bandwidth between a Worker and external Server

## Deploying iperfcon
There are 3 ways to deploy the iperfcon containers 

- Manually
- Ansible
- Operator

### Manually 
The usage of the containers is very simple.

First let's build the namespace for them:

    # oc new-project iperf

Clone the Github repository to your current working directory:

    # git clone https://github.com/randomparity/iperfcon.git

Switch to the new namespace (if you haven't already done so):

    # oc project iperf

Now let's run the deployment for both Deployments

The iperf-server container has 2 environment variables you can configure in the deployment:

   - IPERF_PROTOCOL - choose between TCP and UDP (default: TCP)
   - IPERF_PORT - choose the listening port of the iperf server (default: 5001)

    # oc create -f iperfcon/iperf-server/pod-deployment-antiaffinity.yaml

Now deploy the iperf-client:

    # oc create -f iperfcon/iperf-client/pod-deployment-antiaffinity.yaml

Deploy the services:

    # oc create -f iperfcon/iperf-client/service.yaml
    # oc create -f iperfcon/iperf-server/service.yaml

And deploy the route 

    # oc create -f iperfcon/iperf-client/route.yaml

#### Interval

For running checks in an interval and obtaining the output from the logs deploy iperf-check.

First lets edit the deployment YAML and make sure all the values are in place:

    # vi iperfcon/iperf-check/pod-deployment.yaml

Once we are done with the setting then we can run the deployment:

    # oc create -f iperfcon/iperf-check/pod-deployment.yaml

#### Exporter

Another way of getting the results is running the exporter pod and then have Prometheus obtain 
the result through the exporter:

    # oc create -f iperfcon/iperf-exportedr/pod-deployment.yaml

And create a service and a route for the iperf-exporter:

    # oc create -f iperfcon/iperf-exporter/service.yaml
    # oc create -f iperfcon/iperf-exporter/route.yaml

### Availability 

Now make sure the pods are deployed as you expected:

    # oc get pods -n iperf -o wide

### Cleanup

Cleanup the route, services, and project:

    # oc delete -f iperfcon/iperf-client/route.yaml
    # oc delete -f iperfcon/iperf-server/service.yaml
    # oc delete -f iperfcon/iperf-client/service.yaml
    # oc delete -f iperfcon/iperf-client/pod-deployment-antiaffinity.yaml
    # oc delete -f iperfcon/iperf-server/pod-deployment-antiaffinity.yaml
    # oc delete project iperf

### Ansible

The Ansible deployment is much easier, all we need to to is run the playbook from a station
connected to the OpenShift/Kubernetes cluster

First we need to clone the repository:

    # git clone https://github.com/randomparity/iperfcon.git

Next we will run the Ansible playbook from it's parent directory :

    # cd iperfconf/Ansible
    # ansible-playbook -i inventory main.yaml

Once the playbook is completed make sure the pods are deployed as you expected:

    # oc get pods -n iperf -o wide

### Operator

Will be modified in the near future...

## How to Use it
Now run the curl command to the route to get the results:

    # curl -X GET \
    http://iperf-client-router/iperf/api.cgi?server=iperf-server-service,port=5001,type=log,warnging=5000,critical=3000,format=M

The RESTAPI only expect a GET request with the following values:

- server - the iperf-server service IP address or name
- port - the port you are using on the iperf-server (the default is 5001)
- type - the type of output you want to see , that can be either "html" , "json" or "logs" (lowercase letters ONLY!!)
- format - the output format of bits we would want to see (K,M,G,T,k,m,g,t) 
- warning - the value on which the query will return warning in case the output is less then the given value and higher
then the value of "critical"
- critical - the value on which the query will return critical in case the output is less then the given value

If you want to look at the results in a nicer output you can pipe it to jq

    # curl -X GET  \
      http://iperf-client-router/iperf/api.cgi?server=iperf-server-service,port=5001,type=json,format=M,critical=3000,warnging=5000 | \
      jq

