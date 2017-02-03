#Funky Mini-Bus

* The bus is a clock line, a data line and an instruction specifying what to do with the data.
* Endpoints are joined together in a daisy-chain
* The bus is self-identifying, reporting the ordering, names and sizes of the endpoints.
* All data is treated as BLOBs (oriented LSB first): They care nothing for word-boundaries.
* The endpoint receives data, fills up the endpoint and then ignores any remaining bits.
* There are 6 types of instructions
  * ignore
  * data
  * read
  * write
  * lock
  * unlock
* The typical use case would be to send unlock instructions to all endpoints, send a write instruction, send the data for filling the first endpoint, send the lock instruction, send a write instruction, send the data for filling the second endpoint, send the lock instruction, etc.

There are four IPbus endpoints:

 * A register for sending an instruction down the bus
 * A register for loading data for sending down the bus
 * A register reporting the bus size
 * A ram containing the list of endpoints ("the infospace")

For interacting with the database, then, the bus would retrieve its infospace, iterate through the endpoints, use the name as a database key to retrieve the data, dump it as a BLOB across the bus, lock the endpoint and repeat.