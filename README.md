# Replacement Kindle Ads Server

## Server setup

Steps below [OpenShift](https://www.openshift.com/) client commands. These can probably be ported to vanilla Kubernetes but until I see some interest in that, these docs will be the primary setup method. You can also just build the Docker image for this project and deploy wherever! 

### Deploy application

This is the easiest part of the whole setup:
```
# oc new-app https://github.com/bostrt/kindle-ads
```

### Certificate setup
Your user needs to have permission to create a Certificate Signing Request (CSR). First, create a custom `clusterrole`:

```
# oc create clusterrole certificate-signing-requestor --verb=get,list,create --resource=certificatesigningrequests.certificates.k8s.io
```

And associate with your user:

```
# oc adm policy add-cluster-role-to-user certificate-signing-requestor my-user
```

Next up, run the `fakecrt.sh` script included in this repository to create a CSR object to be used in OpenShift:

```
# ./fakecrt.sh
# oc create -f fakecsr.yaml
```

You'll have to approve the CSR next, probably as `system:admin` or another user with cluster admin type privileges:

```
#  oc adm certificates approve <name>
```

Once the CSR is approved, you can then download the signed cert and use it!

```
#  oc get csr adpublisher-svc.cheep -o jsonpath='{.status.certificate}'     | base64 --decode > server.crt
```

You will then need to create two new routes with the signed certificate and private key. There are two hostnames that Kindle uses for pulling advertisements that you will be using:

- `adpublisher.s3.amazonaws.com`
- `dadet-kapo-prod-flights.s3.amazonaws.com`

```
#  oc create route edge adpublisher --cert=server.crt --key=fake-adpublisher.key --hostname=adpublisher.s3.amazonaws.com --service=kindle-ads
#  oc create route edge dadet-kapo-prod-flights --cert=server.crt --key=fake-adpublisher.key --hostname=dadet-kapo-prod-flights.s3.amazonaws.com --service=kindle-ads
```

At this point, you have the server configured and ready to go. There's plenty more work to do on the Kindle itself and your DNS server.

### DNS Configuration

As mentioned above, there are two hostnames that Kindle uses for pulling advertisements:

- `adpublisher.s3.amazonaws.com`
- `dadet-kapo-prod-flights.s3.amazonaws.com`

These will need to be overriden in your own DNS configuration. The two configuration options to accomplish this are:

- Use DNS `A` record, pointing to IP Address.
- Use DNS `CNAME` record, pointing to another hostname.

I chose to use [CoreDNS](http://coredns.io/) out of familiarity and have it running on a Raspberry Pi on my internal network. I won't go through setting up CoreDNS from scratch but there's the Corefile configurations I added and the zone data:

Corefile snippet:
```
# Internal Kindle ad server hack
adpublisher.s3.amazonaws.com {
   file /etc/coredns/zones
}

dadet-kapo-prod-flights.s3.amazonaws.com {
   file /etc/coredns/zones
}
```

Zone data snippet:
```
adpublisher.s3.amazonaws.com. IN A 127.0.0.1
dadet-kapo-prod-flights.s3.amazonaws.com. IN A 127.0.0.1
```

Pretty easy setup. There honestly might be a more efficient way to configure this in CoreDNS but the configuration above does work.

Note that an alternative method to the zone data snippet above would be to use `CNAME` instead of `A` and specify another hostname instead of an IP Address. 


# Notes. To be better documented.

```
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
```