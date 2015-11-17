kubectl delete -f install-custom.yaml
make push
kubectl create -f install-custom.yaml
sleep 5s
kubectl get po
dm list
