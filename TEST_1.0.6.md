# IRegister => Iregister

## Iregister.sol :
# VIPstatus => VIPStatus
# function external `transferUsername()` added
# event `TransferUsername()` added instead of `SignIn`

## Register.sol :
# VIPstatus => VIPStatus
# function external `transferUsername()` added
# function private `_deleteUser()` added
# function private `_setUsername()` added

## IRNC.sol :
# `genrateFee` => `applicantFee`
# events moved from RNC


## RandomNumberConsumer.sol :
# `genrateFee` => `applicantFee`
# events moved to IRNC.sol
# AggregatorInterface.sol imported
# uint256 `appFee` removed
# `priceFeed` added
# function external `applicantFee` feeds from aggregator
# `appFee` => `applicantFee`


# `Iswap.sol` and `Swap.sol` added to new folder `swap`

## ChanceRoom.sol :
# bool `gateIsOpen` removed => string status "open"
# `gateFee` => `seatPrice`
# `userCount` => `seatsTaken`
# `userLimit` => `seatsLimit`
# mapping `userEntered` removed
# modifier Enterance: `userEntered` removed
# 