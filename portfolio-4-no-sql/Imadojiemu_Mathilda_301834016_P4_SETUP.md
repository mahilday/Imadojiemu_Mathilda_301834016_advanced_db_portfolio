# Portfolio 4: Setup and Run Instructions

These steps start MongoDB in Docker and run the Star Bank document script. They were carried out on Windows using Git Bash.

## Requirements

- Docker Desktop, installed and running.
- The script [Star_Bank_Mongo_Documents](Imadojiemu_Mathilda_301834016_Star_Bank_Mongo_Documents.js), in the current folder.

No local MongoDB installation is needed. The database and its shell, `mongosh`, both run inside the container.

## Step 1: Start MongoDB

```
docker run --name star-bank-mongo -p 27017:27017 -d mongo:7
```

| Part | Meaning |
| --- | --- |
| `--name star-bank-mongo` | The name used to refer to the container in later commands |
| `-p 27017:27017` | Makes MongoDB reachable on port 27017 of the laptop |
| `-d` | Runs the container in the background |
| `mongo:7` | The official MongoDB 7 image |

If port 27017 is already in use, change the first number, for example `-p 27018:27017`.

Check that it is running:

```
docker ps --filter name=star-bank-mongo
```

## Step 2: Copy the script into the container

```
docker cp Imadojiemu_Mathilda_301834016_Star_Bank_Mongo_Documents.js star-bank-mongo:/tmp/p4.js
```

Repeat this step whenever the script is edited.

## Step 3: Run the script

In Git Bash:

```
docker exec star-bank-mongo mongosh --quiet --file //tmp/p4.js
```

In PowerShell or Command Prompt:

```
docker exec star-bank-mongo mongosh --quiet --file /tmp/p4.js
```

The double slash is needed in Git Bash only. Git Bash rewrites a path such as `/tmp/p4.js` into a Windows path before passing it to Docker, and the container then cannot find the file. The double slash stops that rewriting.

## Step 4: Save the output

```
docker exec star-bank-mongo mongosh --quiet --file //tmp/p4.js > Imadojiemu_Mathilda_301834016_Output.txt
```

## What a successful run shows

| Section | Expected |
| --- | --- |
| Counts | members: 4, transactions: 10 |
| Q1 to Q6 | Query results, as listed in the README |
| V1 and V3 | Rejected: Document failed validation |
| V2 | Rejected: E11000 duplicate key error |
| Query plan | A plan containing an `IXSCAN` stage |

The script drops and rebuilds both collections each time, so it can be run repeatedly with the same result.

## Useful commands

| Purpose | Command |
| --- | --- |
| Open an interactive shell | `docker exec -it star-bank-mongo mongosh star_bank` |
| Show the MongoDB version | `docker exec star-bank-mongo mongosh --quiet --eval "db.version()"` |
| Stop the container | `docker stop star-bank-mongo` |
| Start it again | `docker start star-bank-mongo` |
| Remove it and its data | `docker rm -f star-bank-mongo` |

## Problems met during setup

| Problem | Cause | Fix |
| --- | --- | --- |
| `ENOENT: no such file or directory, open '/C:/Users/.../Temp/p4.js'` | Git Bash rewrote `/tmp/p4.js` into a Windows path | Use `//tmp/p4.js` |