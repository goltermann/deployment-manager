# Deployment Manager

[![Go Report Card](http://goreportcard.com/badge/kubernetes/deployment-manager)](http://goreportcard.com/report/kubernetes/deployment-manager)

Deployment Manager (DM) provides parameterized templates for Kubernetes clusters.

You can use it deploy ready-to-use types, such as:
* [Replicated Service](types/replicatedservice/v1)
* [Redis](types/redis/v1)

Types live in ordinary Github repositories. This repository contains the DM
code, but also acts as a DM type registry.

You can also use DM to deploy simple templates that use types, such as:

* [Guestbook](examples/guestbook/guestbook.yaml)
* [Deployment Manager](examples/bootstrap/bootstrap.yaml)

A template is just a `YAML` file that supplies parameters. (Yes, you're reading
that second example correctly. It uses DM to deploy itself.
See [examples/bootstrap/README.md](examples/bootstrap/README.md) for more information.)

DM runs server side, in your Kubernetes cluster, so it can tell you what types
you've instantiated there, what instances you've created of a given type, and even
how the instances are organized. So, you can ask questions like:

* What Redis instances are running in this cluster?
* What Redis master and slave services are part of this Redis instance?
* What pods are part of this Redis slave?

Because DM stores its state in the cluster, not on your workstation, you can ask
those questions from any client at any time.

Please hang out with us in
[the Slack chat room](https://kubernetes.slack.com/messages/sig-configuration/)
and/or
[the Google Group](https://groups.google.com/forum/#!forum/kubernetes-sig-config)
for the Kubernetes configuration SIG. Your feedback and contributions are welcome.

## Installing Deployment Manager

Follow these 3 steps to install DM:

1. Make sure your Kubernetes cluster is up and running, and that you can run
`kubectl` commands against it.
1. Clone this repository into the src folder of your GOPATH, if you haven't already.
See the [Kubernetes docs](https://github.com/kubernetes/kubernetes/blob/master/docs/devel/development.md)
for how to setup Go and the repos.
1. Use `kubectl` to install DM into your cluster:

```
kubectl create -f install.yaml
```

That's it. You can now use `kubectl` to see DM running in your cluster:

```
kubectl get pod,rc,service
```

If you see expandybird-service, manager-service, resourcifier-service, and
expandybird-rc, manager-rc and resourcifier-rc with pods that are READY, then DM
is up and running!

The easiest way to interact with Deployment Manager is through `kubectl` proxy:

```
kubectl proxy --port=8001 &
```

This command starts a proxy that lets you interact with the Kubernetes api
server through port 8001 on localhost. `dm` uses
`http://localhost:8001/api/v1/proxy/namespaces/default/services/manager-service:manager`
as the default service address for DM.

## Using Deployment Manager

You can use `dm` to deploy a type from the command line:

1. You will need to first build it by running `make` from the deployment-manager
repo.
1. You should also ensure you've run the `kubectl proxy` command from the
section above so that the `dm` commandline tool can reach the DM service in your
Kubernetes cluster.

This command deploys a
redis cluster with two workers from the type definition in this repository:

```
dm deploy redis/v1
```

When you deploy a type, you can optionally supply values for input parameters,
like this:

```
dm --properties workers=3 deploy redis/v1
```

When you deploy a type, `dm` generates a template from the type and input 
parameters, and then deploys it. 

You can also deploy an existing template, or read one from `stdin`. This command
deploys the canonical Guestbook example from the examples directory:

```
dm deploy examples/guestbook/guestbook.yaml
```

You can now use `kubectl` to see Guestbook running:

```
kubectl get service
```

Look for frontend-service. If your cluster supports external load balancing, it
will have an external IP assigned to it, and you can navigate to it in your browser
to see the guestbook in action. 

For more information about this example, see [examples/guestbook/README.md](examples/guestbook/README.md)

## Additional commands

The command line tool makes it easy to configure a cluster from a set of predefined
types. Here's a list of available commands:

```
expand              Expands the supplied template(s)
deploy              Deploys the supplied type or template(s)
list                Lists the deployments in the cluster
get                 Retrieves the supplied deployment
delete              Deletes the supplied deployment
update              Updates a deployment using the supplied template(s)
deployed-types      Lists the types deployed in the cluster
deployed-instances  Lists the instances of the supplied type deployed in the cluster
types               Lists the types in the current registry
describe            Describes the supplied type in the current registry

```

## Uninstalling Deployment Manager

You can uninstall Deployment Manager using the same configuration file:

```
kubectl delete -f install.yaml
```

## Creating a type registry

All you need to create a type registry is a Github repository with top level file
named `registry.yaml`, and a top level folder named `types` that contains type definitions. 

A type definition is just a folder that contains one or more versions, like `/v1`, 
`/v2`, etc.

A version is just a folder that contains a type definition. As you can see from the
examples above, a type definition is just a Python or [Jinja](http://jinja.pocoo.org/)
file plus an optional schema.

## Building the container images

This project runs Deployment Manager on Kubernetes as three replicated services.
By default, install.yaml uses prebuilt images stored in Google Container Registry
to install them. However, you can build your own container images and push them
to your own project in the Google Container Registry: 

1. Set the environment variable PROJECT to the name of a project known to gcloud.
1. Run the following command:

```
make push
```

## Design of Deployment Manager

There is a more detailed [design document](docs/design/design.md) available.

## Status of the project

This project is still under active development, so you might run into issues. If
you do, please don't be shy about letting us know, or better yet, contribute a
fix or feature. We use the same [development process](CONTRIBUTING.md) as the main 
Kubernetes repository.

## Relationship to Google Cloud Platform
DM uses the same concepts and languages as
[Google Cloud Deployment Manager](https://cloud.google.com/deployment-manager/overview),
but creates resources in Kubernetes clusters, not in Google Cloud Platform projects.



