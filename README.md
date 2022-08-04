# task
##First

using infra-terraform folder to install EKS dependencies and networking , EKS cluster and EKS node-group
- export variable AWS_PROFILE with your profile name
- set variables that needed through terraform.tfvars

```
cd intra-terraform
terraform init
terraform plan
terraform apply
```

after making sure from nodes of cluster up and running , using kubectl to install argocd :

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

make argocd server expose by `kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'`

this is the loadBalancer of my argocd cluster that I installed it
https://a3128b3aa73f243f8a05beb3c800ab50-1835424501.us-east-1.elb.amazonaws.com

using `admin` user and get password by this command `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo` to login


---------------------------------------------------------------------------------
##Second

setup two argocd Applications using argocd module in argocd folder
before this step i had to expose argocd server because the argocd provider doesn't accept loadBalancer DNS name
So it will be fixed by creating dns zone with domain and using record to resolve lB DNS to domain name like (argocd.production.marfeel.com)

so domain used now is (localhost:8080) into my code
```
cd argocd
terraform init
terraform apply
```
---------------------------------------------------------------------------------------------------------------------

Before installing apps setup `aws-load-balancer-controller` to create ingress with ALB , I follow this way to install alb ingress Controller

the dependencies : helm version 3 and eksctl

Create an AWS Identity and Access Management (IAM) OIDC provider and associate the OIDC provider:

 `eksctl utils associate-iam-oidc-provider --region <region> --cluster <cluster-name> --approve`

Download an IAM policy for the AWS Load Balancer Controller (The IAM policy allows the AWS Load Balancer Controller to call AWS APIs):

 `curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.0/docs/install/iam_policy.json`

 `aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json`

Get the name of the policy's Amazon Resource Name (ARN) and Create an IAM role for the AWS Load Balancer Controller and attach the role to the service account created:

`eksctl create iamserviceaccount --cluster=<your-cluster> --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy --override-existing-serviceaccounts --approve`


Install the AWS Load Balancer Controller using Helm 3:
```
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

helm repo add eks https://aws.github.io/eks-charts

helm install aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=<cluster-name> --set serviceAccount.create=false --set region=<region> --set serviceAccount.name=aws-load-balancer-controller -n kube-system
```


Verify by : `kubectl get deployment -n kube-system aws-load-balancer-controller`

after that i could create ingress type alb in my cluster

my reference  :  https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-aws-waf/

__________________________________________________________________________________________________________________________

first app (in api-app folder) this is the ALB for the one that i setup http://k8s-echoserv-echoserv-3a3bda6507-352657223.us-east-1.elb.amazonaws.com/api
accepting requests prefixed with /api


second app (in nginx folder) i created new image base nginx to add the static.html file and uploaded it to ECR
in folder static-app run :
docker run -d -p 8080:80 nginx-static-html:latest

then login to ecr and tag the local image with the repository , then push it , my image name is `428971313062.dkr.ecr.us-east-1.amazonaws.com/nginx-static-html:latest`
this is the ALB loadBalancer for the one that i created http://k8s-nginx-nginxsta-50cdfaa8d0-1459998875.us-east-1.elb.amazonaws.com/static.html



to setup the same resource in different Environment just overwrite terraform.tfvars file with new cluster name or different region    

------------------------------------------------------------------------------------------------------
incase the Environment is production the argocd app source link with master branch
incase the Environment is development the argocd app source link with dev branch
incase the Environment is staging the argocd app source link with staging branch
