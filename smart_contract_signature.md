# Gasless ERC‑20 Transfers Using Permit (No ETH Needed for the Sender)

Many users hold ERC‑20 tokens but have zero ETH, meaning they can’t pay gas to transfer tokens.
To solve that, we can use ERC20 Permit + a relayer.

step1
```
pip install -r requirements.txt
```
step 2
open python file and add the details
```
like:[owner,receiver,private-key,expiry,value/amount,RPC_URL,Token_name,Token_address,Chain_Id]
```
step 3
execute the python file
python `signature_permit.py`

you will get the output:

```shell
Current nonce: 5
owner: 0x298FE672770e5b8f636C054cCc2Ad3
Spender: 0x7672cb2e9a8C26665CF51413D6790CaBdD3d33A9
permit value/amount: 1000000000
expiry/Deadline: 1764999911
Signature v: 27
Signature r: 678cd73d71cc2512ec5bd42709aead02133ac0b0ce99538cb6d7c93dcd715b82
Signature s: 13f7acb7fc85ee5fb517dc8031ca791068a2f5764f650833e92d7cf5b99a5280
```

**from smart-contract call()**

`permit(owner:"",spender:"",value:"",deadline:"",v:"",r:"",s:"")
`

Note: you got all these values when you executed the python file
`signature_permit.py`

Tips:-
```
r:0x....hash
s:0x....hash
```
