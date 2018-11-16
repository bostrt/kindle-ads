openssl genrsa -out fake-adpublisher.key 2048
openssl req -new -key fake-adpublisher.key -out fake-adpublisher.csr -subj '/C=US/ST=Washington/L=Seattle/O=Amazon.com Inc./CN=*.s3.amazonaws.com'
cat <<EOF > fakecsr.yaml
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: adpublisher-svc.cheep
spec:
  groups:
  - system:authenticated
  request: $(cat fake-adpublisher.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
EOF

# Make sure your user had csr create permission:
#  oc create clusterrole certificate-signing-requestor --verb=get,list,create --resource=certificatesigningrequests.certificates.k8s.io
# oc create -f fakecsr.yaml
# Login as ocp admin and approve cert:
#  oc adm certificates approve <name>
# Download cert as client and use it!
#  oc get csr adpublisher-svc.cheep -o jsonpath='{.status.certificate}'     | base64 --decode > server.crt
# Create route
#  oc create route edge adpublisher --cert=server.crt --key=fake-adpublisher.key --hostname=adpublisher.s3.amazonaws.com --service=go-print-request-headers
# Add CNAME to DNS server pointing adpublisher.s3.amazonaws.com to your app hostname or A record pointing to IP.
# Add CA cert to /etc/ssl/certs/ca-certificates on Kindle

# TODO
# Put all these notes in a real doc
# Other ads are also pulled from dadet-kapo-prod-flights.s3.amazonaws.com !!!
# Example request:
#  10.129.0.1 - - [16/Nov/2018:22:46:24 +0000] "GET /8148/8981198440101_XX-3b5a8c746b8fbd0b324e343dd802191026383609b0119db2142b27689796d4b0/bcd05f741e81540c7d5cc840dc88f66fc36aa71a55b396b98f05fe9065ed6486/1.0/ad-8981198440101_XX-3b5a8c746b8fbd0b324e343dd802191026383609b0119db2142b27689796d4b0.20180409164836.1515612200601.apg?software_rev=2692310002&patchVersion=2&currentTransportMethod=WIFI&currentMCC=&currentSponsoredHotspot= HTTP/1.1" 404 233 "-" "-"


# DEBUG
# curl -o ad.apg -H 'Host: adpublisher.s3.amazonaws.com' -vk 'https://52.216.101.59/US/94/84/9484321190501/SHASTA/ad-9484321190501.20180409170745.1515612200601.apg?software_rev=2692310002&patchVersion=2&currentTransportMethod=WIFI&currentMCC=&currentSponsoredHotspot='
# < HTTP/1.1 200 OK
# < x-amz-id-2: ZRffERjiTdzelBgzto2GWtaKdOHIF2XjESK8oAIUYpf9hmZRTnq4v+E/GffCfzzIJi3s9XTXr0w=
# < x-amz-request-id: 3544210C38446F45
# < Date: Fri, 16 Nov 2018 17:28:42 GMT
# < Last-Modified: Mon, 09 Apr 2018 17:07:46 GMT
# < ETag: "05480ae8221b6c4e1c903ff19f852e43"
# < x-amz-storage-class: REDUCED_REDUNDANCY
# < Accept-Ranges: bytes
# < Content-Type: application/x-apg-zip
# < Content-Length: 311814
# < Server: AmazonS3
