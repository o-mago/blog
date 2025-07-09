---
title: "Concurrent code testing with synctest bubbles in Go"
date: 2025-07-09T12:00:00-03:00
# weight: 1
# aliases: ["/first"]
tags: ["Go", "Technical", "Testing", "1.25"]
author: "Mago"
showToc: true
TocOpen: false
draft: false
description: "Learn how to test concurrent code in Go using the new synctest package, which provides a fake clock and blocking mechanism for goroutines."
ShowReadingTime: true
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowWordCount: true
ShowRssButtonInSectionTermList: true
---
Have you ever got confused about testing functions using `time.Now()`? What about functions calling goroutines? 

Well your problems are over… or they will be over with Go 1.25, that will be released soon (probably next month) featuring the new `testing/synctest` package

### What does synctest do?
Basically, it allows you to run your tests in a “bubble”, a kind of isolation from the rest of the test.

It’s meant to make your life easier when testing concurrent code, avoiding flaky tests, changing your production code to be testable, and reducing the time to run tests.

This bubble has two main features:

- A fake clock
- A blocking mechanism for goroutines

It has two exported functions (actually three, but one is already deprecated 😲; we’ll discuss this more in a bit):

```go
func Test(t *testing.T, f func(*testing.T))
func Wait()
```

`Test` creates what we call a “bubble.” It’s the function that allows you to stop the clock in the past and control its flow as if you were the Flash running so fast ⚡. It waits until all goroutines have returned and will also make the test fail if any goroutine becomes deadlocked. It’s a way to even detect goroutine leaks.

`Wait` will wait until all goroutines get into a state called “durably blocked.” This means waiting until they have already finished or are blocked and won’t keep running unless an event is triggered by another goroutine inside the bubble to unblock them. I know it’s a bit confusing, but we’ll see an example soon.

### The fake clock

The `time.Now()` will return `midnight UTC 2000-01-01`, meticulously chosen to remind us about the fears of the year 2000 problem, or millennium bug 🤪. And time won’t advance until all goroutines inside the bubble are blocked, for example, by using a `time.Sleep` to block them. It’s so much easier to control time this way, instead of having to rely on random sleep times and creating flaky tests.

I used to do things like this:

```go
var _now = time.Now

func TimeToSendMessage(fallbackTime time.Time) time.Time  {
	now := _now()
	
	if now.Hour() > 9 && now.Hour() < 18  {
		return now
	}
	
	return fallbackTime
}
```

This code basically returns the time to send a message (SMS or something like this). We don’t want to bother our clients by sending messages outside business hours, so we check the hour of our current day. If we are before 9 a.m. or after 6 p.m., the system schedules a message for a fallback time.

Focus on the `_now` variable. I created it to hold the function `time.Now`, because this way I would be able to “mock” the `time.Now` like this:

```go
func TestTimeToSendMessage(t *testing.T) {
	inputTime := time.Date(2025, 10, 8, 12, 0, 0, 0, time.UTC)
	
	tt := []struct {
		name  string
		mockedNow time.Time
		expected time.Time
	}{
		{
			name:  "should return now",
			mockedNow: time.Date(2025, 5, 8, 12, 0, 0, 0, time.UTC),
			expected: time.Date(2025, 5, 8, 12, 0, 0, 0, time.UTC),
		},
		{
			name:  "should return fallback time",
			mockedNow: time.Date(2025, 5, 8, 20, 0, 0, 0, time.UTC),
			expected: inputTime,
		},
	}
	
	for _, tc := range tt {
		t.Run(tc.name, func(t *testing.T) {
			_now = func() time.Time {
				return tc.mockedNow
			}
	
			result := TimeToSendMessage(inputTime)

			if result != tc.expected {
				t.Fatalf("wrong output")
			}
		})
	}
}
```

I always felt dirty doing things this way. We have some problems here:

- We can’t run these test cases in parallel; we would have a data race since we are reassigning the value of `_now`, and our tests would be flaky.
- I had to add more code, complexity, and ugliness to the production code in order to test it.

Now my problems are over; I can just do the following:

```go
func TimeToSendMessage(fallbackTime time.Time) time.Time  {
	now := time.Now()
	
	if now.Hour() > 9 && now.Hour() < 18  {
		return now
	}
	
	return fallbackTime
}
```

```go
func TestTimeToSendMessage(t *testing.T) {
	inputTime := time.Date(2025, 10, 8, 12, 0, 0, 0, time.UTC)

	tt := []struct {
		name  string
		sleepDuration time.Duration
		expected time.Time
	}{
		{
			name:  "should return now",
			sleepDuration: 12 * time.Hour,
			expected: time.Date(2000, 1, 1, 12, 0, 0, 0, time.UTC),
		},
		{
			name:  "should return fallback time",
			sleepDuration: 0,
			expected: inputTime,
		},
	}
	
	for _, tc := range tt {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			
			synctest.Run(func() {
				time.Sleep(tc.sleepDuration) // time.Now() will add this sleep time
				
				result := TimeToSendMessage(inputTime)

				if !result.Equal(tc.expected) {
					t.Fatalf("wrong result")
				}
			})
		})
	}
}
```

This way, I don’t have to change production code, and I can run the tests in parallel without worries.

If you don’t believe me, here’s the [code](https://go.dev/play/p/nx6o-SBzttt?v=gotip).

### Blocking mechanism for goroutines

I’ve already explained the `Wait` function; let’s go to an example.

Imagine a function `DoSomething` that basically receives a string and returns a string pointer. The pointer will default to the `initialString` address (and value). But we have a goroutine inside that will change the value of the pointer to `"test"` if the `initialString` has the value `"returnTest"`.

Here’s the code and the test:

```go
func DoSomething(initialString string) *string {
	strPointer := &initialString

	go func() {
		if initialString != "returnTest" {
			return
		}

		*strPointer = "test"
	}()

	return strPointer
}
```

```go
func TestDoSomething(t *testing.T) {
	tt := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "should return 'any' pointer",
			input:    "any",
			expected: "any",
		},
		{
			name:     "should return 'test' pointer",
			input:    "returnTest",
			expected: "test",
		},
	}

	for _, tc := range tt {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			synctest.Test(t, func(t *testing.T) {
				result := DoSomething(tc.input)

				if *result != tc.expected {
					t.Fatalf("wrong result %s", *result)
				}
			})
		})
	}
}
```

First, we don’t have a `synctest.Wait()` call, as you can see, and the output of our code is the following:

```go
=== RUN   TestDoSomething
=== RUN   TestDoSomething/should_return_'any'_pointer
=== PAUSE TestDoSomething/should_return_'any'_pointer
=== RUN   TestDoSomething/should_return_'test'_pointer
=== PAUSE TestDoSomething/should_return_'test'_pointer
=== CONT  TestDoSomething/should_return_'any'_pointer
=== CONT  TestDoSomething/should_return_'test'_pointer
	prog_test.go:50: wrong result returnTest
--- FAIL: TestDoSomething (0.00s)
	--- PASS: TestDoSomething/should_return_'any'_pointer (0.00s)
	--- FAIL: TestDoSomething/should_return_'test'_pointer (0.00s)
FAIL
```

It failed. That’s because we are not waiting for all the goroutines to become “durably blocked.” Changing our test:

```go
func TestDoSomething(t *testing.T) {
	tt := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "should return 'any' pointer",
			input:    "any",
			expected: "any",
		},
		{
			name:     "should return 'test' pointer",
			input:    "returnTest",
			expected: "test",
		},
	}

	for _, tc := range tt {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			synctest.Test(t, func(t *testing.T) {
				result := DoSomething(tc.input)

				synctest.Wait()
				if *result != tc.expected {
					t.Fatalf("wrong result %s", *result)
				}
			})
		})
	}
}
```

The new output will be:

```go
=== RUN   TestDoSomething
=== RUN   TestDoSomething/should_return_'any'_pointer
=== PAUSE TestDoSomething/should_return_'any'_pointer
=== RUN   TestDoSomething/should_return_'test'_pointer
=== PAUSE TestDoSomething/should_return_'test'_pointer
=== CONT  TestDoSomething/should_return_'any'_pointer
=== CONT  TestDoSomething/should_return_'test'_pointer
--- PASS: TestDoSomething (0.00s)
	--- PASS: TestDoSomething/should_return_'any'_pointer (0.00s)
	--- PASS: TestDoSomething/should_return_'test'_pointer (0.00s)
PASS
```

### Goroutine Leaks

I will not dive too much into this subject—maybe it deserves a proper post. But the `synctest` package can be used to detect goroutine leaks. Goroutine what???

It’s similar to the idea of memory leaks—a goroutine that’s stuck and should have already ended.

It can happen for different reasons, but one of them is unbuffered channels and early returns.

```go
var (
	ErrorProcess = errors.New("process error")
	ErrorRequest = errors.New("request error")
)

func DoSomething(input string) error {
	c := make(chan error)
	
	go func() {
		c <- process()
	}()
	
	if err := request(input); err != nil {
		return err
	}
	
	err := <-c

	return err
}

func process() error {
	time.Sleep(2 * time.Second)

	return ErrorProcess
}

func request(input string) error {
	time.Sleep(1 * time.Second)
	
	if input == "error" {
		return ErrorRequest
	}

	return nil
}
```

Let’s give an example. Imagine a function where you have an `error` channel and you process some stuff on a goroutine; if any error happens, you produce an error in the channel. Then you do some request, and after, you consume the error from the channel in order to return it. But if this request in the middle fails, it will return, and the consumer will vanish faster than beer near me. As we already know (or maybe you are learning here 😄), unbuffered channels must have active producers **and** consumers at the same time (we don't have a buffer to hold the information). In this case, we have lost the consumer, so the producer will stall and block our goroutine. There’s your leak.

When we try to test it without `synctest`, we get:

```go
func TestDoSomethingNoSynctest(t *testing.T) {
	tt := []struct {
		name     string
		input    string
		expected error
	}{
		{
			name:     "should return process error",
			input:    "ok",
			expected: ErrorProcess,
		},
		{
			name:     "should return request error",
			input:    "error",
			expected: ErrorRequest,
		},
	}

	for _, tc := range tt {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			err := DoSomething(tc.input)

			if !errors.Is(err, tc.expected) {
				t.Fatalf("wrong result")
			}
		})
	}
}
```

```go
=== RUN   TestDoSomethingNoSynctest
=== RUN   TestDoSomethingNoSynctest/should_return_process_error
=== PAUSE TestDoSomethingNoSynctest/should_return_process_error
=== RUN   TestDoSomethingNoSynctest/should_return_request_error
=== PAUSE TestDoSomethingNoSynctest/should_return_request_error
=== CONT  TestDoSomethingNoSynctest/should_return_process_error
=== CONT  TestDoSomethingNoSynctest/should_return_request_error
--- PASS: TestDoSomethingNoSynctest (0.00s)
	--- PASS: TestDoSomethingNoSynctest/should_return_request_error (1.00s)
	--- PASS: TestDoSomethingNoSynctest/should_return_process_error (2.00s)
PASS
```

Oh! Beautiful, my code works, it’s perfect… ewwww, not actually… Running my test with `synctest`:

```go
func TestDoSomething(t *testing.T) {
	tt := []struct {
		name     string
		input    string
		expected error
	}{
		{
			name:     "should return process error",
			input:    "ok",
			expected: ErrorProcess,
		},
		{
			name:     "should return request error",
			input:    "error",
			expected: ErrorRequest,
		},
	}

	for _, tc := range tt {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			synctest.Test(t, func(t *testing.T) {
				err := DoSomething(tc.input)

				if !errors.Is(err, tc.expected) {
					t.Fatalf("wrong result")
				}
			})
		})
	}
} 
```

```go
=== RUN   TestDoSomething
=== RUN   TestDoSomething/should_return_process_error
=== PAUSE TestDoSomething/should_return_process_error
=== RUN   TestDoSomething/should_return_request_error
=== PAUSE TestDoSomething/should_return_request_error
=== CONT  TestDoSomething/should_return_process_error
=== CONT  TestDoSomething/should_return_request_error
--- FAIL: TestDoSomething (0.00s)
	--- PASS: TestDoSomething/should_return_process_error (0.00s)
	--- FAIL: TestDoSomething/should_return_request_error (0.00s)
panic: deadlock: main bubble goroutine has exited but blocked goroutines remain [recovered, repanicked]

goroutine 18 [running]:
testing.tRunner.func1.2({0x567da0, 0xc000212000})
	/usr/local/go-faketime/src/testing/testing.go:1872 +0x237
testing.tRunner.func1()
	/usr/local/go-faketime/src/testing/testing.go:1875 +0x35b
panic({0x567da0?, 0xc000212000?})
	/usr/local/go-faketime/src/runtime/panic.go:783 +0x132
internal/synctest.Run(0xc00018e000)
	/usr/local/go-faketime/src/runtime/synctest.go:251 +0x2de
testing/synctest.Test(0xc000118380, 0xc00018c000)
	/usr/local/go-faketime/src/testing/synctest/synctest.go:282 +0x90
play.TestDoSomething.func1(0xc000118380)
	/tmp/sandbox4287699162/prog_test.go:67 +0x94
testing.tRunner(0xc000118380, 0xc000104040)
	/usr/local/go-faketime/src/testing/testing.go:1934 +0xea
created by testing.(*T).Run in goroutine 7
	/usr/local/go-faketime/src/testing/testing.go:1997 +0x465

goroutine 35 [sleep (durable), synctest bubble 2]:
time.Sleep(0x77359400?)
	/usr/local/go-faketime/src/runtime/time.go:361 +0x12c
play.process(...)
	/tmp/sandbox4287699162/prog_test.go:31
play.DoSomething.func1()
	/tmp/sandbox4287699162/prog_test.go:20 +0x25
created by play.DoSomething in goroutine 34
	/tmp/sandbox4287699162/prog_test.go:19 +0x6b

Program exited.
```

This happens because we still have a blocked goroutine at the end of the `synctest` bubble. The output is a little bit confusing, I know, but there’s another alternative for it: the [goleak](https://github.com/uber-go/goleak) package by Uber.

And to fix this leak in our code it's easy, we just have to transform our unbuffered channel into a buffered channel, so we can have a buffer to hold the information if the consumer is not there:

```go
func DoSomething(input string) error {
	c := make(chan error, 1) // Buffered channel with a capacity of 1
	
	go func() {
		c <- process()
	}()
	
	if err := request(input); err != nil {
		return err
	}
	
	err := <-c

	return err
}
```

### The 3rd function

I said that there were actually three exported functions inside this package (at least at the time of this post). That’s because this package was first introduced as an experimental package with Go 1.24. This way, you can already preview this new change now—if your code is not stuck in an older Go version 👀.

The examples I gave used the new Go 1.25 API. It’s possible to test it easily by downloading the release candidates or using the [Go Playground](https://go.dev/play/) and selecting the `Go dev branch` version in the dropdown. Be aware with every experimental feature because the API can change. Quoting the release notes:

> The package API is subject to change in future releases  
> Go 1.24 release notes

Let’s first take a look at the differences between them:

Go 1.24:  
`func Run(f func())`  
`func Wait()`

Go 1.25:  
`func Run(f func())`  
`func Test(t *testing.T, f func(*testing.T))`  
`func Wait()`

As we can see, the `Wait` and `Run` functions haven’t changed. The only change is the addition of `Test`. But it was actually made to replace `Run`. In the [docs](https://pkg.go.dev/testing/synctest@master), you can read:

```go
func Run(f func())
Run is deprecated.

Deprecated: Use Test instead. Run will be removed in Go 1.26.
```

Their core functionality is the same, as we can see in the [source code](https://cs.opensource.google/go/go/+/master:src/testing/synctest/synctest.go;bpv=1;bpt=0). They both call `synctest.Run`:

```go
func Run(f func()) {
	synctest.Run(f)
}
```

```go
func Test(t *testing.T, f func(*testing.T)) {
	var ok bool
	synctest.Run(func() {
		ok = testingSynctestTest(t, f)
	})
	if !ok {
		// Fail the test outside the bubble,
		// so test durations get set using real time.
		t.FailNow()
	}
}
```

But the change was not only the name—the parameters are different, and `Test` calls `testingSynctestTest`, which is important. Let’s understand a little bit more about what happened here.

They added the `t *testing.T` parameter, and `testingSynctestTest` will basically create a new `t2 *testing.T` based on `t`. But why?

So `T.Cleanup` calls can run inside the bubble at the end of the `synctest.Test` function, and `T.Context` can return a cancellable context with a `Done` channel in the bubble.

You can see more examples about `synctest` in the [Go blog](https://go.dev/blog/synctest)—it was based on the experimental Go 1.24 version, but it’s pretty similar to what you can do with Go 1.25 using `Test` instead of `Run`. You can also check the [package reference](https://pkg.go.dev/testing/synctest@master).

And that’s all folks, thanks for your attention, hope you enjoyed 🤘

And what about you? Are you using `synctest` already?
