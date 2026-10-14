## Description

Hey everyone, there's this really cool game called [Valheim](https://www.valheimgame.com/) that I used to play with my friends (I strongly recommend you to play it, cause it's <b>AWESOME</b>).

Game offers you to host your own server; but that lead us to a problem.

## A gamer's problematic.

What's the problem? Only a single player will have access to the server data :(

Since we wanted to have a personal server only for us I thought: maybe at the best we can share the Database so we can all have the same progress and host/play whenever we want without depend on a particular player.

## Solution

* What if we track the saved data and we upload into Github?

* And what if we add an script that will fetch data once you start the game?

* Additionally, what if the same script will push changes once you close the game?

* And..And..And.. what if it will push changes every lapse of time as well?

## Usage

1. If you're curious about how it works you can clone this repository at `C:\Users\<user>\AppData\LocalLow\IronGate\Valheim\worlds_local` (this will add my current game DB).
2. Once repository it's cloned you can look for Valheim.bat file, use right click select Send to option and then Desktop (create shortcut).
3. You're ready to play, just start the game by using Valheim.exe file (now it should be in Desktop).

## Pre-requisites

1. Git as environment variable.
2. Game in Steam(feel free to reach [me](https://steamcommunity.com/profiles/76561198395802666/)).

## Authors and acknowledgment

I felt pretty geek by doing this, but I think it's nice that we can use Development tools we normally use at work to do some random things.

It's a really small but powerful solution that doesn't require a lot of knowledge to understand what's about.

I love to automatize stuff and even by doing something that it's common for us as Developers I learned something new ([Git LFS](https://git-lfs.com/)) while doing it.
