---
title: "Should I Stay or Should I Go?"
date: 2025-07-04T12:00:00-03:00
# weight: 1
# aliases: ["/first"]
tags: ["Go", "Opinion"]
author: "Mago"
showToc: true
TocOpen: false
draft: false
description: "This is my first blog post in a while and the first here, at my personal website 😄 (I used to post at Medium before). Before getting to the subject, I would like to say that I’m not using any AI to write this. I really want to put my thoughts into the texts you see here. These are my thoughts now, at the date I’m posting this, and they can change with time. There are some jokes about JS, but it’s all just for humor purposes, don’t be mad 😉"
ShowReadingTime: true
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowWordCount: true
ShowRssButtonInSectionTermList: true
---
Let's talk about why Go is so interesting and why I love it!

It took me some time to choose the title of the post. I wanted to play with a song name; the first one that came to my mind was “Should I Stay or Should I Go?” by The Clash, a classic. But then my curiosity made me search for other songs with the word “go.” And there are a lot.

“Go” by Pearl Jam, “Go” by Blink-182, “Go” by Indigo Girls, “Go” by Kelly Clarkson, "Go" by The Smashing Pumpkins, "Go" by Def Leppard, "Go Go Go" by Chuck Berry, “Here I Go Again” by Whitesnake, “Go All the Way” by Raspberries, “Go Your Own Way” by Fleetwood Mac … and the list goes on!

After some consideration, I found out I had lost lots of time searching and listening to songs, and I decided to go 🤭 with The Clash.

But it fits perfectly with the theme. I’m also a mentor at ADPList, and many of my mentees ask me this question from the title. Ok, not exactly like that, but like “Should I learn Go?” or “Why do you like Go?”

The first question is hard to answer, but as a senior engineer, I have the answer: “It depends.” Usually, I start asking, not answering, because it depends on each one's reality. I will not dive into this question today (maybe in another post). Today I want to talk about the second one; maybe it helps you reflect on the first one and clear things up for you, maybe not.

First I want to tell my story quickly: how I ended up working with Go, when it started and why I chose to keep going.

## How it started

My first contact with Golang was on a cold night (not that cold, this is Brazil) in September 2020. I was working with JavaScript at that time, I was unhappy (of course, it’s JS 🤪) and wanted to change jobs. A friend of mine was working in a company using Go and said they were looking for engineers, and wanted to refer me. I didn’t know Go at the time (just by name), but he said the language was great. I was unsure, but I accepted it and started the selection process.

The first step was a LeetCode-like challenge, but it wasn’t mandatory to use Go. But I wanted to show “I’m a fast learner,” so I took one day to study the documentation and did some basic LeetCode with it. I took the test the next day and passed. At that point, I knew I wasn’t that fast; actually, the language is “fast learnable.”

These were the first characteristics of the language that I noticed:

- “It is fast to learn”
- “It has amazing and intuitive documentation”

At that point, I was convinced to give it a try if I got the job.

I got the job, and then the more I dived into the language, tools, and the community, the more I fell in love with it. ❤️

So let’s break into these and other reasons why I fell in love.

## Great Documentation

Why is the documentation great?

It’s meant for learners. When you enter the [Go documentation webpage](https://go.dev/doc/), you don’t see lots of texts and references, etc. You see lots of links to resources for learning, tutorials, examples, good practices, guidelines, and explanations of the internals. It has resources for starters and for those who want to dive into the internals of Go, like how the garbage collector works. They make it easy for you to start using, but they want you to understand how Go works—really understand what you are doing.

One of the main parts is the [Learn Go](https://go.dev/learn/) section. It’s so amazing; it’s where I first learned Go, and that’s my suggestion to all my mentees and everyone that asks. I’m not a video tutorial fan, so I tend to prefer written material.

It tells you everything very straightforwardly, starting with how to install. Then you have the amazing [Tour of Go](https://go.dev/tour/welcome/1), where it will teach you all the basics with split sections and interactive examples for you to run using the Go Playground. It’s great because many people get afraid when they see lots of texts, without a certain order—they freeze. The “Tour of Go” takes you by the hand in a linear path through the magical world of the Gopher, with compiled information, just what you need to get an idea of how everything works without letting your memory overflow. At the end, it gives you a ton of links to deep dive into some subjects, like concurrency, and some more practical tutorials, like web servers and CLIs.

You also have [Go by Example](https://gobyexample.com/), which gives you a brief explanation and examples for common Go usage. It’s great because it has an index with the subject associated—something to help you remember some stuff without having to go through the tour all over again. These two are a great combo for starters. And if you want to expand more, there’s the [Go Specification](https://go.dev/ref/spec).

And of course, you have the amazing “Effective Go,” a guideline to write idiomatic Golang. It’s a must-read. I know it’s long, like this blog post is becoming, but it’s worth your time.

The [Release Notes](https://go.dev/doc/devel/release) are amazing, always summarizing the main changes in the language first, then they go tool by tool, package by package. It’s really made for humans to read, and it’s great as a guide to understand the impact on your code. You can easily look at each topic, see what can impact you, and test or change your code to use the newest modifications.

And of course, we cannot forget the [Standard Library Reference](https://pkg.go.dev/std). It has all the packages, all the functions, methods, explanations, and examples. It’s amazing.

## Fast to learn

I experienced this and have heard from many others the same. Why?

It becomes pretty obvious after the last paragraphs I wrote about the documentation 😄. It really has a way to onboard you fast and let you dive into the language as you need and want.

But it’s not only that, there’s more…

## Go is simple

Just looking at some data, Go is one of the mainstream languages with the fewest reserved words:

- Java: > 60
- JavaScript: > 50
- Rust: > 35
- Python: > 30
- Go: 25

How is that possible? A simple example that I like is that you don’t have `while`; you just use `for` without a condition. Do you want to make a function private? Just use lowercase.

Go tries (almost always) to be concise, to have as few ways as possible of doing the same thing. It wants to give you tools (types, functions, methods) to allow you to build your logic, not to build everyone’s logic and package it. For example, we don’t have `for` and `foreach` like in JS. Of course, there are methods from the slices package to sort, compare, and we have iterators now. But all of them have their purpose; it’s not simply a way to avoid creating an `i` variable in the for loop. You could argue that in Go there is the `range` to do something similar to what `foreach` does. But it has more specific uses, like ranging over channels.

Because of this simplicity, Go is easy to read—even the standard library internal code. They really do what they suggest you do. Go is humble; it doesn’t try to be unnecessarily clever and fancy, it just does the work. No classes, no inheritance, just composition.

Simplicity has a strong relation with being explicit in this case, and sometimes it has its price: more code written, like in the case of error handling in Go. 😬

## Go is reliable

Go has the philosophy of backwards compatibility at all costs, avoiding breaking changes on major or minor versions. It happened in the past, of course—there’s the famous [loopvar change](https://go.dev/blog/loopvar-preview) where they changed how the loop variable behaves. It was in many cases the root of bugs, but that’s because of a dissonance between the behaviour and what most people expected, and at the end, it was just behaviour. And the behaviour changed; maybe someone was relying on the way things were, and the fix actually caused a new bug. Who knows? Not me, I read the release notes every time. That’s why I always advise you to read them before updating your Go version, especially if it’s a major version.

Although we don’t have an exact date of release of new Go versions, we can count on two major releases a year.

## Go improves

Go is always seeking improvement in all areas: performance of the compiler, of the packages (like faster JSON encoding), and bringing new toys, like iterators and generics. I don’t know about you, but for me, all this effort to bring new features and improve things gets me excited like when a new video game console will be launched or a new Star Wars movie will be released (when they were good).

I know much of this stuff is not new, like generics or PGO. But all of it is thought through carefully and discussed in the community before being merged. And I think Go and its community are an ecosystem that revives and brings light to some old tech in a way that people think it’s new. Because they do it in a developer-friendly way, like PGO. It was already a thing in C++ and other languages. But if you search PGO today, the majority of content, posts, and talks will be related to Golang.

## Go is an ecosystem

Golang is more than a language; it is a Swiss Army knife. When you install it from the official website, you get a powerful tool with the capabilities of:

- testing (`test`)
- building (`build`)
- formatting and fixing mistakes (`fmt`, `vet`)
- managing modules (`mod`)
- managing dependencies (`get`)
- analyzing profiles (`tool pprof`)

And benchmarking, outputting test coverage, and much more…

It’s all accessible out of the box with the command line `go <command>`. You don’t have to install different tools to start coding and maintaining your code. Of course, there are some third-party tools that can help you along the way, like `golangci-lint`.

## The Community

This is another great point: Golang has an active community of enthusiasts. You have official channels for it—Slack, Google Groups—and even the Go repository is a great place to get involved in discussions inside the issues. You can point out improvements or bugs and collaborate through pull requests.

There are tons of Golang groups and conferences, and I see more and more starting. Here in Brazil, we have meetups like Golang SP, Floripa Gophers, and many GDGs around the country talk about Golang. Of course, there are the main conferences all over the globe, like Gophercon Latam, Golab, Gophercon US, Gophercon UK, etc. And many other conferences have some space for Golang talks, especially DevOps ones, like DevOps Days and Container Days. And there’s space for beginners and experts; every conference I attended, people are nice and open to help someone that’s struggling to start with the language.

Let’s not forget the newsletters. We have the [Golang Weekly](https://golangweekly.com/) and, for the Portuguese speakers, thanks to Elton Minetto, there is [A Semana Go](https://www.asemanago.dev/). This way, you can always keep up to date with news about the language and interesting projects.

I know not everyone wants to think about programming after work, but if you want and enjoy it, there are so many resources and people that share the same feeling and excitement about Go.

## Asynchronous made easy

> ***Go has eliminated the distinction between synchronous and asynchronous code.***  
> Bob Nystrom

This statement is strong and impactful. I really recommend this [post](https://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/).

Golang is amazing because it is built with goroutines, even the main one. Each goroutine is a user-level thread managed by the Go runtime, using a pool of OS threads. The way it works enables avoiding all the async-await hell. Any function can become asynchronous with the keyword `go`; you don’t have a chain of changes over the functions that are calling it.

We also have the usage of channels, the select statement, mutexes, waitgroups, errgroups—lots of features to help you work with concurrency. Switching from JS to Go, it was a breath of fresh air and one of the main things that...

## Performance

You probably were waiting for me to come to this topic; everyone talks about that. But for me, and maybe for most developers, it should be the least important. This is not why I use Go. Every company I worked for, every system I built, could have been built with other languages (even JS 🤢). Most of us don’t count microseconds of performance.

And we have lots of benchmarks all over the internet stating that language X is better than language Y. And most of these benchmarks have shady methodology and lots of biases. A benchmark is a scientific research; it must have a well-defined plan and consider its limitations. There are numerous situations to test, numerous structures and algorithms that these tests will never touch. There are compilation and interpretation improvements that can happen if you run the same code more than once. Maybe a language has a faster encoding of JSON, but another is faster for decoding because of the implementation in each one. And usually, the person comparing tech A to tech B is an expert with A and has a basic understanding of B; of course, it’s easier for them to extract more performance from A.

But yeah, Go is fast, and you can build your web server; it will handle your load. You probably don’t need Rust or Zig for it. Remember that the language is just part of your latency; usually, we have lots of components on the way—container clusters, lots of network hops, load balancers, API gateways, etc.

## Summary

Of course, there are things I don’t like in Go, like the built-in `make`, more specifically its signature `func make(t Type, size ...IntegerType) Type`. It’s not clear what the possible parameters are, and for different data structures, the behaviour is different. I always get confused when using it. I will not dive into the problems; that’s not the point now (maybe in another post).

At the end, the main things that make me love Golang are its ease of use, simplicity, and community. I don’t have a problem changing programming languages at work, but if I had to choose, I would prefer to stick with it, at least for now. We see more and more Golang jobs opening each year and more devs starting their journey learning Go. Remember, Go is a general-purpose language. We usually see APIs and CLIs being built with Go, but it’s possible to serve SPAs, run WebAssembly code generated from Go, and deal with AI stuff. Go is still v1. The future ahead is bright and exciting.
