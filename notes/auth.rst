====
auth
====

saml
====
security assertion markup language

Now there are lots of moving parts like

    * Assertion Query
    * Authentication Request
    * Artifact Resolution
    * Name Id Management and mapping
    * Single Logout

and hit has a bunch of different binding

like soap, redirect, post, artifacte

but the gist of it is.

* your browser requests a resource (the service provider)
* service provider says ( hey you belong to this organization go your identity provider and come back with some more info),  redirects browser to the idp
* you login, idp gives you an signed, maybe encrypted assertion,  xml payload with some info that describes you
* service provider takes a look at the assertion, says verifyies the cryptographic signature as well as the info in it and says "you're good", then redirects you to the resource.


shibboleth
octa
onelogin

oidc
====

built on top of oauth.  oauth is authz, oidc is authn.

so it's a similar process to saml, where you're bounced back and forth between a service and identity provider and you wind up getting a token to hand to the service provider at the end.  there is one major difference between the two.
with oauth, you ask 'hey idp, cna you please help me prove who I am?"
with oidc. you ask, 'hey idp, can I please get a token that is valid for this one particular resource"


jwt
===
json web tokens

it's literally a cryptographic json token holding claims that can be passed around.
things like "I'm an admin", or "I'm a nobody".

You can shoehorn them to hold more, but they really shouldn't be used to hold state data, which must be checked against a datastore. jwt should be stateless


kerberos
========

typically four steps

* user client authn
you bascially prove your identity via, password, cert, other means and get

* client authn
client uses the tgt to prove your identitity to the service

* client service authz
client checks whether the service actually exists in the authentication server

* client service request
client and service decrypt keys, trust is proved,  server provides the services to client

* client serviec authorization
client sends the tgt and the encrypted authenticator (client id and timestamp)
service send abck the clien to serv

spnego
^^^^^^
simple protected gssapi negotiation mechanism
negotiates security mechanisms for the gss-api, which currently the only major implementation of gssapi is krbv5

ldap
====
should never be used for authn, only authz.
pki
