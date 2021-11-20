## Factory.sol/events/NewChanceRoom:
# add `gateFee`, `percentCommission`, `userLimit`, `timeLimit`

"TEST_1.0.5.4"
# `timeLimit` => `deadLine`

"TEST_1.0.5.5"
## ChanceRoom.sol:
# event `StatusChanged(string newStatus)` added
#
# status `open and active` => `open`
#        `Number of users has reach the quorum.` => `user quorum reached`
#        `waiting for random number...` => `waiting for RNC`
#        `Finished.` => `closed`
#        `Canceled.` => `canceled`