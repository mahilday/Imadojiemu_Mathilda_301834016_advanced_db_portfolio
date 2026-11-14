# Portfolio 5: Distributed and Cloud Database Exercise

Star Bank operates in two countries, Nigeria and Kenya. So far its database has been a single server on one machine. This portfolio looks at what changes when the bank's data has to live on several servers: how it is copied, how it is divided, what happens when a server fails, and what has to be given up to keep the data correct.

## Why Star Bank needs more than one server

- **One server is a single point of failure.** If it goes down, no member can check a balance or make a transfer.
- **Members are in two countries.** A server in Lagos is far from a member in Nairobi, so every request is slower for them.
- **Data may need to stay in its own country.** Banking and data protection rules often require customer data to be held locally.
- **The data will grow.** One machine can only hold and process so much.

## Replication: keeping copies

Replication means several servers hold the same data. In a replica set, one server is the primary and takes all writes. The others are secondaries and copy every change from it.

For Star Bank I would run three copies of each database. Three is the smallest number that can survive losing one, because the remaining two still form a majority.

Secondaries can also serve reads that do not need to be perfectly up to date. A statement or a transaction history could be read from a secondary, which takes load off the primary. A balance check before a withdrawal should always read from the primary.

## Availability: surviving a failure

If the primary fails, the secondaries notice within seconds and vote one of themselves in as the new primary. Applications reconnect to it without anyone intervening. When the failed server returns, it rejoins as a secondary and catches up on what it missed.

For Star Bank this means a hardware failure costs a few seconds of interrupted writes, not hours of downtime.

## Consistency: what the bank refuses to risk

A distributed database cannot guarantee everything at once. When servers lose contact with each other, it has to choose: keep accepting changes on both sides and risk them disagreeing, or stop accepting changes until contact is restored. This is the trade-off described by the CAP theorem.

For money, Star Bank should choose correctness:

- **A write counts only when a majority of servers have it.** A transfer is confirmed after at least two of the three servers have recorded it, so it cannot be lost if one fails immediately afterwards.
- **A server that cannot reach a majority stops accepting writes.** It cannot tell whether it is the last one standing or merely cut off, so it refuses, to avoid two servers recording conflicting balances.

The cost is that in a serious outage the bank is briefly unable to move money. That is better than moving it twice.

Not all data needs this. A notification or an activity feed can tolerate being a few seconds behind, so those can use faster, looser settings. This matches the split I recommended in Portfolio 4.

## Sharding: dividing the data

Replication copies all the data to every server. Sharding does the opposite: it divides the data so each group of servers holds only part of it.

For Star Bank the natural dividing line is country:

| Shard | Holds | Located |
| --- | --- | --- |
| Nigeria | Members, accounts and transactions with country NG | In or near Nigeria |
| Kenya | Members, accounts and transactions with country KE | In or near Kenya |

Each shard would itself be a three-server replica set, so the bank would run six database servers in total.

Country works well as the dividing key for three reasons:

- **Members are served from nearby**, so requests are faster.
- **Each country's data stays in that country**, which supports local data rules.
- **Most transactions stay inside one shard.** My business rule BR10 already says a transfer must be between accounts in the same currency, and currency follows country, so a transfer never has to span two shards. Operations that touch one shard are simple and fast; operations that span shards are slow and hard to keep correct.

The weakness is balance. If Nigeria has far more members than Kenya, its shard carries more load. The fix would be to divide the Nigerian shard further, for example by a hash of the member ID.

I designed this but did not build it. A sharded cluster needs configuration servers and routers as well as the shards, which is more than this exercise calls for.

## Deployment in the cloud

In production these servers would not be containers on one laptop. Each replica set's three servers would be placed in separate data centres within a cloud region, so that losing one building does not lose the database. A managed database service would handle backups, monitoring and replacing failed servers.

Where regulation requires data to remain in-country and no cloud region is available there, the shard for that country would run in a local data centre instead.

## How this applies to the PostgreSQL ledger

The same ideas apply to the relational database from Portfolios 1 to 3, which I recommended as the system of record. PostgreSQL supports replication from a primary to standby servers, and can be set to confirm a transaction only after a standby has received it. Distributed SQL databases go further, combining the relational model and ACID transactions with built-in replication and placement of data by region.

## Practical demonstration

*Keep this section only if the demonstration was run. Otherwise delete it, and the related rows in the evidence table.*

I ran a three-server MongoDB replica set in Docker, loaded the Star Bank data from Portfolio 4, and tested the points above.

Files: [docker-compose.yml](docker-compose.yml), [Replica_Set_Demo](Imadojiemu_Mathilda_301834016_Replica_Set_Demo.sh), [Output](Imadojiemu_Mathilda_301834016_Output.txt)

| Step | What I did | Result |
| --- | --- | --- |
| 3 | Listed the role of each server | TO FILL: one PRIMARY, two SECONDARY |
| 4 | Loaded the data once, counted transactions on each server | TO FILL: 10 on all three |
| 5 | Stopped the primary | TO FILL: which server became the new primary |
| 5 | Wrote a record with one server down | TO FILL: accepted |
| 6 | Restarted the stopped server | TO FILL: rejoined as SECONDARY and held the missed record |
| 7 | Stopped two of the three servers and tried to write | TO FILL: refused |

Step 7 is the consistency rule in action: with no majority, the remaining server would not accept a write.

## Limits

- This is a design for Star Bank, not a deployed system.
- Sharding and cloud deployment are described, not built.
- Three containers on one laptop share the same hardware. They show how a replica set behaves, not how it performs across real data centres.

## Evidence

| Topic | Where |
| --- | --- |
| Replication | [Replication](#replication-keeping-copies) above; demonstration steps 3 and 4 |
| Availability | [Availability](#availability-surviving-a-failure) above; demonstration steps 5 and 6 |
| Consistency | [Consistency](#consistency-what-the-bank-refuses-to-risk) above; demonstration step 7 |
| Sharding | [Sharding](#sharding-dividing-the-data) above (design only) |
| Deployment | [Deployment in the cloud](#deployment-in-the-cloud) above (design only) |