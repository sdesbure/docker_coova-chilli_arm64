CoovaChilly
===========

CoovaChilly - http://coova.github.io/CoovaChilli/

Latest CoovaChilly release from git

**Pull image**

```
docker pull sdesbure/coova-chilly

```

**Run container**

```
docker run -d --name=<container name> -v <path for config files>:/config -v /etc/localtime:/etc/localtime:ro sdesbure/coova-chilly
```

Please replace all user variables in the above command defined by <> with the correct values.
