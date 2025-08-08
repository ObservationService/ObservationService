# **UNFINISHED DOCUMENTATION**
<sub>lemon please finish this before the weekend ends</sub>

# ObservationService
---
ObservationService is a roblox module that allows you to observe players on server, and it helps with making anti-cheat.
The module is written in **pure lua**, with no other languages.

It has a **flagging system** that lets you flag the observedPlayer when something happens.

# Table of Contents
1. [Getting Started](https://github.com/ObservationService/ObservationService/blob/main/README.md#getting-started)
2. [The Observation Functions](https://github.com/ObservationService/ObservationService/blob/main/README.md#the-observation-functions)
3. [But, What are Observers?](https://github.com/ObservationService/ObservationService/blob/main/README.md#but-what-are-observers)

## Getting Started

Observing a player is done through this function:
```lua
ObservationService.ObservePlayer(Player: Player): ObservedPlayer
```
It returns an instance of a class named **ObservedPlayer**.
It lets you use functions that observes the actions of the players.

Right now, there's only 2 functions. But first,
You gotta observe the player with this function:
```lua
ObservedPlayer:StartObserving(): ()
```
What it does is starts the observation, which allows you to use the observe functions.

You **should** wait for when the player's observation starts so you can avoid errors with observing.
This function should help you.
```lua
ObservedPlayer:IsObserved(): boolean
```

## The Observation Functions
You can observe **only these things** at the time I'm writing these.
- Walkspeed
- JumpHeight

The **planned** things to have an observation functions are:
- Movement
- Collision
- Position

You can observe a player's walkspeed with this function:
```lua
ObservedPlayer:ObserveSpeed(allowedSpeed: number?, onDetect: (threshold: number, speed: number, state: Enum.HumanoidStateType, ping: number) -> (), speedDetectionWait: number?): Observer
```
It observes how fast the player moves in their client.
It uses the fact that their walkspeed on client also applies to the server for it's advantage.

Since the walkspeed property **doesn't change** on the server, but does on the client,
It calculates how fast the player is going and compares it to the allowed speed.
It flags by itself if there's no onDetect function.

The player's ping is part of the calculation, ensuring laggy players get a chance to play.

## But, What are Observers?
Observers are custom classes that hold the observation progress.

You can stop the observer with this function.
```lua
Observer:Stop(): ()
```

If you want to avoid false-positives with detections (e.g. Teleportation, Vehicles), you can use this function.
```lua
Observer:IgnoreTick(amount: number?)
```
It adds `amount` ticks to the amount of ticks to be ignored by the observer, which skips that checking.
