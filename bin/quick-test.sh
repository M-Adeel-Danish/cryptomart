#!/bin/bash

set -e

http --session barong POST http://exchange.cryptomart.us/api/v2/barong/identity/sessions email='admin@barong.io' password='0lDHd9ufs9t@'
http --session barong GET http://exchange.cryptomart.us/api/v2/barong/resource/users/me
http --session barong GET http://exchange.cryptomart.us/api/v2/peatio/account/balances
